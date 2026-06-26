local ok, err = pcall(function()
	rconsolecreate()
	rconsolesettitle("N1V1LON")
	rconsoleclear()
end)

local log = function(msg)
	if ok then
		rconsoleprint(msg .. "\n")
	else
		print(msg)
	end
end

log("=== N1V1LON ===")
log("[INFO] Starting...")

local env = getgenv and getgenv() or {}
env.N1V1LON = {}

local player = game:GetService("Players").LocalPlayer
if not player then
	log("[ERROR] Player not found")
	return
end

local gui = Instance.new("ScreenGui")
gui.Name = "N1V1LON"
gui.ResetOnSpawn = false

local success, err = pcall(function()
	gui.Parent = player:WaitForChild("PlayerGui", 10)
end)

if not success then
	log("[ERROR] PlayerGui not found: " .. tostring(err))
	gui.Parent = game:GetService("CoreGui")
end

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

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 32)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
titleBar.BackgroundTransparency = 0.2
titleBar.BorderSizePixel = 0
titleBar.Parent = frame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = titleBar

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
container.CanvasSize = UDim2.new(0, 0, 0, 0)
container.AutomaticCanvasSize = Enum.AutomaticSize.Y
container.Parent = frame

local uiList = Instance.new("UIListLayout")
uiList.Padding = UDim.new(0, 6)
uiList.SortOrder = Enum.SortOrder.LayoutOrder
uiList.Parent = container

log("[OK] Loaded")
