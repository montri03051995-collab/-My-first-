-- RELWX egg pickup / return-to-plot core extracted from the supplied source.
-- No UI code included.
-- NOTE: This is an excerpt, not a standalone script. It relies on shared original modules
-- such as xDTaraZ.Player, Tasks, Geo, EggIndex, GameLib, Mount, Config, State, Options,
-- Util, Guard, and the game's existing event/index setup.

-- ========================================================================
-- DELIVERY: locate/pick up egg, return to plot, deposit/recover
-- ========================================================================
xDTaraZ.Delivery = {}

---@return "Plot"|"Direct"|"Drop", number  mode, trip studs
function xDTaraZ.Delivery.Mode(entry)
    local _, bp = xDTaraZ.Player:Plot()
    if not bp or not entry or not entry.pos then return "Drop", math.huge end

    local inside = xDTaraZ.Geo.EdgeInside(bp, entry.pos)
    if (inside - entry.pos).Magnitude <= xDTaraZ.Config.PickupReach then return "Plot", 0 end

    local trip = xDTaraZ.Geo.Trip(bp, xDTaraZ.Geo.StandPoint(bp, entry.pos))
    local opts = xDTaraZ.Options
    if opts and opts.DeliveryMode == "Safe" then return "Drop", trip end

    if xDTaraZ.Delivery.Fits(trip, entry.weight, entry.egg) then return "Direct", trip end
    return "Drop", trip
end

---@return number  carry speed left after the egg weight slowdown
function xDTaraZ.Delivery.WeightFactor(weight, eggName)
    local cfg = xDTaraZ.Config
    local over = math.max(0, (tonumber(weight) or 1) - 1)
    local per = eggName == "Cherub" and cfg.CherubWeightPenalty or cfg.WeightPenalty
    return 1 - math.min(cfg.WeightPenaltyMax, over * 10 * per)
end

---@param weight number|nil  carried egg weight, nil = light
---@return boolean           straight trip home passes with the pet ridden right now
function xDTaraZ.Delivery.Fits(trip, weight, eggName)
    local factor = xDTaraZ.Delivery.WeightFactor(weight, eggName)
    local speed = xDTaraZ.Mount.Speed()
    if speed > 0 then return trip <= xDTaraZ.State.Tune.DirectFactor * speed * factor end
    return trip <= xDTaraZ.Config.UnmountedDirect * factor
end

---@return boolean  true when the full time passed
function xDTaraZ.Delivery.Sleep(token, sec)
    if sec <= 0 then return true end
    local _, why = xDTaraZ.Tasks.Await(token, nil, sec)
    return why == "timeout"
end

---@return boolean, string
function xDTaraZ.Delivery.Pickup(token, guid, standPos)
    local cfg = xDTaraZ.Config
    local remote = xDTaraZ.GameLib.Remote("EggPickup")
    local hrp = xDTaraZ.Player.Root
    if not remote or not hrp then return false, "missing" end
    local flags = xDTaraZ.Player:Flags()

    if (hrp.Position - standPos).Magnitude > 1 then
        if not xDTaraZ.Tasks.Teleport(token, CFrame.new(standPos)) then return false, "aborted" end
        if not xDTaraZ.Delivery.Sleep(token, cfg.TpSettle) then return false, "aborted" end
    end

    local deadline = os.clock() + cfg.PickupTotalTimeout
    local retried = false
    repeat
        if not xDTaraZ.Tasks.Holds(token) or xDTaraZ.Guard.Tripped or xDTaraZ.Player:Flags() > flags then return false, "aborted" end
        xDTaraZ.EggIndex.Expect(guid)
        remote:FireServer(guid)
        local kind, text = xDTaraZ.EggIndex.WaitReply(guid, cfg.PickupReplyTimeout)

        if kind == "PickedUp" then return true, "ok" end
        if xDTaraZ.Player:BasketCount() > 0 then return true, "ok" end
        if kind == "BasketFull" then return false, "full" end
        if kind == "Gone" then
            xDTaraZ.EggIndex.MarkGone(guid)
            return false, "gone"
        end
        if kind == "Refused" then
            local distanceLag = tostring(text or ""):find("studs", 1, true) ~= nil
            if retried or not distanceLag or xDTaraZ.Player:Flags() > flags then return false, "refused" end
            retried = true
            if not xDTaraZ.Delivery.Sleep(token, cfg.PickupAckWait) then return false, "aborted" end
        end
    until os.clock() >= deadline
    return false, "timeout"
end

