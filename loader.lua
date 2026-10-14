
-- My First UI | Neon Cyan
-- สำหรับ LocalScript ใน Roblox ที่รองรับ

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ป้องกัน UI ซ้ำ
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

-- หน้าต่างหลัก
local frame = Instance.new("Frame")
frame.Name = "Main"
frame.Size = UDim2.fromOffset(280, 220)
frame.Position = UDim2.new(0.5, -140, 0.35, 0)
frame.BackgroundColor3 = dark
frame.BorderSizePixel = 0
frame.ClipsDescendants = true
frame.Parent = gui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 12)
frameCorner.Parent = frame

local stroke = Instance.new("UIStroke")
stroke.Color = cyan
stroke.Thickness = 1.5
stroke.Parent = frame

-- แถบชื่อ ใช้ลากหน้าต่าง
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 42)
header.BackgroundColor3 = panel
header.BorderSizePixel = 0
header.Active = true
header.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -100, 1, 0)
title.Position = UDim2.fromOffset(12, 0)
title.BackgroundTransparency = 1
title.Text = "MY FIRST UI"
title.TextColor3 = cyan
title.TextSize = 18
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

-- ปุ่มสร้างแบบใช้ซ้ำ
local function makeButton(name, text, position, size)
local button = Instance.new("TextButton")
button.Name = name
button.Text = text
button.Position = position
button.Size = size
button.BackgroundColor3 = panel
button.TextColor3 = white
button.TextSize = 14
button.Font = Enum.Font.GothamMedium
button.AutoButtonColor = true
button.Parent = frame

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 7)
corner.Parent = button

local border = Instance.new("UIStroke")
border.Color = cyan
border.Thickness = 1
border.Parent = button

return button
end

local minimize = Instance.new("TextButton")
minimize.Name = "Minimize"
minimize.Size = UDim2.fromOffset(35, 30)
minimize.Position = UDim2.new(1, -80, 0, 6)
minimize.Text = "-"
minimize.TextSize = 22
minimize.BackgroundColor3 = dark
minimize.TextColor3 = cyan
minimize.Parent = header

local close = Instance.new("TextButton")
close.Name = "HideUI"
close.Size = UDim2.fromOffset(35, 30)
close.Position = UDim2.new(1, -40, 0, 6)
close.Text = "×"
close.TextSize = 22
close.BackgroundColor3 = dark
close.TextColor3 = cyan
close.Parent = header

local function styleHeaderButton(button)
local c = Instance.new("UICorner")
c.CornerRadius = UDim.new(0, 6)
c.Parent = button
end

styleHeaderButton(minimize)
styleHeaderButton(close)

local toggle = makeButton(
"Toggle",
"ปิดระบบแสดงข้อความ",
UDim2.fromOffset(12, 55),
UDim2.new(1, -24, 0, 38)
)

local status = Instance.new("TextLabel")
status.Name = "Status"
status.Position = UDim2.fromOffset(12, 103)
status.Size = UDim2.new(1, -24, 0, 65)
status.BackgroundColor3 = panel
status.TextColor3 = white
status.TextSize = 14
status.Font = Enum.Font.Gotham
status.TextWrapped = true
status.Text = "สถานะ: พร้อมใช้งาน\nMy First UI เริ่มทำงานแล้ว"
status.Parent = frame

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 8)
statusCorner.Parent = status

local footer = Instance.new("TextLabel")
footer.Size = UDim2.new(1, -24, 0, 25)
footer.Position = UDim2.new(0, 12, 1, -30)
footer.BackgroundTransparency = 1
footer.Text = "NEON CYAN • MOBILE UI"
footer.TextColor3 = cyan
footer.TextSize = 11
footer.Parent = frame

-- ปุ่มลอยสำหรับเปิด UI กลับ
local reopen = Instance.new("TextButton")
reopen.Name = "ReopenUI"
reopen.Size = UDim2.fromOffset(115, 42)
reopen.Position = UDim2.new(0, 15, 0.5, 0)
reopen.Text = "เปิด My UI"
reopen.TextColor3 = cyan
reopen.TextSize = 14
reopen.BackgroundColor3 = dark
reopen.Visible = false
reopen.Parent = gui

local reopenCorner = Instance.new("UICorner")
reopenCorner.CornerRadius = UDim.new(0, 10)
reopenCorner.Parent = reopen

local reopenStroke = Instance.new("UIStroke")
reopenStroke.Color = cyan
reopenStroke.Parent = reopen

-- เปิด/ปิดเนื้อหา
local enabled = true

toggle.Activated:Connect(function()
enabled = not enabled
status.Visible = enabled
footer.Visible = enabled

toggle.Text = enabled
and "ปิดระบบแสดงข้อความ"
or "เปิดระบบแสดงข้อความ"

status.Text = enabled
and "สถานะ: เปิด\nMy First UI พร้อมใช้งาน"
or "สถานะ: ปิดการแสดงข้อความ"
end)

-- ย่อ/ขยาย
local minimized = false

minimize.Activated:Connect(function()
minimized = not minimized

toggle.Visible = not minimized
status.Visible = not minimized and enabled
footer.Visible = not minimized and enabled

frame.Size = minimized
and UDim2.fromOffset(280, 42)
or UDim2.fromOffset(280, 220)

minimize.Text = minimized and "+" or "-"
end)
