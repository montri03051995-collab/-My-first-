-- My First UI FARM
-- LocalScript สำหรับเกม Roblox ของคุณเอง
-- EXP / Coins เป็นข้อมูลจำลองเท่านั้น

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local old = playerGui:FindFirstChild("MyFirstUI")
if old then
    old:Destroy()
end

local cyan = Color3.fromRGB(0, 220, 255)
local dark = Color3.fromRGB(7, 15, 32)
local panelColor = Color3.fromRGB(12, 28, 52)
local green = Color3.fromRGB(40, 235, 150)
local red = Color3.fromRGB(255, 80, 105)

local gui = Instance.new("ScreenGui")
gui.Name = "MyFirstUI"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.fromOffset(300, 300)
main.Position = UDim2.new(0.5, -150, 0.5, -150)
main.BackgroundColor3 = dark
main.BorderSizePixel = 0
main.Active = true
main.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 14)
corner.Parent = main

local outline = Instance.new("UIStroke")
outline.Color = cyan
outline.Thickness = 2
outline.Parent = main

local function makeLabel(text, y, height, size)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -24, 0, height)
    label.Position = UDim2.fromOffset(12, y)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(235, 250, 255)
    label.TextSize = size
    label.Font = Enum.Font.GothamBold
    label.Parent = main
    return label
end

local header = Instance.new("TextButton")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 48)
header.BackgroundColor3 = panelColor
header.Text = "MY FIRST UI     —"
header.TextColor3 = cyan
header.TextSize = 18
header.Font = Enum.Font.GothamBold
header.Parent = main

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 12)
headerCorner.Parent = header

local status = makeLabel("STATUS: OFF", 57, 25, 14)
local stats = makeLabel("EXP: 0     COINS: 0", 91, 32, 17)

local farmButton = Instance.new("TextButton")
farmButton.Name = "FarmToggle"
farmButton.Position = UDim2.fromOffset(15, 137)
farmButton.Size = UDim2.new(1, -30, 0, 45)
farmButton.BackgroundColor3 = green
farmButton.Text = "FARM: OFF"
farmButton.TextColor3 = dark
farmButton.TextSize = 16
farmButton.Font = Enum.Font.GothamBold
farmButton.Parent = main

local farmCorner = Instance.new("UICorner")
farmCorner.CornerRadius = UDim.new(0, 10)
farmCorner.Parent = farmButton

local resetButton = Instance.new("TextButton")
resetButton.Name = "Reset"
resetButton.Position = UDim2.fromOffset(15, 194)
resetButton.Size = UDim2.new(1, -30, 0, 40)
resetButton.BackgroundColor3 = panelColor
resetButton.Text = "RESET DEMO"
resetButton.TextColor3 = cyan
resetButton.TextSize = 14
resetButton.Font = Enum.Font.GothamBold
resetButton.Parent = main

local resetCorner = Instance.new("UICorner")
resetCorner.CornerRadius = UDim.new(0, 10)
resetCorner.Parent = resetButton

local footer = makeLabel("Demo only • No real rewards", 250, 22, 10)
footer.TextColor3 = Color3.fromRGB(130, 165, 190)

local farming = false
local minimized = false
local exp = 0
local coins = 0
local session = 0

local function updateStats()
    stats.Text = "EXP: " .. exp .. "     COINS: " .. coins
end

local function setFarm(enabled)
    farming = enabled
    session += 1
    local mySession = session

    if enabled then
        farmButton.Text = "FARM: ON"
        farmButton.BackgroundColor3 = red
        status.Text = "STATUS: RUNNING DEMO"

        task.spawn(function()
            while farming and session == mySession do
                task.wait(1)
                if farming and session == mySession then
                    exp += 10
                    coins += 5
                    updateStats()
                end
            end
        end)
    else
        farmButton.Text = "FARM: OFF"
        farmButton.BackgroundColor3 = green
        status.Text = "STATUS: OFF"
    end
end

farmButton.Activated:Connect(function()
    setFarm(not farming)
end)

resetButton.Activated:Connect(function()
    setFarm(false)
    exp = 0
    coins = 0
    updateStats()
end)

header.Activated:Connect(function()
    minimized = not minimized
    main.Size = minimized
        and UDim2.fromOffset(300, 48)
        or UDim2.fromOffset(300, 300)

    status.Visible = not minimized
    stats.Visible = not minimized
    farmButton.Visible = not minimized
    resetButton.Visible = not minimized
    footer.Visible = not minimized
    header.Text = minimized and "MY FIRST UI     +" or "MY FIRST UI     —"
end)

-- ลากหน้าต่างด้วยนิ้วหรือเมาส์
local dragging = false
local dragStart
local startPos

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (
        input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseMovement
    ) then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

print("My First UI FARM demo loaded")
