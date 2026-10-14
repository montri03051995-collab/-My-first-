-- My First UI
-- UI Demo สำหรับทดสอบปุ่มบน Android

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "MyFirstUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 260, 0, 290)
frame.Position = UDim2.new(0.5, -130, 0.35, 0)
frame.BackgroundColor3 = Color3.fromRGB(12, 22, 40)
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -45, 0, 42)
title.BackgroundTransparency = 1
title.Text = "MY FIRST"
title.TextColor3 = Color3.fromRGB(0, 220, 255)
title.TextSize = 22
title.Parent = frame

local minimize = Instance.new("TextButton")
minimize.Size = UDim2.new(0, 38, 0, 34)
minimize.Position = UDim2.new(1, -42, 0, 4)
minimize.Text = "-"
minimize.TextSize = 24
minimize.Parent = frame

local content = Instance.new("Frame")
content.Position = UDim2.new(0, 8, 0, 48)
content.Size = UDim2.new(1, -16, 1, -56)
content.BackgroundTransparency = 1
content.Parent = frame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.Parent = content

local states = {
    ["อมตะ"] = false,
    ["บอสไม่ตี"] = false,
    ["อารีนาออโต้"] = false
}

local function makeButton(name)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 42)
    button.BackgroundColor3 = Color3.fromRGB(25, 45, 70)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.TextSize = 16
    button.Parent = content

    local function refresh()
        button.Text = name .. ": " ..
            (states[name] and "เปิด" or "ปิด")
        button.BackgroundColor3 = states[name]
            and Color3.fromRGB(0, 120, 150)
            or Color3.fromRGB(25, 45, 70)
    end

    button.Activated:Connect(function()
        states[name] = not states[name]
        refresh()
        print(name, states[name] and "ON" or "OFF")
    end)

    refresh()
end

makeButton("อมตะ")
makeButton("บอสไม่ตี")
makeButton("อารีนาออโต้")

minimize.Activated:Connect(function()
    content.Visible = not content.Visible
    frame.Size = content.Visible
        and UDim2.new(0, 260, 0, 290)
        or UDim2.new(0, 260, 0, 45)
    minimize.Text = content.Visible and "-" or "+"
end)
