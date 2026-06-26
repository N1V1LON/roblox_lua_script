local player = game:GetService("Players").LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "N1V1LON"
gui.ResetOnSpawn = false
gui.Parent = player.PlayerGui

local icon = Instance.new("TextButton")
icon.Name = "Icon"
icon.Size = UDim2.new(0, 16, 0, 16)
icon.Position = UDim2.new(0, 10, 0.5, -8)
icon.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
icon.BorderSizePixel = 0
icon.Text = "N"
icon.TextColor3 = Color3.fromRGB(220, 220, 255)
icon.TextSize = 10
icon.Font = Enum.Font.GothamBold
icon.Draggable = true
icon.Parent = gui
Instance.new("UICorner", icon).CornerRadius = UDim.new(0, 4)

local menu = Instance.new("Frame")
menu.Name = "Menu"
menu.Size = UDim2.new(0, 450, 0, 350)
menu.Position = UDim2.new(0.5, -225, 0.5, -175)
menu.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
menu.BorderSizePixel = 0
menu.Visible = false
menu.Parent = gui
Instance.new("UICorner", menu).CornerRadius = UDim.new(0, 10)

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 32)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
titleBar.BorderSizePixel = 0
titleBar.Parent = menu
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -40, 1, 0)
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
	menu.Visible = false
end)

local container = Instance.new("ScrollingFrame")
container.Size = UDim2.new(1, -20, 1, -52)
container.Position = UDim2.new(0, 10, 0, 42)
container.BackgroundTransparency = 1
container.BorderSizePixel = 0
container.ScrollBarThickness = 4
container.CanvasSize = UDim2.new(0, 0, 0, 0)
container.AutomaticCanvasSize = Enum.AutomaticSize.Y
container.Parent = menu
Instance.new("UIListLayout", container).Padding = UDim.new(0, 6)

icon.MouseButton1Click:Connect(function()
	menu.Visible = not menu.Visible
end)
