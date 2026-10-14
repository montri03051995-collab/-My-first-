
-- My First UI
-- UI demo for a supported Roblox LocalScript

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "MyFirstUI"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame")
frame.Name = "Main"
frame.Size = UDim2.fromOffset(260, 170)
frame.Position = UDim2.new(0.5, -130, 0.4, 0)
frame.BackgroundColor3 = Color3.fromRGB(15, 25, 45)
frame.BorderSizePixel = 0
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -50, 0, 40)
title.Position = UDim2.fromOffset(10, 0)
title.Text = "MY FIRST UI"
title.TextColor3 = Color3.fromRGB(0, 220, 255)
title.BackgroundTransparency = 1
title.TextSize = 20
title.Parent = frame

local minimize = Instance.new("TextButton")
minimize.Size = UDim2.fromOffset(35, 30)
minimize.Position = UDim2.new(1, -40, 0, 5)
minimize.Text = "-"
minimize.TextSize = 22
minimize.Parent = frame

local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(1, -20, 0, 40)
toggle.Position = UDim2.fromOffset(10, 50)
toggle.Text = "ปิดการแสดงข้อความ"
toggle.Parent = frame

local message = Instance.new("TextLabel")
message.Size = UDim2.new(1, -20, 0, 45)
message.Position = UDim2.fromOffset(10, 105)
message.Text = "My First UI พร้อมใช้งาน"
message.TextColor3 = Color3.new(1, 1, 1)
message.BackgroundTransparency = 1
message.TextSize = 15
message.Parent = frame

local enabled = true
local minimized = false

toggle.Activated:Connect(function()
    enabled = not enabled
    message.Visible = enabled
    toggle.Text = enabled
        and "ปิดการแสดงข้อความ"
        or "เปิดการแสดงข้อความ"
end)

minimize.Activated:Connect(function()
    minimized = not minimized
    message.Visible = not minimized and enabled
    toggle.Visible = not minimized

    frame.Size = minimized
        and UDim2.fromOffset(260, 40)
        or UDim2.fromOffset(260, 170)

    minimize.Text = minimized and "+" or "-"
end)

gui.Parent = player:WaitForChild("PlayerGui")

