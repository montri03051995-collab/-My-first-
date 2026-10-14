
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "MyFirst"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame")
frame.Name = "Main"
frame.Size = UDim2.fromOffset(260, 290)
frame.Position = UDim2.new(0.5, -130, 0.5, -145)
frame.BackgroundColor3 = Color3.fromRGB(10, 20, 40)
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -48, 0, 42)
title.BackgroundTransparency = 1
title.Text = "My first"
title.TextColor3 = Color3.fromRGB(0, 220, 255)
title.TextSize = 22
title.Parent = frame

local minimize = Instance.new("TextButton")
minimize.Size = UDim2.fromOffset(38, 34)
minimize.Position = UDim2.new(1, -42, 0, 4)
minimize.Text = "-"
minimize.Parent = frame

local content = Instance.new("Frame")
content.Position = UDim2.fromOffset(8, 48)
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
        button.Text = name .. ": "
            .. (states[name] and "เปิด" or "ปิด")
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

local minimized = false

minimize.Activated:Connect(function()
    minimized = not minimized
    content.Visible = not minimized
    frame.Size = minimized
        and UDim2.fromOffset(260, 45)
        or UDim2.fromOffset(260, 290)
    minimize.Text = minimized and "+" or "-"
end)

gui.Parent = player:WaitForChild("PlayerGui")
