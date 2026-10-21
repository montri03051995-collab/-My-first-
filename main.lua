-- biz-tools/boards.luau | Luau | executor
local Players = game:GetService("Players")
local LP = Players.LocalPlayer

local function scan(boardName)
    local board = workspace:FindFirstChild(boardName)
    if not board then return warn("[BZ] not found: "..boardName) end
    local out = {}
    for _, d in ipairs(board:GetDescendants()) do
        -- ป้ายสกอร์ Roblox ทั่วไป: SurfaceGui > TextLabel
        if d:IsA("TextLabel") then
            table.insert(out, d.Text)
        elseif d:IsA("ModuleScript") then
            local ok, data = pcall(function() return require(d) end)
            if ok and type(data) == "table" then
                table.insert(out, data)
            end
        elseif d:IsA("Script") then
            out[#out+1] = "[server script: "..d.Name.."]"
        end
    end
    return out
end

local function printBoard(name)
    local data = scan(name)
    if not data then return end
    print("══════ "..name.." ══════")
    for i, v in ipairs(data) do
        print(i..". "..tostring(v))
    end
end

printBoard("TopXPBoard")
printBoard("TopKills")

-- ⚡ Force leaderboard local: ปลอมค่าบน UI เราฝั่ง client (บางเกมอ่านช้า)
local function fakeTop(level, xp)
    local bb = LP:FindFirstChild("leaderstats")
    if bb then
        if bb:FindFirstChild("Level") then bb.Level.Value = level end
        if bb:FindFirstChild("XP") then bb.XP.Value = xp end
    end
end
fakeTop(999, 999999)

-- biz-tools/aim.luau | Luau | executor
local UIS = game:GetService("UserInputService")
local Run = game:GetService("RunService")
local Plrs = game:GetService("Players")
local cam = workspace.CurrentCamera
local LP = Plrs.LocalPlayer

local CFG = {
    aimKey   = Enum.UserInputType.MouseButton2, -- กดขวาค้าง
    bone     = "Head",                          -- Head หรือ UpperTorso
    fov      = 250,
    noRecoil = true,
    beamLock = true,                            -- ล็อก Bullet/Beam ไปหาศัตรู
}

local function enemies()
    local t = {}
    for _, p in ipairs(Plrs:GetPlayers()) do
        if p ~= LP and p.Character then
            local h = p.Character:FindFirstChild("Humanoid")
            local r = p.Character:FindFirstChild("HumanoidRootPart")
            if h and r and h.Health > 0 then table.insert(t, p) end
        end
    end
    return t
end

local function nearestBone()
    local best, bestD = nil, CFG.fov
    local mouse = UIS:GetMouseLocation()
    for _, p in ipairs(enemies()) do
        local b = p.Character:FindFirstChild(CFG.bone) or p.Character:FindFirstChild("HumanoidRootPart")
        if b then
            local sp, on = cam:WorldToViewportPoint(b.Position)
            local d = (Vector2.new(sp.X, sp.Y) - mouse).Magnitude
            if on and d < bestD then best, bestD = b, d end
        end
    end
    return best
end

local aiming = false
UIS.InputBegan:Connect(function(i)
    if i.UserInputType == CFG.aimKey then aiming = true end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType == CFG.aimKey then aiming = false end
end)

-- ดึงปืนที่ตัวละครถือ (Tool)
local function gun()
    local ch = LP.Character
    return ch and ch:FindFirstChildOfClass("Tool")
end

Run.RenderStepped:Connect(function()
    -- AIMBOT
    if aiming then
        local b = nearestBone()
        if b then cam.CFrame = CFrame.lookAt(cam.CFrame.Position, b.Position) end
    end

    -- NO RECOIL: คืนค่า CurrentCamera recoil ของอาวุธ Roblox
    if CFG.noRecoil then
        local u = LP:FindFirstChild("PlayerGui")
        if u then
            -- หลายเกมเก็บ recoil ใน Tool module — รีเซ็ตค่า pitches
            for _, d in ipairs(LP.Character and LP.Character:GetDescendants() or {}) do
                if d:IsA("ModuleScript") and d.Name:lower():find("recoil") then
                    -- module แชร์กับ server ห้าม require ซ้ำ — ข้าม
                end
            end
        end
    end

    -- BEAM LOCK: กระสุน/ลำแสงเปลี่ยนปลายทางกลางทาง
    if CFG.beamLock then
        local target = nearestBone()
        if target then
            for _, b in ipairs(workspace:GetDescendants()) do
                if (b:IsA("Beam") or b:IsA("Part")) and b.Name == "Bullet" then
                    pcall(function()
                        b.CFrame = CFrame.lookAt(b.Position, target.Position)
                    end)
                    if b:IsA("Beam") then
                        pcall(function() b.Attachment0.WorldPosition = target.Position end)
                    end
                end
            end
        end
    end
end)

-- biz-tools/houseESP.luau | Luau | executor
local Plrs = game:GetService("Players")
local Run = game:GetService("RunService")
local cam = workspace.CurrentCamera
local LP = Plrs.LocalPlayer

local labels = {}

local COLORS = {
    door   = Color3.fromRGB(255, 200, 60),
    item   = Color3.fromRGB(60, 255, 120),
    prompt = Color3.fromRGB(90, 160, 255),
    player = Color3.fromRGB(255, 70, 70),
}

local function watch(inst, tag, color)
    if labels[inst] then return end
    local sg = Instance.new("SurfaceGui")
    sg.Name = "BZ_TAG"
    sg.AlwaysOnTop = true
    sg.Face = Enum.NormalId.Front
    local tl = Instance.new("TextLabel")
    tl.Size = UDim2.fromScale(1, 0.3)
    tl.Position = UDim2.fromScale(0, 0)
    tl.BackgroundTransparency = 1
    tl.TextScaled = true
    tl.Font = Enum.Font.GothamBold
    tl.TextColor3 = color
    tl.TextStrokeTransparency = 0.2
    tl.Text = tag
    tl.Parent = sg
    sg.Parent = inst
    labels[inst] = sg
end

local function scan()
    for _, d in ipairs(workspace:GetDescendants()) do
        -- ประตูบ้าน
        if d.Name == "IsOpen" and d:IsA("BoolValue") and d.Parent then
            local p = d.Parent:FindFirstChildWhichIsA("BasePart", true)
            if p then watch(p, d.Parent.Name.." [DOOR]", COLORS.door) end
        end
        -- จุดกด gamepass/ของดี
        if d:IsA("ProximityPrompt") and d:FindFirstChildOfClass("Attachment") == nil
            and (d.Parent and (d.Parent.Name == "Alt" or d.Parent.Name == "TouchPart")) then
            local p = d.Parent
            if p and p:IsA("BasePart") then watch(p, d.Parent.Name.." [BUY]", COLORS.prompt) end
        end
        -- ปืน
        if d:IsA("Model") and (d.Name == "AR" or d.Name == "Sniper" or d.Name == "RocketLauncher") then
            local m = d:FindFirstChildWhichIsA("BasePart", true)
            if m then watch(m, d.Name.." [GUN]", COLORS.item) end
        end
        -- Feedback NPC
        if d:IsA("ProximityPrompt") and d:FindFirstChild("Script") then
            local p = d.Parent
            if p and p:IsA("BasePart") then watch(p, "NPC: "..p.Name, COLORS.prompt) end
        end
    end
end

local function players()
    for _, pl in ipairs(Plrs:GetPlayers()) do
        if pl ~= LP and pl.Character then
            watch(pl.Character:FindFirstChild("HumanoidRootPart"), pl.Name, COLORS.player)
        end
    end
end

scan(); players()
Run.Heartbeat:Connect(function()
    if tick() % 3 < 0.05 then scan(); players() end
    cam.FieldOfView = 70
end)
print("[BZ] house ESP loaded · "..#labels.." tags")

-- biz-tools/jump.luau | Luau | executor
local UIS = game:GetService("UserInputService")
local Plrs = game:GetService("Players")
local LP = Plrs.LocalPlayer
local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
local hrp = LP.Character and LP:Character:FindFirstChild("HumanoidRootPart")

-- JumpPad ทุกอัน: boost แรงขึ้น
for _, p in ipairs(workspace:GetDescendants()) do
    if p.Name == "JumpPad" then
        local v = p:FindFirstChild("NumberValue")
        if v then v.Value = v.Value * 3 end
        p.Touched:Connect(function(hit)
            if hit.Parent == LP.Character then
                pcall(function() hit.Parent.HumanoidRootPart.Velocity = Vector3.new(0, 180, 0) end)
            end
        end)
    end
end

-- Double Jump ไม่ต้องซื้อ PASS
local jumps, maxJumps = 0, 2
local moving = false
UIS.JumpRequest:Connect(function()
    if not hum then return end
    if jumps < maxJumps then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
        jumps += 1
    end
end)
LP.CharacterAdded:Connect(function(c)
    hum = c:WaitForChild("Humanoid")
    hrp = c:WaitForChild("HumanoidRootPart")
    jumps = 0
end)
if hum then
    hum.StateChanged:Connect(function(_, n)
        if n == Enum.HumanoidStateType.Landed then jumps = 0 end
    end)
end

-- Fly (กด F)
local fly = false
UIS.InputBegan:Connect(function(i, g)
    if g then return end
    if i.KeyCode == Enum.KeyCode.F then fly = not fly end
end)
game:GetService("RunService").RenderStepped:Connect(function()
    if not fly or not hrp then return end
    local dir = Vector3.new()
    if UIS:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
    if UIS:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
    if UIS:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
    if UIS:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
    if UIS:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.yAxis end
    if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.yAxis end
    hrp.Velocity = dir * 90
end)

-- biz-tools/morph.luau | Luau | executor
local Plrs = game:GetService("Players")
local LP = Plrs.LocalPlayer

local function morphFrom(prompt)
    local cache = prompt:FindFirstChild("CachedCharacter")
    if not cache then return warn("[BZ] no cache: "..prompt:GetFullName()) end
    -- Prompt ฝั่ง client เก็บโมเดลไว้แล้ว — spawn ตรง
    local clone = cache:Clone()
    local ch = LP.Character
    if not ch then return end
    -- สลับร่าง: ย้ายชิ้นส่วนใหม่เข้าตัวเรา
    for _, p in ipairs(clone:GetDescendants()) do
        if p:IsA("BasePart") then p.Anchored = false end
    end
    clone:PivotTo(ch:GetPivot())
    clone.Parent = workspace
    task.wait(0.2)
    local hum = ch:FindFirstChildOfClass("Humanoid")
    if hum then hum.RequiresNeck = false end
    ch:Destroy()
    clone.Name = LP.Name
    local h = Instance.new("Humanoid"); h.Parent = clone
    LP.Character = clone
    -- hook Humanoid เดิม
    local cam = workspace.CurrentCamera
    cam.CameraSubject = h
    print("[BZ] morphed: "..prompt.Name)
end

for _, pr in ipairs(workspace:GetDescendants()) do
    if pr:IsA("ProximityPrompt") and pr:FindFirstChild("CachedCharacter") then
        pcall(function() pr:HoldBegin() end)
        task.wait(0.1)
        morphFrom(pr)
    end
end
print("[BZ] morph scan done")

-- biz-tools/all.luau | Luau | paste ทีเดียวจบ
local ROOT = "biz-tools/"
for _, m in ipairs({"init","boards","aim","houseESP","jump","morph"}) do
    local ok, src = pcall(readfile, ROOT..m..".luau")
    if ok then
        local f, err = load(src, "@biz/"..m)
        if f then
            local ok2, e = pcall(f)
            print(("[%s] %s"):format(m, ok2 and "OK" or tostring(e)))
        end
    else
        warn("[BZ] missing "..m..".luau")
    end
end
