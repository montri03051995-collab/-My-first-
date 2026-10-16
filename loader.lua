
-- My First UI
-- UI ทดสอบปุ่มสำหรับ LocalScript
-- ใช้ในเกมที่คุณมีสิทธิ์แก้ไข

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
if not player then
    warn("ต้องรันจาก LocalScript")
    return
end

local playerGui = player:WaitForChild("PlayerGui")

local oldGui = playerGui:FindFirstChild("MyFirstUI")
if oldGui then
    oldGui:Destroy()
end

local farmEnabled = false
local minimized = false

local gui = Instance.new("ScreenGui")
gui.Name = "MyFirstUI"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(280, 270)
frame.Position = UDim2.new(0.5, -140, 0.35, 0)
frame.BackgroundColor3 = Color3.fromRGB(12, 20, 38)
frame.Active = true
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(0, 220, 255)
stroke.Thickness = 2
stroke.Parent = frame

local title = Instance.new("TextButton")
title.Size = UDim2.new(1, -80, 0, 42)
title.BackgroundTransparency = 1
title.Text = "MY FIRST UI"
title.TextColor3 = Color3.fromRGB(0, 220, 255)
title.TextSize = 18
title.Font = Enum.Font.GothamBold
title.Parent = frame

local function makeButton(name, text, y, color)
    local b = Instance.new("TextButton")
    b.Name = name
    b.Size = UDim2.new(1, -24, 0, 42)
    b.Position = UDim2.fromOffset(12, y)
    b.BackgroundColor3 = color
    b.Text = text
    b.TextColor3 = Color3.new(1, 1, 1)
    b.TextSize = 15
    b.Font = Enum.Font.GothamBold
    b.Active = true
    b.Parent = frame

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 8)
    c.Parent = b

    return b
end

local minimize = Instance.new("TextButton")
minimize.Size = UDim2.fromOffset(36, 30)
minimize.Position = UDim2.new(1, -42, 0, 6)
minimize.Text = "-"
minimize.TextSize = 22
minimize.Parent = frame

local farmButton = makeButton(
    "FarmButton", "FARM: OFF", 52,
    Color3.fromRGB(150, 45, 55)
)

local testButton = makeButton(
    "TestButton", "ทดสอบปุ่ม", 102,
    Color3.fromRGB(25, 100, 180)
)

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -24, 0, 50)
status.Position = UDim2.fromOffset(12, 152)
status.BackgroundTransparency = 1
status.Text = "สถานะ: พร้อมใช้งาน"
status.TextColor3 = Color3.new(1, 1, 1)
status.TextSize = 14
status.TextWrapped = true
status.Parent = frame

local closeButton = makeButton(
    "CloseButton", "ปิด UI", 210,
    Color3.fromRGB(65, 70, 90)
)

farmButton.Activated:Connect(function()
    farmEnabled = not farmEnabled

    if farmEnabled then
        farmButton.Text = "FARM: ON"
        farmButton.BackgroundColor3 =
            Color3.fromRGB(20, 150, 85)
        status.Text = "สถานะ: เปิด FARM แล้ว"
    else
        farmButton.Text = "FARM: OFF"
        farmButton.BackgroundColor3 =
            Color3.fromRGB(150, 45, 55)
        status.Text = "สถานะ: ปิด FARM แล้ว"
    end
end)

testButton.Activated:Connect(function()
    status.Text = "ทดสอบสำเร็จ! ปุ่มทำงานแล้ว"
    print("My First UI: button works")
end)

minimize.Activated:Connect(function()
    minimized = not minimized

    farmButton.Visible = not minimized
    testButton.Visible = not minimized
    status.Visible = not minimized
    closeButton.Visible = not minimized

    frame.Size = minimized
        and UDim2.fromOffset(280, 42)
        or UDim2.fromOffset(280, 270)

    minimize.Text = minimized and "+" or "-"
end)

closeButton.Activated:Connect(function()
    gui:Destroy()
end)

-- ลากหน้าต่างด้วยนิ้วหรือเมาส์
local dragging = false
local dragStart
local startPosition

title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then

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

UserInputService.InputChanged:Connect(function(input)
    if dragging and (
        input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseMovement
    ) then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

print("My First UI loaded successfully")