---@return boolean  only true on the server's Deposited reply
function xDTaraZ.Delivery.AwaitDeposit(token, timeout)
    local kind = xDTaraZ.EggIndex.WaitReply("*carry", timeout)
    return kind == "Deposited" and not xDTaraZ.Guard.Tripped
end

function xDTaraZ.Delivery.StepHome(token, bp)
    local hrp = xDTaraZ.Player.Root
    if not hrp then return false end
    xDTaraZ.EggIndex.Expect("*carry")
    return xDTaraZ.Tasks.Teleport(token, CFrame.new(xDTaraZ.Geo.EdgeInside(bp, hrp.Position)))
end

---@return table|nil  newest dropped entry for the carried egg
---@param before table  guids that existed before our drop
function xDTaraZ.Delivery.FindDrop(eggName, origin, since, before)
    local hrp = xDTaraZ.Player.Root
    local here = hrp and hrp.Position
    local byOrigin, nearest, nearestDist = nil, nil, math.huge

    for _, entry in pairs(xDTaraZ.EggIndex.Entries) do
        if not entry.dropEndsAt or entry.dropEndsAt < since then continue end
        if before[entry.guid or ""] then continue end
        if origin and entry.origin and xDTaraZ.Util.Flat(entry.origin, origin) < 1 then
            byOrigin = entry
            break
        end
        if entry.egg == eggName and here then
            local dist = xDTaraZ.Util.Flat(entry.pos, here)
            if dist < nearestDist then nearest, nearestDist = entry, dist end
        end
    end
    return byOrigin or nearest
end

---@return table|nil
function xDTaraZ.Delivery.Drop(token, eggName, origin)
    local cfg = xDTaraZ.Config
    local remote = xDTaraZ.GameLib.Remote("BasketDrop")
    if not remote then return nil end

    local before = {}
    for _, entry in pairs(xDTaraZ.EggIndex.Entries) do
        if entry.guid then before[entry.guid] = true end
    end
    local since = xDTaraZ.Util.ServerNow() - 0.5
    remote:FireServer()

    local drop
    xDTaraZ.Tasks.Await(token, function()
        drop = xDTaraZ.Delivery.FindDrop(eggName, origin, since, before)
        return drop ~= nil
    end, cfg.DropAppearTimeout)
    return drop
end

function xDTaraZ.Delivery.WaitLanded(token, drop)
    local landAt = drop.dropEndsAt + xDTaraZ.Config.DropEndsSlack
    local remaining = landAt - xDTaraZ.Util.ServerNow()
    if remaining ~= remaining or remaining > xDTaraZ.Config.DropLandMax then return false end
    local timeout = math.max(xDTaraZ.Config.DropAppearTimeout, remaining + 0.5)
    local ok = xDTaraZ.Tasks.Await(token, function() return xDTaraZ.Util.ServerNow() >= landAt end, timeout)
    return ok
end

function xDTaraZ.Delivery.RaiseSettle()
    local tune = xDTaraZ.State.Tune
    tune.DropSettle = math.min(tune.DropSettle + 0.05, xDTaraZ.Config.DropSettleMax)
    xDTaraZ.State.Stats.staleDrops += 1
end

function xDTaraZ.Delivery.LowerSettle()
    local tune = xDTaraZ.State.Tune
    local floor = math.max(xDTaraZ.Config.DropSettle, tonumber(xDTaraZ.Util.Opt("DropSettle")) or 0)
    tune.DropSettle = math.max(floor, tune.DropSettle - 0.01)
end

---@return number|nil  replicated break timer for the carried egg
function xDTaraZ.Delivery.BreakLeft()
    local left
    for _, egg in ipairs(xDTaraZ.Player:BasketItems()) do
        if egg:GetAttribute("Delivering") then continue end
        local at = tonumber(egg:GetAttribute("BreakAt"))
        if at then left = math.min(left or math.huge, at - xDTaraZ.Util.ServerNow()) end
    end
    return left
end

