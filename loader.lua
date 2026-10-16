-- MY FIRST UI V2 | RED EDITION
-- สำหรับเกม Roblox ที่คุณสร้างเอง
-- ตำแหน่ง: StarterPlayer > StarterPlayerScripts > LocalScript

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ตั้งค่า
local RANGE = 250
local systemOn = true
local boxesOn = true
local linesOn = true
local infoOn = true
local nearestOn = true
local selfGlowOn = false
local minimized = false
local closed = false

local RED = Color3.fromRGB(255, 45, 65)
local DARK = Color3.fromRGB(20, 20, 27)
local WHITE = Color3.fromRGB(245, 245, 245)
local GREEN = Color3.fromRGB(60, 230, 130)

local records = {}
local connections = {}

local function connect(signal, callback)
    local connection = signal:Connect(callback)
    table.insert(connections, connection)
    return connection
end

-- ลบ UI เก่า
local oldGui = playerGui:FindFirstChild("MyFirstUIV2")
if oldGui then
    oldGui:Destroy()
end

-- ScreenGui
local gui = Instance.new("ScreenGui")
gui.Name = "MyFirstUIV2"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

-- หน้าต่างหลัก
local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.fromOffset(265, 410)
main.Position = UDim2.new(0, 18, 0.2, 0)
main.BackgroundColor3 = DARK
main.BorderSizePixel = 0
main.Active = true
main.Parent = gui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = main

local stroke = Instance.new("UIStroke")
stroke.Color = RED
stroke.Thickness = 2
stroke.Parent = main

-- แถบหัวหน้าต่าง
local header = Instance.new("TextLabel")
header.Name = "Header"
header.Size = UDim2.new(1, -12, 0, 40)
header.Position = UDim2.fromOffset(6, 4)
header.BackgroundColor3 = Color3.fromRGB(45, 20, 27)
header.Text = "MY FIRST UI V2"
header.TextColor3 = RED
header.TextSize = 18
header.Font = Enum.Font.GothamBold
header.Active = true
header.Parent = main

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 7)
headerCorner.Parent = header

-- ปุ่มลูกลอย (เริ่มต้นซ่อนไว้)
local floatingButton = Instance.new("TextButton")
floatingButton.Name = "MyFirstFloatingButton"
floatingButton.Size = UDim2.fromOffset(56, 56)
floatingButton.Position = UDim2.new(0, 20, 0.55, 0)
floatingButton.BackgroundColor3 = Color3.fromRGB(150, 20, 35)
floatingButton.Text = "MY"
floatingButton.TextColor3 = WHITE
floatingButton.TextSize = 18
floatingButton.Font = Enum.Font.GothamBold
floatingButton.Visible = false
floatingButton.Active = true
floatingButton.ZIndex = 20
floatingButton.Parent = gui

local floatCorner = Instance.new("UICorner")
floatCorner.CornerRadius = UDim.new(1, 0)
floatCorner.Parent = floatingButton

local floatStroke = Instance.new("UIStroke")
floatStroke.Color = RED
floatStroke.Thickness = 2
floatStroke.Parent = floatingButton

-- พื้นที่ปุ่ม
local content = Instance.new("ScrollingFrame")
content.Name = "Content"
content.Position = UDim2.fromOffset(8, 50)
content.Size = UDim2.new(1, -16, 1, -58)
content.BackgroundTransparency = 1
content.BorderSizePixel = 0
content.ScrollBarThickness = 4
content.CanvasSize = UDim2.new(0, 0, 0, 0)
content.AutomaticCanvasSize = Enum.AutomaticSize.Y
content.ScrollingDirection = Enum.ScrollingDirection.Y
content.Parent = main

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 6)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = content

local function makeButton(text, order, callback)
    local button = Instance.new("TextButton")
    button.Name = "Button" .. order
    button.LayoutOrder = order
    button.Size = UDim2.new(1, -4, 0, 32)
    button.BackgroundColor3 = Color3.fromRGB(39, 39, 49)
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = WHITE
    button.TextSize = 13
    button.Font = Enum.Font.Gotham
    button.AutoButtonColor = true
    button.Parent = content

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button

    button.Activated:Connect(function()
        if not closed and callback then
            callback(button)
        end
    end)

    return button
end

local function updateButton(button, label, enabled)
    button.Text = label .. ": " .. (enabled and "เปิด" or "ปิด")
    button.TextColor3 = enabled and GREEN or WHITE
end

