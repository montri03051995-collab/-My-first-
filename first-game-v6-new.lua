
-- FIRST GAME | RGB UI V6
-- สำหรับเกม Roblox ที่คุณสร้างเอง
-- วางใน StarterPlayer > StarterPlayerScripts > LocalScript

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ลบ UI เก่า
local old = playerGui:FindFirstChild("FirstGameUI")
if old then old:Destroy() end

local HEIGHT_MIN, HEIGHT_MAX = 0, 100
local SPEED_MIN, SPEED_MAX = 2, 100

local height = 10
local speed = 12
local floatEnabled = false
local minimized = false
local baseY = 0

local connections = {}
local function connect(signal, callback)
    local c = signal:Connect(callback)
    table.insert(connections, c)
    return c
end

local function make(className, props, parent)
    local obj = Instance.new(className)
    for k, v in pairs(props) do
        obj[k] = v
    end
    obj.Parent = parent
    return obj
end

local function corner(obj, radius)
    make("UICorner", {
        CornerRadius = UDim.new(0, radius or 8)
    }, obj)
end

local function label(parent, text, pos, size, textSize)
    return make("TextLabel", {
        Position = pos,
        Size = size,
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Color3.fromRGB(240, 250, 255),
        TextSize = textSize or 14,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
    }, parent)
end

local function button(parent, text, pos, size)
    local b = make("TextButton", {
        Position = pos,
        Size = size,
        BackgroundColor3 = Color3.fromRGB(23, 43, 68),
        Text = text,
        TextColor3 = Color3.fromRGB(240, 250, 255),
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        BorderSizePixel = 0,
        Active = true,
        AutoButtonColor = true,
    }, parent)
    corner(b, 8)
    return b
end