---@return boolean  one bounded hop followed by movement at the actual ride speed
function xDTaraZ.Delivery.TravelCarry(token, cf, eggName)
    local cfg = xDTaraZ.Config
    local root, speed = xDTaraZ.Player.Root, xDTaraZ.Mount.TravelSpeed()
    if not root or speed <= 0 or xDTaraZ.Player:BasketCount() == 0 then return false end
    if not token.returnHop then
        token.returnHop = true
        local delta = cf.Position - root.Position
        local hopLimit = math.min(cfg.ReturnHopMax, math.max(xDTaraZ.Mount.Speed(), cfg.UnmountedPlayerSpeed) * State.Tune.DirectFactor)
        local hop = math.min(hopLimit, math.max(0, delta.Magnitude - cfg.TravelStopDistance))
        if hop > 0 then
            if not xDTaraZ.Tasks.Teleport(token, CFrame.new(root.Position + delta.Unit * hop) * root.CFrame.Rotation) then return false end
            if not xDTaraZ.Delivery.Sleep(token, cfg.TpSettle) then return false end
        end
    end
    local timeout = (cf.Position - root.Position).Magnitude / speed + cfg.RunBudget
    token.budget = math.max(token.budget or 0, os.clock() + timeout)
    local expired = false
    local reached = xDTaraZ.Tasks.Travel(token, cf, xDTaraZ.Mount.TravelSpeed, timeout, {
        noClip = true, reach = cfg.TravelStopDistance,
        done = function()
            local left = xDTaraZ.Delivery.BreakLeft()
            expired = left ~= nil and left <= 0
            return expired or xDTaraZ.Player:BasketCount() == 0
        end,
    })
    return reached and not expired and xDTaraZ.Player:BasketCount() > 0
end

---@return "Deposited"|"Gone"|"Refused"|"Aborted"
function xDTaraZ.Delivery.DropCycle(token, bp, eggName, origin)
    local cfg = xDTaraZ.Config

    for _ = 0, 2 do
        local hrp = xDTaraZ.Player.Root
        if not hrp or os.clock() > token.budget then return "Aborted" end

        local out = xDTaraZ.Geo.Outside(bp, hrp.Position, cfg.DropOutside)
        if not xDTaraZ.Delivery.Fits(xDTaraZ.Geo.Trip(bp, hrp.Position), nil, eggName) then
            if not xDTaraZ.Delivery.TravelCarry(token, CFrame.new(out), eggName) then return "Aborted" end
        elseif not xDTaraZ.Tasks.Teleport(token, CFrame.new(out)) then
            return "Aborted"
        end
        if not xDTaraZ.Delivery.Sleep(token, xDTaraZ.State.Tune.DropSettle) then return "Aborted" end

        local drop = xDTaraZ.Delivery.Drop(token, eggName, origin)
        if not drop then return xDTaraZ.Player:BasketCount() == 0 and "Gone" or "Aborted" end
        origin = drop.origin or origin

        local fresh = xDTaraZ.Util.Flat(drop.pos, out) <= cfg.StaleDropDistance
        local stand = fresh and out or drop.pos + Vector3.new(0, xDTaraZ.Geo.Lift(), 0)
        if fresh then xDTaraZ.Delivery.LowerSettle() end
        if not fresh then
            xDTaraZ.Delivery.RaiseSettle()
            if not xDTaraZ.Tasks.Teleport(token, CFrame.new(stand)) then return "Aborted" end
        end
        if not xDTaraZ.Delivery.WaitLanded(token, drop) then return "Aborted" end

        local got, why = xDTaraZ.Delivery.Pickup(token, drop.guid, stand)
        if not got then return why == "gone" and "Gone" or "Aborted" end

        if fresh or xDTaraZ.Delivery.Fits(xDTaraZ.Geo.Trip(bp, stand), drop.weight, eggName) then
            if not xDTaraZ.Delivery.StepHome(token, bp) then return "Aborted" end
            return xDTaraZ.Delivery.AwaitDeposit(token, cfg.DepositTimeout) and "Deposited" or "Aborted"
        end
    end
    return "Aborted"
end

---@return "Deposited"|"Aborted"
function xDTaraZ.Delivery.DirectHome(token, bp)
    local cfg = xDTaraZ.Config
    if not xDTaraZ.Delivery.StepHome(token, bp) then return "Aborted" end
    if xDTaraZ.Delivery.AwaitDeposit(token, cfg.DepositTimeout) then return "Deposited" end
    if xDTaraZ.Player:BasketCount() > 0 and xDTaraZ.Player:Flags() <= token.flags0 then
        if xDTaraZ.Delivery.AwaitDeposit(token, cfg.DepositTimeout) then return "Deposited" end
    end
    return "Aborted"
end