local function makeLabel(text, order, color, height)
    local label = Instance.new("TextLabel")
    label.LayoutOrder = order
    label.Size = UDim2.new(1, -4, 0, height or 23)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color or WHITE
    label.TextSize = 12
    label.Font = Enum.Font.Gotham
    label.TextWrapped = true
    label.Parent = content
    return label
end

local statusLabel = makeLabel("สถานะระบบ: เปิด", 1, GREEN, 24)
local healthLabel = makeLabel("เลือด: --", 2)
local speedLabel = makeLabel("ความเร็ว: --", 3)
local nearestLabel = makeLabel("ใกล้ที่สุด: --", 4, RED, 28)

-- ตรวจสอบตัวละคร
local function getRoot(model)
    return model:FindFirstChild("HumanoidRootPart")
        or model:FindFirstChild("UpperTorso")
        or model:FindFirstChild("Torso")
end

local function getHumanoid(model)
    return model and model:FindFirstChildOfClass("Humanoid")
end

local function validCharacter(model)
    if not model or not model:IsA("Model") then
        return false
    end

    local humanoid = getHumanoid(model)
    local root = getRoot(model)

    return humanoid ~= nil and root ~= nil and humanoid.Health > 0
end

local function removeRecord(model)
    local record = records[model]
    if not record then
        return
    end

    for _, object in pairs(record) do
        if typeof(object) == "Instance" then
            object:Destroy()
        end
    end

    records[model] = nil
end

-- สร้างกรอบครอบทั้งโมเดล ไม่ใช่เฉพาะหัว
local function addCharacter(model)
    if records[model] or not validCharacter(model) then
        return
    end

    local highlight = Instance.new("Highlight")
    highlight.Name = "MyFirstCharacterHighlight"
    highlight.Adornee = model
    highlight.FillColor = RED
    highlight.FillTransparency = 0.9
    highlight.OutlineColor = RED
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Enabled = false
    highlight.Parent = Workspace

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "MyFirstCharacterInfo"
    billboard.Adornee = getRoot(model)
    billboard.Size = UDim2.fromOffset(190, 28)
    billboard.StudsOffsetWorldSpace = Vector3.new(0, 3.2, 0)
    billboard.AlwaysOnTop = true
    billboard.Enabled = false
    billboard.Parent = playerGui

    local infoText = Instance.new("TextLabel")
    infoText.Size = UDim2.fromScale(1, 1)
    infoText.BackgroundColor3 = DARK
    infoText.BackgroundTransparency = 0.15
    infoText.BorderSizePixel = 0
    infoText.TextColor3 = WHITE
    infoText.TextSize = 12
    infoText.Font = Enum.Font.GothamBold
    infoText.Text = model.Name
    infoText.Parent = billboard

    local infoCorner = Instance.new("UICorner")
    infoCorner.CornerRadius = UDim.new(0, 5)
    infoCorner.Parent = infoText

    local line = Instance.new("Frame")
    line.Name = "MyFirstDistanceLine"
    line.AnchorPoint = Vector2.new(0.5, 0.5)
    line.BorderSizePixel = 0
    line.BackgroundColor3 = RED
    line.Visible = false
    line.ZIndex = 2
    line.Parent = gui

    records[model] = {
        highlight = highlight,
        billboard = billboard,
        infoText = infoText,
        line = line,
    }
end

-- เพิ่มตัวละครผู้เล่นและบอทในโฟลเดอร์ NPCs
local function scanCharacters()
    if closed then
        return
    end

    for _, otherPlayer in ipairs(Players:GetPlayers()) do
        local character = otherPlayer.Character
        if character and character ~= player.Character then
            addCharacter(character)
        end
    end

    local npcFolder = Workspace:FindFirstChild("NPCs")
    if npcFolder then
        for _, object in ipairs(npcFolder:GetDescendants()) do
            if object:IsA("Model") and validCharacter(object) then
                addCharacter(object)
            end
        end
    end

    for model in pairs(records) do
        if not model.Parent or not validCharacter(model) then
            removeRecord(model)
        end
    end
end

-- ปุ่มควบคุม
local systemButton = makeButton("ระบบ: เปิด", 5, function(button)
    systemOn = not systemOn
    updateButton(button, "ระบบ", systemOn)
    statusLabel.Text = "สถานะระบบ: " .. (systemOn and "เปิด" or "ปิด")
    statusLabel.TextColor3 = systemOn and GREEN or RED
end)

local boxButton = makeButton("กรอบตัวละคร: เปิด", 6, function(button)
    boxesOn = not boxesOn
    updateButton(button, "กรอบตัวละคร", boxesOn)
end)