-- UI
local gui = make("ScreenGui", {
    Name = "FirstGameUI",
    ResetOnSpawn = false,
    DisplayOrder = 100,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, playerGui)

local panel = make("Frame", {
    Name = "Window",
    Size = UDim2.fromOffset(340, 360),
    Position = UDim2.new(0, 12, 0.18, 0),
    BackgroundColor3 = Color3.fromRGB(7, 13, 29),
    BorderSizePixel = 0,
    Active = true,
    ClipsDescendants = true,
}, gui)
corner(panel, 12)

local outline = make("UIStroke", {
    Color = Color3.fromRGB(0, 255, 255),
    Thickness = 2,
}, panel)

local header = make("Frame", {
    Size = UDim2.new(1, 0, 0, 44),
    BackgroundColor3 = Color3.fromRGB(12, 24, 46),
    BorderSizePixel = 0,
    Active = true,
}, panel)

local title = label(
    header, "FIRST GAME | RGB V6",
    UDim2.fromOffset(10, 0),
    UDim2.new(1, -100, 1, 0), 14
)
title.Font = Enum.Font.GothamBold
title.Active = false

local minimizeBtn = button(
    header, "−",
    UDim2.new(1, -78, 0, 8),
    UDim2.fromOffset(32, 28)
)

local hideBtn = button(
    header, "×",
    UDim2.new(1, -40, 0, 8),
    UDim2.fromOffset(32, 28)
)

local body = make("Frame", {
    Position = UDim2.fromOffset(7, 50),
    Size = UDim2.new(1, -14, 1, -57),
    BackgroundTransparency = 1,
}, panel)

local menu = make("Frame", {
    Size = UDim2.new(0, 100, 1, 0),
    BackgroundColor3 = Color3.fromRGB(9, 19, 37),
    BorderSizePixel = 0,
}, body)
corner(menu, 8)

local pages = make("Frame", {
    Position = UDim2.fromOffset(107, 0),
    Size = UDim2.new(1, -107, 1, 0),
    BackgroundTransparency = 1,
}, body)

local function newPage(name)
    return make("Frame", {
        Name = name,
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Visible = false,
    }, pages)
end

local floatPage = newPage("Float")
local speedPage = newPage("Speed")
local settingsPage = newPage("Settings")

local tabFloat = button(menu, "FLOAT", UDim2.fromOffset(6, 10),
    UDim2.new(1, -12, 0, 38))
local tabSpeed = button(menu, "SPEED", UDim2.fromOffset(6, 54),
    UDim2.new(1, -12, 0, 38))
local tabSettings = button(menu, "SETTINGS", UDim2.fromOffset(6, 98),
    UDim2.new(1, -12, 0, 38))

label(menu, "RGB NEON", UDim2.fromOffset(8, 150),
    UDim2.new(1, -16, 0, 24), 11).TextColor3 =
    Color3.fromRGB(145, 170, 195)

-- FLOAT page
local floatTitle = label(floatPage, "FLOAT CONTROL",
    UDim2.fromOffset(8, 5), UDim2.new(1, -16, 0, 25), 15)

local floatBtn = button(floatPage, "FLOAT: OFF",
    UDim2.fromOffset(8, 38), UDim2.new(1, -16, 0, 38))
floatBtn.BackgroundColor3 = Color3.fromRGB(110, 35, 50)

local floatStatus = label(floatPage, "Status: OFF",
    UDim2.fromOffset(8, 80), UDim2.new(1, -16, 0, 24), 12)

label(floatPage, "HEIGHT: 0 - 100 studs",
    UDim2.fromOffset(8, 112), UDim2.new(1, -16, 0, 22), 12)

local heightValue = label(floatPage, "Height: " .. height,
    UDim2.fromOffset(8, 136), UDim2.new(1, -16, 0, 22), 13)

local heightTrack = make("Frame", {
    Position = UDim2.fromOffset(8, 166),
    Size = UDim2.new(1, -16, 0, 14),
    BackgroundColor3 = Color3.fromRGB(23, 43, 68),
    BorderSizePixel = 0,
    Active = true,
}, floatPage)
corner(heightTrack, 7)

local heightFill = make("Frame", {
    Size = UDim2.new(height / HEIGHT_MAX, 0, 1, 0),
    BackgroundColor3 = Color3.fromRGB(0, 255, 255),
    BorderSizePixel = 0,
}, heightTrack)
corner(heightFill, 7)

local heightMinus = button(floatPage, "- 5",
    UDim2.fromOffset(8, 192), UDim2.fromOffset(55, 32))
local heightPlus = button(floatPage, "+ 5",
    UDim2.fromOffset(70, 192), UDim2.fromOffset(55, 32))

label(floatPage, "เลื่อนแถบเพื่อปรับระดับลอย",
    UDim2.fromOffset(8, 238), UDim2.new(1, -16, 0, 34), 11)

-- SPEED page
local speedTitle = label(speedPage, "SPEED CONTROL",
    UDim2.fromOffset(8, 5), UDim2.new(1, -16, 0, 25), 15)

local speedValue = label(speedPage, "Speed: " .. speed,
    UDim2.fromOffset(8, 38), UDim2.new(1, -16, 0, 25), 14)

local speedMinus = button(speedPage, "- 2",
    UDim2.fromOffset(8, 78), UDim2.new(0.5, -12, 0, 36))
local speedPlus = button(speedPage, "+ 2",
    UDim2.new(0.5, 4, 0, 78), UDim2.new(0.5, -12, 0, 36))

local speedTrack = make("Frame", {
    Position = UDim2.fromOffset(8, 132),
    Size = UDim2.new(1, -16, 0, 14),
    BackgroundColor3 = Color3.fromRGB(23, 43, 68),
    BorderSizePixel = 0,
    Active = true,
}, speedPage)
corner(speedTrack, 7)

local speedFill = make("Frame", {
    Size = UDim2.new((speed - SPEED_MIN) /
        (SPEED_MAX - SPEED_MIN), 0, 1, 0),
    BackgroundColor3 = Color3.fromRGB(0, 255, 255),
    BorderSizePixel = 0,
}, speedTrack)
corner(speedFill, 7)

label(speedPage, "ปรับความเร็วแนวราบ",
    UDim2.fromOffset(8, 158), UDim2.new(1, -16, 0, 30), 11)

-- SETTINGS page
local settingsTitle = label(settingsPage, "SETTINGS",
    UDim2.fromOffset(8, 5), UDim2.new(1, -16, 0, 25), 15)

label(settingsPage,
    "FIRST GAME UI\n\nลากแถบหัวข้อเพื่อย้ายหน้าต่าง\n− ย่อหน้าต่าง\n× ซ่อนหน้าต่าง\nMF เปิดหน้าต่างกลับ",
    UDim2.fromOffset(8, 40), UDim2.new(1, -16, 0, 150), 12)

-- MF reopen button
local ball = button(gui, "MF",
    UDim2.new(0.82, 0, 0.55, 0),
    UDim2.fromOffset(58, 58))
ball.AnchorPoint = Vector2.new(0.5, 0.5)
ball.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
ball.TextColor3 = Color3.fromRGB(7, 13, 29)
ball.TextSize = 18
ball.Visible = false
corner(ball, 29)

local ballStroke = make("UIStroke", {
    Color = Color3.new(1, 1, 1),
    Thickness = 2,
}, ball)

-- Character / floating control
local floatAttachment
local floatVelocity
local heartbeatConnection
local characterConnection

local function getCharacterParts()
    local character = player.Character
    if not character then return nil, nil end

    local root = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    return root, humanoid
end

local function stopFloat()
    floatEnabled = false

    if heartbeatConnection then
        heartbeatConnection:Disconnect()
        heartbeatConnection = nil
    end

    if floatVelocity then
        floatVelocity:Destroy()
        floatVelocity = nil
    end

    if floatAttachment then
        floatAttachment:Destroy()
        floatAttachment = nil
    end

    floatBtn.Text = "FLOAT: OFF"
    floatBtn.BackgroundColor3 = Color3.fromRGB(110, 35, 50)
    floatStatus.Text = "Status: OFF"
end

local function startFloat()
    local root, humanoid = getCharacterParts()
    if not root or not humanoid or humanoid.Health <= 0 then
        floatStatus.Text = "Status: character not ready"
        return
    end

    stopFloat()

    root, humanoid = getCharacterParts()
    if not root or not humanoid then return end

    baseY = root.Position.Y
    floatAttachment = Instance.new("Attachment")
    floatAttachment.Name = "FirstGameFloatAttachment"
    floatAttachment.Parent = root

    floatVelocity = Instance.new("LinearVelocity")
    floatVelocity.Name = "FirstGameFloatVelocity"
    floatVelocity.Attachment0 = floatAttachment
    floatVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
    floatVelocity.VelocityConstraintMode =
        Enum.VelocityConstraintMode.Vector
    floatVelocity.ForceLimitsEnabled = false
    floatVelocity.VectorVelocity = Vector3.zero
    floatVelocity.Parent = root

    floatEnabled = true
    floatBtn.Text = "FLOAT: ON"
    floatBtn.BackgroundColor3 = Color3.fromRGB(0, 145, 105)
    floatStatus.Text = "Status: FLOATING"

    heartbeatConnection = RunService.Heartbeat:Connect(function()
        if not floatEnabled then return end

        local currentRoot, currentHumanoid = getCharacterParts()
        if not currentRoot or not currentHumanoid
            or currentHumanoid.Health <= 0 then
            stopFloat()
            return
        end

        if not floatVelocity or not floatVelocity.Parent then
            stopFloat()
            return
        end

        local targetY = baseY + height
        local difference = targetY - currentRoot.Position.Y

        -- คุมระดับขึ้น/ลง และเคลื่อนที่ตามทิศทางเดิน
        local verticalSpeed = math.clamp(difference * 3, -25, 25)
        local move = currentHumanoid.MoveDirection
        floatVelocity.VectorVelocity = Vector3.new(
            move.X * speed,
            verticalSpeed,
            move.Z * speed
        )
    end)
end

connect(floatBtn.Activated, function()
    if floatEnabled then
        stopFloat()
    else
        startFloat()
    end
end)

-- Height slider
local heightDragging = false
local speedDragging = false
local activeSlider = nil

local function setHeight(value)
    height = math.clamp(math.floor(value + 0.5),
        HEIGHT_MIN, HEIGHT_MAX)

    heightValue.Text = "Height: " .. height
    heightFill.Size = UDim2.new(height / HEIGHT_MAX, 0, 1, 0)
end

local function setSpeed(value)
    speed = math.clamp(math.floor(value + 0.5),
        SPEED_MIN, SPEED_MAX)

    speedValue.Text = "Speed: " .. speed
    speedFill.Size = UDim2.new(
        (speed - SPEED_MIN) / (SPEED_MAX - SPEED_MIN), 0, 1, 0)
end

local function updateSlider(track, input, minValue, maxValue, setter)
    local width = track.AbsoluteSize.X
    if width <= 0 then return end

    local ratio = math.clamp(
        (input.Position.X - track.AbsolutePosition.X) / width,
        0, 1
    )
    setter(minValue + ratio * (maxValue - minValue))
end

local function beginSlider(track, input, kind)
    if input.UserInputType ~= Enum.UserInputType.Touch
        and input.UserInputType ~= Enum.UserInputType.MouseButton1 then
        return
    end

    activeSlider = {
        track = track,
        input = input,
        kind = kind,
        inputType = input.UserInputType,
    }

    if kind == "height" then
        updateSlider(track, input, HEIGHT_MIN, HEIGHT_MAX, setHeight)
    else
        updateSlider(track, input, SPEED_MIN, SPEED_MAX, setSpeed)
    end
end

connect(heightTrack.InputBegan, function(input)
    beginSlider(heightTrack, input, "height")
end)

connect(speedTrack.InputBegan, function(input)
    beginSlider(speedTrack, input, "speed")
end)

connect(UIS.InputChanged, function(input)
    if not activeSlider then return end

    local isTouch = activeSlider.inputType == Enum.UserInputType.Touch
    local valid = isTouch
        and input.UserInputType == Enum.UserInputType.Touch
        or (not isTouch
            and input.UserInputType == Enum.UserInputType.MouseMovement)

    if not valid then return end

    local track = activeSlider.track
    if activeSlider.kind == "height" then
        updateSlider(track, input, HEIGHT_MIN, HEIGHT_MAX, setHeight)
    else
        updateSlider(track, input, SPEED_MIN, SPEED_MAX, setSpeed)
    end
end)

connect(UIS.InputEnded, function(input)
    if not activeSlider then return end

    if input == activeSlider.input
        or input.UserInputType == Enum.UserInputType.MouseButton1 then
        activeSlider = nil
    end
end)

connect(heightMinus.Activated, function()
    setHeight(height - 5)
end)

connect(heightPlus.Activated, function()
    setHeight(height + 5)
end)

connect(speedMinus.Activated, function()
    setSpeed(speed - 2)
end)

connect(speedPlus.Activated, function()
    setSpeed(speed + 2)
end)

-- Tabs
local function selectTab(name)
    floatPage.Visible = name == "FLOAT"
    speedPage.Visible = name == "SPEED"
    settingsPage.Visible = name == "SETTINGS"

    local tabs = {
        {tabFloat, "FLOAT"},
        {tabSpeed, "SPEED"},
        {tabSettings, "SETTINGS"},
    }

    for _, item in ipairs(tabs) do
        local selected = item[2] == name
        item[1].BackgroundColor3 = selected
            and Color3.fromRGB(240, 250, 255)
            or Color3.fromRGB(23, 43, 68)
        item[1].TextColor3 = selected
            and Color3.fromRGB(7, 13, 29)
            or Color3.fromRGB(240, 250, 255)
    end
end

connect(tabFloat.Activated, function()
    selectTab("FLOAT")
end)

connect(tabSpeed.Activated, function()
    selectTab("SPEED")
end)

connect(tabSettings.Activated, function()
    selectTab("SETTINGS")
end)

-- Minimize / hide / reopen
connect(minimizeBtn.Activated, function()
    minimized = not minimized
    body.Visible = not minimized
    panel.Size = minimized
        and UDim2.fromOffset(340, 44)
        or UDim2.fromOffset(340, 360)
    minimizeBtn.Text = minimized and "+" or "−"
end)

connect(hideBtn.Activated, function()
    panel.Visible = false
    ball.Visible = true
end)

connect(ball.Activated, function()
    panel.Visible = true
    ball.Visible = false
    minimized = false
    body.Visible = true
    panel.Size = UDim2.fromOffset(340, 360)
    minimizeBtn.Text = "−"
end)

-- Drag window using header
do
    local dragging = false
    local activeInput
    local startPoint
    local startPosition

    connect(header.InputBegan, function(input)
        local kind = input.UserInputType
        if kind ~= Enum.UserInputType.Touch
            and kind ~= Enum.UserInputType.MouseButton1 then
            return
        end

        local x, y = input.Position.X, input.Position.Y

        local function inside(obj)
            local p, s = obj.AbsolutePosition, obj.AbsoluteSize
            return x >= p.X and x <= p.X + s.X
                and y >= p.Y and y <= p.Y + s.Y
        end

        if inside(minimizeBtn) or inside(hideBtn) then return end

        dragging = true
        activeInput = input
        startPoint = Vector2.new(x, y)
        startPosition = panel.AbsolutePosition
    end)

    connect(UIS.InputChanged, function(input)
        if not dragging or not activeInput then return end

        local isTouch = activeInput.UserInputType == Enum.UserInputType.Touch
        if isTouch then
            if input ~= activeInput then return end
        elseif input.UserInputType ~= Enum.UserInputType.MouseMovement then
            return
        end

        local delta = Vector2.new(
            input.Position.X, input.Position.Y) - startPoint

        local camera = workspace.CurrentCamera
        if not camera then return end

        local view = camera.ViewportSize
        local size = panel.AbsoluteSize
        local x = math.clamp(startPosition.X + delta.X,
            0, math.max(0, view.X - size.X))
        local y = math.clamp(startPosition.Y + delta.Y,
            0, math.max(0, view.Y - size.Y))

        panel.Position = UDim2.fromOffset(x, y)
    end)

    connect(UIS.InputEnded, function(input)
        if dragging and activeInput then
            if input == activeInput
                or (activeInput.UserInputType ==
                    Enum.UserInputType.MouseButton1
                    and input.UserInputType ==
                    Enum.UserInputType.MouseButton1) then
                dragging = false
                activeInput = nil
            end
        end
    end)
end

-- RGB animation
local hue = 0
connect(RunService.RenderStepped, function(dt)
    hue = (hue + dt * 0.15) % 1
    local rgb = Color3.fromHSV(hue, 1, 1)

    outline.Color = rgb
    title.TextColor3 = rgb
    floatTitle.TextColor3 = rgb
    speedTitle.TextColor3 = rgb
    settingsTitle.TextColor3 = rgb
    heightFill.BackgroundColor3 = rgb
    speedFill.BackgroundColor3 = rgb
    ball.BackgroundColor3 = rgb
    ballStroke.Color = rgb
    header.BackgroundColor3 = Color3.fromHSV(hue, 0.65, 0.18)
end)

-- ปิดระบบลอยเมื่อเกิดใหม่
connect(player.CharacterAdded, function()
    stopFloat()
end)

connect(gui.Destroying, function()
    stopFloat()
    for _, c in ipairs(connections) do
        if c.Connected then
            c:Disconnect()
        end
    end
end)

selectTab("FLOAT")
setHeight(height)
setSpeed(speed)

print("FIRST GAME RGB UI V6 loaded")