---@return "Deposited"|"Gone"|"Refused"|"Aborted", number  outcome, seconds
function xDTaraZ.Delivery.Run(token, entry)
    local _, bp = xDTaraZ.Player:Plot()
    if not bp or not entry then return "Aborted", 0 end

    local t0 = os.clock()
    token.flags0 = xDTaraZ.Player:Flags()
    token.budget = t0 + xDTaraZ.Config.RunBudget

    local mode, trip = xDTaraZ.Delivery.Mode(entry)
    xDTaraZ.Delivery.LastPlan = { mode = mode, trip = math.floor(trip), speed = xDTaraZ.Mount.Speed(), settle = xDTaraZ.State.Tune.DirectFactor }
    local stand = mode == "Plot" and xDTaraZ.Geo.EdgeInside(bp, entry.pos) or xDTaraZ.Geo.StandPoint(bp, entry.pos)

    xDTaraZ.EggIndex.Expect("*carry")
    local got, why = xDTaraZ.Delivery.Pickup(token, entry.guid, stand)
    if not got then
        if why == "full" then xDTaraZ.Delivery.Recover(token) end
        return why == "gone" and "Gone" or (why == "refused" and "Refused" or "Aborted"), os.clock() - t0
    end

    xDTaraZ.Eggs.CarryCritical = true
    local outcome
    if mode == "Plot" then
        outcome = xDTaraZ.Delivery.AwaitDeposit(token, xDTaraZ.Config.DepositTimeout) and "Deposited" or "Aborted"
    elseif mode == "Direct" then
        outcome = xDTaraZ.Delivery.DirectHome(token, bp)
    else
        outcome = xDTaraZ.Delivery.DropCycle(token, bp, entry.egg, entry.origin or entry.pos)
    end

    if outcome ~= "Deposited" and xDTaraZ.Player:BasketCount() > 0 then xDTaraZ.Delivery.Recover(token) end
    xDTaraZ.Eggs.CarryCritical = false
    xDTaraZ.Guard.Check(token.flags0)

    local seconds = os.clock() - t0
    local stats = xDTaraZ.State.Stats
    if outcome == "Deposited" then
        local key = string.lower(mode)
        stats[key] = (stats[key] or 0) + 1
    end
    stats.lastRun, stats.lastMode = seconds, mode
    return outcome, seconds
end

---@return string|nil, string|nil  egg name, "Delivering"|"Carry"|"Unknown"
function xDTaraZ.Delivery.Carried()
    local items = xDTaraZ.Player:BasketItems()
    local first = items[1]
    if not first then return nil, nil end
    if first:GetAttribute("Delivering") == true then return first:GetAttribute("Egg"), "Delivering" end
    if first:GetAttribute("BreakAt") then return first:GetAttribute("Egg"), "Carry" end
    return first:GetAttribute("Egg"), "Unknown"
end

---@return boolean  deposited after stepping out of the plot and back in
function xDTaraZ.Delivery.Reenter(token, bp, hrp)
    local cfg = xDTaraZ.Config
    local out = xDTaraZ.Geo.Outside(bp, hrp.Position, cfg.DropOutside)
    if not xDTaraZ.Tasks.Teleport(token, CFrame.new(out)) then return false end
    if not xDTaraZ.Delivery.Sleep(token, cfg.TpSettle) then return false end
    if not xDTaraZ.Delivery.StepHome(token, bp) then return false end
    return xDTaraZ.Delivery.AwaitDeposit(token, cfg.DepositTimeout)
end

---@return boolean  basket empty afterwards
function xDTaraZ.Delivery.Recover(token)
    local eggName, phase = xDTaraZ.Delivery.Carried()
    if not phase then return true, "Empty" end

    local cfg = xDTaraZ.Config
    token.flags0 = token.flags0 or xDTaraZ.Player:Flags()
    token.budget = math.max(token.budget or 0, os.clock() + cfg.RunBudget)

    if phase ~= "Carry" then
        xDTaraZ.Tasks.Await(token, function() return xDTaraZ.Player:BasketCount() == 0 end, cfg.DepositTimeout)
        return xDTaraZ.Player:BasketCount() == 0, "Settled"
    end

    local _, bp = xDTaraZ.Player:Plot()
    local hrp = xDTaraZ.Player.Root
    if not bp or not hrp then return false end

    local wasCritical = xDTaraZ.Eggs.CarryCritical
    xDTaraZ.Eggs.CarryCritical = true

-- ========================================================================
-- PLANNER + EGGS: select target eggs and run collection loop
-- ========================================================================
xDTaraZ.Planner = {
    Ranked = {}, Contested = {},
    Dirty = true, BuiltAt = 0, Epoch = -1, MountName = nil,
    RebuildGap = 0.5, MaxAge = 2, ContestStep = 0.25,
    Started = false,
}

---@return number  studs per second this player can close on an egg
function xDTaraZ.Planner.PlayerSpeed(player, char)
    if player:GetAttribute("IsRiding") ~= true then return Config.UnmountedPlayerSpeed end
    for _, child in ipairs(char:GetChildren()) do
        local pet = GameLib.PetInfo[child.Name]
        if pet and pet.speed then return pet.speed end
    end
    return Config.UnmountedPlayerSpeed