local lineButton = makeButton("เส้นระยะ: เปิด", 7, function(button)
    linesOn = not linesOn
    updateButton(button, "เส้นระยะ", linesOn)
end)

local infoButton = makeButton("ข้อมูลตัวละคร: เปิด", 8, function(button)
    infoOn = not infoOn
    updateButton(button, "ข้อมูลตัวละคร", infoOn)
end)

local nearestButton = makeButton("ไฮไลต์ใกล้สุด: เปิด", 9, function(button)
    nearestOn = not nearestOn
    updateButton(button, "ไฮไลต์ใกล้สุด", nearestOn)
end)

local rangeButton = makeButton("ระยะ: 250 studs", 10, function(button)
    if RANGE == 250 then
        RANGE = 500
    elseif RANGE == 500 then
        RANGE = 100
    else
        RANGE = 250
    end
    button.Text = "ระยะ: " .. RANGE .. " studs"
end)

local selfGlowButton = makeButton("ไฮไลต์ตัวเอง: ปิด", 11, function(button)
    selfGlowOn = not selfGlowOn
    updateButton(button, "ไฮไลต์ตัวเอง", selfGlowOn)
end)

local minimizeButton = makeButton("ย่อเป็นลูกลอย", 12, function()
    minimized = true
    main.Visible = false
    floatingButton.Visible = true
end)

local closeButton = makeButton("ปิดหน้าต่าง", 13, function()
    if closed then
        return
    end
    closed = true

    for _, connection in ipairs(connections) do
        connection:Disconnect()
    end

    for model in pairs(records) do
        removeRecord(model)
    end

    selfHighlight:Destroy()
    gui:Destroy()
end)

-- ลากหน้าต่างหลักด้วยนิ้วหรือเมาส์
local function makeDraggable(handle, target)
    local dragging = false
    local dragStart
    local startPosition
    local activeTouch

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
            or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPosition = target.Position
            activeTouch = input
        end
    end)

    handle.InputEnded:Connect(function(input)
        if input == activeTouch
            or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            activeTouch = nil
        end
    end)

    local connection = UserInputService.InputChanged:Connect(function(input)
        if not dragging then
            return
        end

        local isMouseMove =
            activeTouch
            and activeTouch.UserInputType == Enum.UserInputType.MouseButton1
            and input.UserInputType == Enum.UserInputType.MouseMovement

        local isTouchMove = activeTouch and input == activeTouch

        if isMouseMove or isTouchMove then
            local delta = input.Position - dragStart
            target.Position = UDim2.new(
                startPosition.X.Scale,
                startPosition.X.Offset + delta.X,
                startPosition.Y.Scale,
                startPosition.Y.Offset + delta.Y
            )
        end
    end)

    table.insert(connections, connection)
end

makeDraggable(header, main)

-- ลากลูกลอยด้วยนิ้ว/เมาส์ พร้อมแยกการลากจากการแตะเปิด
local floatDragging = false
local floatMoved = false
local floatStart
local floatStartPosition
local floatInput
local floatThreshold = 8

floatingButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then
        floatDragging = true
        floatMoved = false
        floatStart = input.Position
        floatStartPosition = floatingButton.Position
        floatInput = input
    end
end)

table.insert(connections, UserInputService.InputChanged:Connect(function(input)
    if not floatDragging or not floatInput then
        return
    end

    local isTouchMove =
        floatInput.UserInputType == Enum.UserInputType.Touch
        and input == floatInput

    local isMouseMove =
        floatInput.UserInputType == Enum.UserInputType.MouseButton1
        and input.UserInputType == Enum.UserInputType.MouseMovement

    if isTouchMove or isMouseMove then
        local delta = input.Position - floatStart
        if delta.Magnitude > floatThreshold then
            floatMoved = true
        end

        floatingButton.Position = UDim2.new(
            floatStartPosition.X.Scale,
            floatStartPosition.X.Offset + delta.X,
            floatStartPosition.Y.Scale,
            floatStartPosition.Y.Offset + delta.Y
        )
    end
end))

table.insert(connections, UserInputService.InputEnded:Connect(function(input)
    if not floatInput then
        return
    end

    local touchEnded = input == floatInput
    local mouseEnded =
        floatInput.UserInputType == Enum.UserInputType.MouseButton1
        and input.UserInputType == Enum.UserInputType.MouseButton1

    if touchEnded or mouseEnded then
        local shouldOpen = not floatMoved
        floatDragging = false
        floatInput = nil

        if shouldOpen and minimized and not closed then
            minimized = false
            floatingButton.Visible = false
            main.Visible = true
        end
    end
end))

