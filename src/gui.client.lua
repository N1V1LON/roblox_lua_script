local player = game:GetService("Players").LocalPlayer
local mouse = player:GetMouse()

local gui = Instance.new("ScreenGui")
gui.Name = "N1V1LON"
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 450, 0, 350)
frame.Position = UDim2.new(0.5, -225, 0.5, -175)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
frame.BackgroundTransparency = 0.1
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

local shadow = Instance.new("ImageLabel")
shadow.Size = UDim2.new(1, 20, 1, 20)
shadow.Position = UDim2.new(0, -10, 0, -10)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://6014261993"
shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
shadow.ImageTransparency = 0.6
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(10, 10, 10, 10)
shadow.ZIndex = -1
shadow.Parent = frame

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 32)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
titleBar.BackgroundTransparency = 0.2
titleBar.BorderSizePixel = 0
titleBar.Parent = frame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = titleBar
local titleBarTop = Instance.new("UIStroke")
titleBarTop.Thickness = 1
titleBarTop.Color = Color3.fromRGB(40, 40, 60)
titleBarTop.Parent = titleBar

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -40, 1, 0)
title.Position = UDim2.new(0, 12, 0, 0)
title.BackgroundTransparency = 1
title.Text = "N1V1LON"
title.TextColor3 = Color3.fromRGB(220, 220, 255)
title.TextSize = 15
title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.GothamBold
title.Parent = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 32, 1, 0)
closeBtn.Position = UDim2.new(1, -32, 0, 0)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(200, 60, 60)
closeBtn.TextSize = 18
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = titleBar

closeBtn.MouseButton1Click:Connect(function()
	gui:Destroy()
end)

local container = Instance.new("ScrollingFrame")
container.Size = UDim2.new(1, -20, 1, -52)
container.Position = UDim2.new(0, 10, 0, 42)
container.BackgroundTransparency = 1
container.BorderSizePixel = 0
container.ScrollBarThickness = 4
container.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 85)
container.ScrollBarImageTransparency = 0.5
container.CanvasSize = UDim2.new(0, 0, 0, 0)
container.AutomaticCanvasSize = Enum.AutomaticSize.Y
container.Parent = frame

local uiList = Instance.new("UIListLayout")
uiList.Padding = UDim.new(0, 6)
uiList.SortOrder = Enum.SortOrder.LayoutOrder
uiList.Parent = container

local padding = Instance.new("UIPadding")
padding.PaddingLeft = UDim.new(0, 4)
padding.PaddingRight = UDim.new(0, 4)
padding.Parent = container

local status = Instance.new("TextLabel")
status.Name = "Status"
status.Size = UDim2.new(1, 0, 0, 20)
status.BackgroundTransparency = 1
status.Text = "Loading..."
status.TextColor3 = Color3.fromRGB(140, 140, 180)
status.TextSize = 12
status.TextXAlignment = Enum.TextXAlignment.Left
status.Font = Enum.Font.Gotham
status.Parent = container
