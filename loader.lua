

-- My First UI - Neon Cyan
-- UI demonstration for a supported Roblox LocalScript

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Remove old copy
local oldGui = playerGui:FindFirstChild("MyFirstUI")
if oldGui then
    oldGui:Destroy()
end

local cyan = Color3.fromRGB(0, 220, 255)
local dark = Color3.fromRGB(12, 20, 38)
local panel = Color3.fromRGB(20, 32, 55)
local white = Color3.fromRGB(240, 250, 255)

local gui = Instance.new("ScreenGui")
gui.Name = "MyFirstUI"
gui.ResetOnSpawn = false
gui.DisplayOrder = 10
gui.Parent = playerGui

-- Main window
local frame = Instance.new("Frame")
frame.Name = "Main"
frame.Size = UDim2.fromOffset(280, 190)
frame.Position = UDim2.new(0.5, -140, 0.35, 0)
frame.BackgroundColor3 = dark
frame.BorderSizePixel = 0
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame

local outline = Instance.new("UIStroke")
outline.Color = cyan
outline.Thickness = 1.5
outline.Parent = frame

-- Header
local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 42)
header.BackgroundColor3 = panel
header.BorderSizePixel = 0
header.Active = true
header.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -95, 1, 0)
title.Position = UDim2.fromOffset(10, 0)
title.BackgroundTransparency = 1
title.Text = "MY FIRST UI"
title.TextColor3 = cyan
title.TextSize = 18
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

-- Header buttons
local function headerButton(name, text, x)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.fromOffset(32, 30)
    button.Position = UDim2.new(1, x, 0, 6)
    button.BackgroundColor3 = dark
    button.TextColor3 = cyan
    button.Text = text
    button.TextSize = 20
    button.Parent = header

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = button

    return button
end

local minimizeButton = headerButton("Minimize", "-", -74)
local hideButton = headerButton("Hide", "×", -38)

local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleContent"
toggleButton.Size = UDim2.new(1, -24, 0, 40)
toggleButton.Position = UDim2.fromOffset(12, 55)
toggleButton.BackgroundColor3 = panel
toggleButton.TextColor3 = white
toggleButton.TextSize = 14
toggleButton.Text = "ซ่อนข้อความ"
toggleButton.Parent = frame

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 8)
toggleCorner.Parent = toggleButton

local status = Instance.new("TextLabel")
status.Name = "Status"
status.Size = UDim2.new(1, -24, 0, 55)
status.Position = UDim2.fromOffset(12, 105)
status.BackgroundTransparency = 1
status.TextColor3 = white
status.TextSize = 14
status.TextWrapped = true
status.Text = "สถานะ: พร้อมใช้งาน"
status.Parent = frame

-- Floating button to reopen hidden window
local reopenButton = Instance.new("TextButton")
reopenButton.Name = "Reopen"
reopenButton.Size = UDim2.fromOffset(120, 42)
reopenButton.Position = UDim2.new(0, 12, 0.5, 0)
reopenButton.BackgroundColor3 = dark
reopenButton.TextColor3 = cyan
reopenButton.Text = "เปิด My UI"
reopenButton.TextSize = 14
reopenButton.Visible = false
reopenButton.Parent = gui

local reopenCorner = Instance.new("UICorner")
reopenCorner.CornerRadius = UDim.new(0, 8)
reopenCorner.Parent = reopenButton

local reopenStroke = Instance.new("UIStroke")
reopenStroke.Color = cyan
reopenStroke.Parent = reopenButton

-- Toggle content
local contentVisible = true

toggleButton.Activated:Connect(function()
    contentVisible = not contentVisible
    status.Visible = contentVisible

    toggleButton.Text = contentVisible
        and "ซ่อนข้อความ"
        or "แสดงข้อความ"

    status.Text = contentVisible
        and "สถานะ: พร้อมใช้งาน"
        or "ซ่อนข้อความแล้ว"
end)

-- Minimize and restore
local minimized = false

minimizeButton.Activated:Connect(function()
    minimized = not minimized

    frame.Size = minimized
        and UDim2.fromOffset(280, 42)
        or UDim2.fromOffset(280, 190)

    toggleButton.Visible = not minimized
    status.Visible = not minimized and contentVisible
    minimizeButton.Text = minimized and "+" or "-"
end)

-- Hide and reopen entire window
hideButton.Activated:Connect(function()
    frame.Visible = false
    reopenButton.Visible = true
end)

reopenButton.Activated:Connect(function()
    frame.Visible = true
    reopenButton.Visible = false
end)

-- Touch and mouse dragging
local dragging = false
local dragStart
local startPosition
local activeInput

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then

        dragging = true
        dragStart = input.Position
        startPosition = frame.Position
        activeInput = input

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
                activeInput = nil
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not dragging then
        return
    end

    if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseMovement then

        local delta = input.Position - dragStart

        frame.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

print("My First UI ready")