-- ไฮไลต์ตัวเอง
local selfHighlight = Instance.new("Highlight")
selfHighlight.Name = "MyFirstSelfHighlight"
selfHighlight.FillColor = RED
selfHighlight.FillTransparency = 0.9
selfHighlight.OutlineColor = RED
selfHighlight.Enabled = false
selfHighlight.Parent = Workspace
selfHighlight.Adornee = player.Character

table.insert(connections, player.CharacterAdded:Connect(function(character)
    selfHighlight.Adornee = character
end))

-- อัปเดต UI และตัวละคร
table.insert(connections, RunService.RenderStepped:Connect(function()
    if closed or not gui.Parent then
        return
    end

    local character = player.Character
    local myRoot = character and getRoot(character)
    local myHumanoid = character and getHumanoid(character)

    if myHumanoid then
        healthLabel.Text = string.format(
            "เลือด: %d / %d",
            math.floor(myHumanoid.Health),
            math.floor(myHumanoid.MaxHealth)
        )
        speedLabel.Text = "ความเร็ว: " .. math.floor(myHumanoid.WalkSpeed)
    else
        healthLabel.Text = "เลือด: --"
        speedLabel.Text = "ความเร็ว: --"
    end

    selfHighlight.Enabled = systemOn and selfGlowOn
    selfHighlight.Adornee = character

    local nearestModel = nil
    local nearestDistance = math.huge

    if myRoot then
        for model, record in pairs(records) do
            local root = getRoot(model)
            local humanoid = getHumanoid(model)

            if root and humanoid and humanoid.Health > 0 then
                local distance = (root.Position - myRoot.Position).Magnitude
                local inRange = distance <= RANGE

                if inRange and distance < nearestDistance then
                    nearestDistance = distance
                    nearestModel = model
                end

                record.highlight.Adornee = model
                record.highlight.Enabled =
                    systemOn and boxesOn and inRange

                if nearestOn and model == nearestModel then
                    record.highlight.OutlineColor = GREEN
                else
                    record.highlight.OutlineColor = RED
                end

                record.infoText.Text = string.format(
                    "%s | HP %d | %.0f studs",
                    model.Name,
                    math.max(0, math.floor(humanoid.Health)),
                    distance
                )

                local camera = Workspace.CurrentCamera
                local screenPosition, onScreen = camera:WorldToViewportPoint(root.Position)

                record.billboard.Adornee = root
                record.billboard.Enabled =
                    systemOn and infoOn and inRange and onScreen

                if systemOn and linesOn and inRange and onScreen then
                    local center = camera.ViewportSize / 2
                    local from = Vector2.new(center.X, center.Y)
                    local to = Vector2.new(screenPosition.X, screenPosition.Y)
                    local delta = to - from

                    record.line.Position = UDim2.fromOffset(
                        (from.X + to.X) / 2,
                        (from.Y + to.Y) / 2
                    )
                    record.line.Size = UDim2.fromOffset(delta.Magnitude, 2)
                    record.line.Rotation = math.deg(
                        math.atan2(delta.Y, delta.X)
                    )
                    record.line.Visible = true
                    record.line.BackgroundColor3 =
                        (nearestOn and model == nearestModel) and GREEN or RED
                else
                    record.line.Visible = false
                end
            else
                record.highlight.Enabled = false
                record.billboard.Enabled = false
                record.line.Visible = false
            end
        end
    else
        for _, record in pairs(records) do
            record.highlight.Enabled = false
            record.billboard.Enabled = false
            record.line.Visible = false
        end
    end

    if nearestModel then
        nearestLabel.Text = string.format(
            "ใกล้ที่สุด: %s (%.0f studs)",
            nearestModel.Name,
            nearestDistance
        )
    else
        nearestLabel.Text = "ใกล้ที่สุด: --"
    end

    if not systemOn then
        for _, record in pairs(records) do
            record.highlight.Enabled = false
            record.billboard.Enabled = false
            record.line.Visible = false
        end
    end
end))

-- สแกนซ้ำเพื่อรองรับการเกิดใหม่
task.spawn(function()
    while not closed and gui.Parent do
        scanCharacters()
        task.wait(2)
    end
end)

table.insert(connections, gui.Destroying:Connect(function()
    closed = true
    if selfHighlight and selfHighlight.Parent then
        selfHighlight:Destroy()
    end
    for model in pairs(records) do
        removeRecord(model)
    end
end))

print("My First UI V2 พร้อมใช้งาน")

