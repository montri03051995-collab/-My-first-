
-- My First UI FARM
-- สำหรับเกม Roblox ที่คุณมีสิทธิ์แก้ไข
-- วางโค้ดนี้เป็น LocalScript ใน StarterPlayerScripts

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ตั้งค่า
local UI_NAME = "MyFirstUI"
local FARM_INTERVAL = 1

local farmEnabled = false
local minimized = false
local destroyed = false

-- ลบ UI เก่าเมื่อรันซ้ำ
local oldGui = playerGui:FindFirstChild(UI_NAME)
if oldGui then
    oldGui:Destroy()
end

-- สร้าง UI
local gui = Instance.new("ScreenGui")
gui.Name = UI_NAME
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.fromOffset(280, 300)
frame.Position = UDim2.new(0.5, -140, 0.35, 0)
frame.BackgroundColor3 = Color3.fromRGB(12, 20, 38)
frame.BorderSizePixel = 0
frame.Active = true
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(0, 200, 255)
stroke.Thickness = 2
stroke.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -90, 0, 42)
title.Position = UDim2.fromOffset(10, 0)
title.BackgroundTransparency = 1
title.Text = "MY FIRST UI FARM"
title.TextColor3 = Color3.fromRGB(0, 220, 255)
title.TextSize = 17
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

local function createButton(name, text, y, color)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(1, -24, 0, 42)
    button.Position = UDim2.fromOffset(12, y)
    button.BackgroundColor3 = color
    button.Text = text
    button.TextColor3 = Color3.new(1, 1, 1)
    button.TextSize = 15
    button.Font = Enum.Font.GothamBold
    button.AutoButtonColor = true
    button.Active = true
    button.Parent = frame

    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 8)
    buttonCorner.Parent = button

    return button
end

local minimizeButton = Instance.new("TextButton")
minimizeButton.Name = "MinimizeButton"
minimizeButton.Size = UDim2.fromOffset(34, 30)
minimizeButton.Position = UDim2.new(1, -42, 0, 6)
minimizeButton.BackgroundColor3 = Color3.fromRGB(30, 50, 75)
minimizeButton.Text = "-"
minimizeButton.TextColor3 = Color3.new(1, 1, 1)
minimizeButton.TextSize = 22
minimizeButton.Font = Enum.Font.GothamBold
minimizeButton.Parent = frame

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 6)
minCorner.Parent = minimizeButton

local farmButton = createButton(
    "FarmButton",
    "FARM: OFF",
    52,
    Color3.fromRGB(150, 45, 55)
)

local attackButton = createButton(
    "AttackButton",
    "โจมตี 1 ครั้ง",
    102,
    Color3.fromRGB(25, 100, 180)
)

local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Size = UDim2.new(1, -24, 0, 34)
statusLabel.Position = UDim2.fromOffset(12, 152)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "สถานะ: พร้อมใช้งาน"
statusLabel.TextColor3 = Color3.fromRGB(220, 235, 255)
statusLabel.TextSize = 13
statusLabel.Font = Enum.Font.Gotham
statusLabel.Parent = frame

local statsLabel = Instance.new("TextLabel")
statsLabel.Name = "StatsLabel"
statsLabel.Size = UDim2.new(1, -24, 0, 42)
statsLabel.Position = UDim2.fromOffset(12, 190)
statsLabel.BackgroundColor3 = Color3.fromRGB(22, 35, 55)
statsLabel.Text = "EXP: 0  |  Coins: 0"
statsLabel.TextColor3 = Color3.fromRGB(0, 220, 255)
statsLabel.TextSize = 14
statsLabel.Font = Enum.Font.GothamBold
statsLabel.Parent = frame

local statsCorner = Instance.new("UICorner")
statsCorner.CornerRadius = UDim.new(0, 8)
statsCorner.Parent = statsLabel

local closeButton = createButton(
    "CloseButton",
    "ปิดหน้าต่าง",
    240,
    Color3.fromRGB(65, 70, 90)
)

-- ค้นหา RemoteEvent แบบไม่รอค้าง
local attackEvent =
    ReplicatedStorage:FindFirstChild("FarmAttack")

local function sendAttack()
    if destroyed or not gui.Parent then
        return false
    end

    -- ตรวจสอบอีกครั้ง เผื่อ RemoteEvent ถูกสร้างภายหลัง
    if not attackEvent then
        attackEvent =
            ReplicatedStorage:FindFirstChild("FarmAttack")
    end

    if not attackEvent
        or not attackEvent:IsA("RemoteEvent") then
        statusLabel.Text = "ไม่พบ FarmAttack"
        return false
    end

    attackEvent:FireServer()
    statusLabel.Text = "ส่งคำขอโจมตีแล้ว"
    return true
end

-- เปิด / ปิด FARM
farmButton.Activated:Connect(function()
    farmEnabled = not farmEnabled

    if farmEnabled then
        farmButton.Text = "FARM: ON"
        farmButton.BackgroundColor3 =
            Color3.fromRGB(20, 150, 85)
        statusLabel.Text = "FARM เปิดอยู่"
    else
        farmButton.Text = "FARM: OFF"
        farmButton.BackgroundColor3 =
            Color3.fromRGB(150, 45, 55)
        statusLabel.Text = "FARM ปิดอยู่"
    end
end)

-- โจมตีด้วยการกดปุ่ม
attackButton.Activated:Connect(function()
    sendAttack()
end)

-- ย่อ / ขยาย
minimizeButton.Activated:Connect(function()
    minimized = not minimized

    for _, child in ipairs(frame:GetChildren()) do
        if child ~= title
            and child ~= minimizeButton
            and child ~= corner
            and child ~= stroke then
            child.Visible = not minimized
        end
    end

    frame.Size = minimized
        and UDim2.fromOffset(280, 42)
        or UDim2.fromOffset(280, 300)

    minimizeButton.Text = minimized and "+" or "-"
end)

-- ปิดหน้าต่าง
closeButton.Activated:Connect(function()
    destroyed = true
    farmEnabled = false
    gui:Destroy()
end)

-- ลากหน้าต่างด้วยนิ้วหรือเมาส์
local dragging = false
local dragStart
local startPosition
local dragInput

title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then

        dragging = true
        dragStart = input.Position
        startPosition = frame.Position

        input.Changed:Connect(function()
            if input.UserInputState ==
                Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

title.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local delta = input.Position - dragStart

        frame.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

-- อัปเดต EXP / Coins เมื่อมี leaderstats
local function connectStats()
    local leaderstats = player:FindFirstChild("leaderstats")
    if not leaderstats then
        return
    end

    local exp = leaderstats:FindFirstChild("EXP")
    local coins = leaderstats:FindFirstChild("Coins")

    local function refresh()
        if not gui.Parent then
            return
        end

        local expValue = exp and exp.Value or 0
        local coinValue = coins and coins.Value or 0

        statsLabel.Text = string.format(
            "EXP: %s  |  Coins: %s",
            tostring(expValue),
            tostring(coinValue)
        )
    end

    if exp then
        exp:GetPropertyChangedSignal("Value"):Connect(refresh)
    end

    if coins then
        coins:GetPropertyChangedSignal("Value"):Connect(refresh)
    end

    refresh()
end

connectStats()

player.ChildAdded:Connect(function(child)
    if child.Name == "leaderstats" then
        task.defer(connectStats)
    end
end)

-- ระบบโจมตีอัตโนมัติในเกมของคุณ
task.spawn(function()
    while not destroyed and gui.Parent do
        task.wait(FARM_INTERVAL)

        if farmEnabled then
            sendAttack()
        end
    end
end)

print("My First UI FARM loaded")