end

---@return table  { {pos, speed} } of every other player with a body
function xDTaraZ.Planner.Riders()
    local riders = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        riders[#riders + 1] = { hrp.Position, xDTaraZ.Planner.PlayerSpeed(player, char) }
    end
    return riders
end

---@param riders table?  from Planner.Riders, built when nil
---@return number        0..1, 1 = someone is on it now
function xDTaraZ.Planner.Contest(entry, riders)
    if not entry.pos then return 0 end
    local best = 0
    for _, rider in ipairs(riders or xDTaraZ.Planner.Riders()) do
        local eta = xDTaraZ.Util.Flat(rider[1], entry.pos) / math.max(rider[2], 1)
        best = math.max(best, math.clamp(1 - eta / Config.ContestHorizon, 0, 1))
    end
    return best
end

---@return number, string, number  score, delivery mode, contest
function xDTaraZ.Planner.Score(entry, riders)
    local mode, trip = xDTaraZ.Delivery.Mode(entry)
    local contest = xDTaraZ.Planner.Contest(entry, riders)
    local cost = Config.TripCost[mode] or Config.TripCost.Drop
    if mode == "Drop" then
        local hum = xDTaraZ.Player.Humanoid
        local speed = math.min(math.max(xDTaraZ.Mount.Speed(), Config.UnmountedPlayerSpeed), hum and hum.WalkSpeed or 0) * 0.9
        cost += trip / math.max(speed, 1)
    end
    local score = (entry.value or 0) * (1 + contest * State.Tune.ContestWeight) / cost
    return score, mode, contest
end

function xDTaraZ.Planner.Rebuild()
    local planner = xDTaraZ.Planner
    local riders = planner.Riders()
    local ranked = planner.Ranked
    table.clear(ranked)

    for _, entry in pairs(xDTaraZ.EggIndex.Entries) do
        if not entry.pos or not entry.egg then continue end
        if entry.privateTo and entry.privateTo ~= LocalPlayer.UserId then continue end
        local score, mode, contest = planner.Score(entry, riders)
        table.insert(ranked, { entry, mode, contest, score })
    end
    table.sort(ranked, function(a, b) return a[4] > b[4] end)

    planner.Dirty, planner.BuiltAt = false, os.clock()
    planner.Epoch = xDTaraZ.EggIndex.ValueEpoch
    planner.MountName = xDTaraZ.Mount.Name
end

---@return boolean  ranking is stale
function xDTaraZ.Planner.Stale()
    local planner = xDTaraZ.Planner
    local age = os.clock() - planner.BuiltAt
    if planner.Epoch ~= xDTaraZ.EggIndex.ValueEpoch or planner.MountName ~= xDTaraZ.Mount.Name then return true end
    if age > planner.MaxAge then return true end
    if not planner.Dirty then return false end

    local surging = os.clock() - xDTaraZ.EggIndex.RolledAt <= Config.WaveSurge
    return surging or age >= planner.RebuildGap
end

---@param minRank number?  hunter-only: rarity rank floor, user filters skipped
---@return table?, string?  entry, planned mode
function xDTaraZ.Planner.Next(minRank)
    local planner = xDTaraZ.Planner
    if planner.Stale() then planner.Rebuild() end

    for _, pick in ipairs(planner.Ranked) do
        local entry = pick[1]
        if not minRank and xDTaraZ.Util.Opt("EggRoute") == "Fast nearby" and pick[2] == "Drop" then continue end
        if minRank then
            local info = GameLib.EggInfo[entry.egg]
            if not info or (GameLib.RarityRank[info.rarity] or 0) < minRank then continue end
        end
        if xDTaraZ.EggIndex.Wanted(entry, minRank ~= nil) then
            planner.Contested[entry.guid] = pick[3]
            return entry, pick[2]
        end
    end
    return nil
end

function xDTaraZ.Planner.OnReply(kind, guid)
    local planner = xDTaraZ.Planner
    if kind ~= "Gone" or not guid then return end
    local contest = planner.Contested[guid]
    planner.Contested[guid] = nil
    if not contest or contest <= 0 then return end

    local tune = State.Tune
    local before = tune.ContestWeight
    tune.ContestWeight = math.min(Config.ContestWeightMax, before + planner.ContestStep)
    if tune.ContestWeight == before then return end

    State.TuneLog = State.TuneLog or {}
    table.insert(State.TuneLog, { "ContestWeight", before, tune.Co
