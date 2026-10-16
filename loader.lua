
-- MY FIRST UI FARM
-- วางใน StarterPlayerScripts > MyFirstUI (LocalScript)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local attackEvent =
    ReplicatedStorage:WaitForChild("FarmAttack")

local oldGui = player.PlayerGui:FindFirstChild("MyFirstUI")
if oldGui then
    oldGui:Destroy()
end

local farmEnabled = false
local minimized = false

local gui = Instance.new("ScreenGui")
gui.Name = "MyFirstUI"
gui.ResetOnSpawn = false
gui.DisplayOrder = 10
gui.Parent = player:WaitForChild("PlayerGui")

-- หน้าต่างหลัก
local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.fromOffset(280, 250)
frame.Position = UDim2.new(0.5, -140, 0.35, 0)
frame.BackgroundColor3 = Color3.fromRGB(10, 20, 40)
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

-- แถบหัวหน้าต่าง
local header = Instance.new("TextLabel")
header.Size = UDim2.new(1, -50, 0, 42)
header.Position = UDim2.fromOffset(10, 0)
header.BackgroundTransparency = 1
header.Text = "MY FIRST FARM"
header.TextColor3 = Color3.fromRGB(80, 225, 255)
header.TextSize = 20
header.Font = Enum.Font.GothamBold
header.TextXAlignment = Enum.TextXAlignment.Left
header.Parent = frame

-- ปุ่มย่อ/ขยาย
local minimizeButton = Instance.new("TextButton")
minimizeButton.Size = UDim2.fromOffset(36, 32)
minimizeButton.Position = UDim2.new(1, -42, 0, 5)
minimizeButton.Text = "-"
minimizeButton.TextSize = 24
minimizeButton.BackgroundColor3 = Color3.fromRGB(25, 50, 75)
minimizeButton.TextColor3 = Color3.new(1, 1, 1)
minimizeButton.Parent = frame

local function makeButton(name, text, position, size)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = size
    button.Position = position
    button.Text = text
    button.TextSize = 17
    button.Font = Enum.Font.GothamBold
    button.TextColor3 = Color3.new(1, 1, 1)
    button.BackgroundColor3 = Color3.fromRGB(30, 60, 85)
    button.AutoButtonColor = true
    button.Parent = frame

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 8)
    c.Parent = button

    return button
end

local farmButton = makeButton(
    "FarmToggle",
    "FARM: OFF",
    UDim2.fromOffset(15, 55),
    UDim2.new(1, -30, 0, 42)
)

farmButton.BackgroundColor3 = Color3.fromRGB(120, 45, 55)

local attackButton = makeButton(
    "Attack",
    "โจมตีศัตรู",
    UDim2.fromOffset(15, 105),
    UDim2.new(1, -30, 0, 48)
)

attackButton.BackgroundColor3 = Color3.fromRGB(0, 120, 190)

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 25)
statusLabel.Position = UDim2.fromOffset(10, 160)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "สถานะ: ปิดระบบ"
statusLabel.TextColor3 = Color3.fromRGB(220, 230, 240)
statusLabel.TextSize = 14
statusLabel.Parent = frame

local statsLabel = Instance.new("TextLabel")
statsLabel.Size = UDim2.new(1, -20, 0, 30)
statsLabel.Position = UDim2.fromOffset(10, 192)
statsLabel.BackgroundTransparency = 1
statsLabel.Text = "EXP: 0 | Coins: 0"
statsLabel.TextColor3 = Color3.fromRGB(100, 225, 255)
statsLabel.TextSize = 15
statsLabel.Parent = frame

-- เปิด/ปิดระบบ
farmButton.Activated:Connect(function()
    farmEnabled = not farmEnabled

    if farmEnabled then
        farmButton.Text = "FARM: ON"
        farmButton.BackgroundColor3 =
            Color3.fromRGB(0, 145, 90)
        statusLabel.Text = "สถานะ: พร้อมโจมตี"
    else
        farmButton.Text = "FARM: OFF"
        farmButton.BackgroundColor3 =
            Color3.fromRGB(120, 45, 55)
        statusLabel.Text = "สถานะ: ปิดระบบ"
    end
end)

-- โจมตีเมื่อผู้เล่นกดปุ่ม
attackButton.Activated:Connect(function()
    if not farmEnabled then
        statusLabel.Text = "กรุณาเปิด FARM ก่อน"
        return
    end

    attackEvent:FireServer()
    statusLabel.Text = "ส่งคำขอโจมตีแล้ว"
end)

-- อัปเดต EXP และ Coins จาก leaderstats
local function connectStats()
    local stats = player:WaitForChild("leaderstats")
    local exp = stats:WaitForChild("EXP")
    local coins = stats:WaitForChild("Coins")

    local function update()
        statsLabel.Text = string.format(
            "EXP: %d | Coins: %d",
            exp.Value,
            coins.Value
        )
    end

    exp:GetPropertyChangedSignal("Value"):Connect(update)
    coins:GetPropertyChangedSignal("Value"):Connect(update)
    update()
end

task.spawn(connectStats)

-- ปุ่มย่อ/ขยาย
minimizeButton.Activated:Connect(function()
    minimized = not minimized

    farmButton.Visible = not minimized
    attackButton.Visible = not minimized
    statusLabel.Visible = not minimized
    statsLabel.Visible = not minimized

    frame.Size = minimized
        and UDim2.fromOffset(280, 42)
        or UDim2.fromOffset(280, 250)

    minimizeButton.Text = minimized and "+" or "-"
end)

-- ลากหน้าต่างด้วยเมาส์หรือสัมผัส
local dragging = false
local dragInput = nil
local dragStart = nil
local startPosition = nil

local function updateDrag(input)
    local delta = input.Position - dragStart

    frame.Position = UDim2.new(
        startPosition.X.Scale,
        startPosition.X.Offset + delta.X,
        startPosition.Y.Scale,
        startPosition.Y.Offset + delta.Y
    )
end

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        dragStart = input.Position
        startPosition = frame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        updateDrag(input)
    end
end)

print("MyFirstUI FARM โหลดสำเร็จ")
