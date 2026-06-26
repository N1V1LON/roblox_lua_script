-- N1V1LON test loader
local baseUrl = "https://raw.githubusercontent.com/N1V1LON/roblox_lua_script/main/scripts_beta/"

local widgets = {
	"widget_speed.lua",
	"widget_infjump.lua",
	"widget_checkpoints.lua",
	"widget_autoattack.lua",
}

local uis = game:GetService("UserInputService")
local rs = game:GetService("RunService")

_G.N1V1LON = _G.N1V1LON or {}
if _G.N1V1LON.cleanup then
	for _, fn in ipairs(_G.N1V1LON.cleanup) do
		pcall(fn)
	end
end
_G.N1V1LON.cleanup = {}
_G.N1V1LON.logs = {}

local function addLog(msg)
	local t = os.time()
	local info = ""
	local ok, result = pcall(function()
		local s = game:GetService("HttpService")
		info = s:FormatUtc(s:GetCurrentDateTime(), "!time")
	end)
	if not ok then info = tostring(t) end
	table.insert(_G.N1V1LON.logs, "[" .. info .. "] " .. msg)
end

local ok, err = pcall(function()
	local player = game:GetService("Players").LocalPlayer
	if not player then return end

	addLog("Player found: " .. player.Name)

	local pg = player:WaitForChild("PlayerGui", 10)
	if not pg then return end

	local existing = pg:FindFirstChild("N1V1LON")
	if existing then existing:Destroy(); addLog("Old GUI destroyed") end

	local gui = Instance.new("ScreenGui")
	gui.Name = "N1V1LON"
	gui.ResetOnSpawn = false
	gui.Parent = pg

	local icon = Instance.new("TextButton")
	icon.Name = "Icon"
	icon.Size = UDim2.new(0, 48, 0, 48)
	icon.Position = UDim2.new(1, -68, 0, 20)
	icon.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
	icon.BorderSizePixel = 0
	icon.Text = "N"
	icon.TextColor3 = Color3.fromRGB(220, 220, 255)
	icon.TextSize = 28
	icon.Font = Enum.Font.GothamBold
	icon.Draggable = true
	icon.Parent = gui
	Instance.new("UICorner", icon).CornerRadius = UDim.new(0, 12)

	local menu = Instance.new("Frame")
	menu.Name = "Menu"
	menu.Size = UDim2.new(0, 300, 0, 300)
	menu.Position = UDim2.new(0.5, -150, 0.5, -150)
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
	title.Size = UDim2.new(0, 140, 1, 0)
	title.Position = UDim2.new(0, 8, 0, 0)
	title.BackgroundTransparency = 1
	title.Text = "N1V1LON (test)"
	title.TextColor3 = Color3.fromRGB(220, 220, 255)
	title.TextSize = 11
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Font = Enum.Font.GothamBold
	title.Parent = titleBar

	local logBtn = Instance.new("TextButton")
	logBtn.Size = UDim2.new(0, 28, 1, 0)
	logBtn.Position = UDim2.new(1, -64, 0, 0)
	logBtn.BackgroundTransparency = 1
	logBtn.Text = "^"
	logBtn.TextColor3 = Color3.fromRGB(100, 200, 255)
	logBtn.TextSize = 18
	logBtn.Font = Enum.Font.GothamBold
	logBtn.Parent = titleBar

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

	icon.MouseButton1Click:Connect(function()
		menu.Visible = not menu.Visible
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

	for _, name in ipairs(widgets) do
		local url = baseUrl .. name
		local success, fn = pcall(function()
			return loadstring(game:HttpGet(url, true))()
		end)
		if success and type(fn) == "function" then
			pcall(fn, container, player, uis, rs)
			addLog("Loaded: " .. name)
		else
			warn("N1V1LON: failed to load " .. name)
			addLog("FAILED: " .. name)
		end
	end

	logBtn.MouseButton1Click:Connect(function()
		local dataLines = {}
		table.insert(dataLines, "=== N1V1LON Debug Log ===")
		table.insert(dataLines, "Version: v26.2.1.0 Realse")
		table.insert(dataLines, "Build: beta (scripts_beta)")
		table.insert(dataLines, "")
		table.insert(dataLines, "--- Game Info ---")
		local ok, gName = pcall(function() return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name end)
		table.insert(dataLines, "Game: " .. (ok and gName or "unknown"))
		table.insert(dataLines, "PlaceId: " .. game.PlaceId)
		table.insert(dataLines, "JobId: " .. game.JobId)
		table.insert(dataLines, "CreatorId: " .. game.CreatorId)
		table.insert(dataLines, "")
		table.insert(dataLines, "--- Player ---")
		table.insert(dataLines, "Name: " .. player.Name)
		table.insert(dataLines, "UserId: " .. player.UserId)
		table.insert(dataLines, "AccountAge: " .. player.AccountAge)
		local char = player.Character
		if char then
			local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
			if root then
				table.insert(dataLines, "Position: " .. tostring(root.Position))
			end
			table.insert(dataLines, "Character: " .. char.Name)
			local hum = char:FindFirstChildOfClass("Humanoid")
			if hum then
				table.insert(dataLines, "Health: " .. hum.Health .. "/" .. hum.MaxHealth)
				table.insert(dataLines, "WalkSpeed: " .. hum.WalkSpeed)
			end
		end
		table.insert(dataLines, "")
		table.insert(dataLines, "--- Inventory ---")
		local backpack = player:FindFirstChild("Backpack")
		if backpack then
			for _, item in ipairs(backpack:GetChildren()) do
				table.insert(dataLines, "  [Backpack] " .. item.Name .. " (" .. item.ClassName .. ")")
			end
		end
		if char then
			for _, item in ipairs(char:GetChildren()) do
				if item:IsA("Tool") or item:IsA("Accoutrement") or item:IsA("Accessory") then
					table.insert(dataLines, "  [Char] " .. item.Name .. " (" .. item.ClassName .. ")")
				end
			end
		end
		table.insert(dataLines, "")
		table.insert(dataLines, "--- Nearby Parts (30 studs) ---")
		if char then
			local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
			if root then
				local pos = root.Position
				local count = 0
				for _, part in ipairs(workspace:GetDescendants()) do
					if part:IsA("BasePart") and not part:IsA("Terrain") then
						local dist = (part.Position - pos).Magnitude
						if dist < 30 then
							count = count + 1
							if count <= 50 then
								table.insert(dataLines, "  " .. part.Name .. " (" .. part.ClassName .. ") at " .. tostring(part.Position))
							end
						end
					end
				end
				table.insert(dataLines, "  Total nearby: " .. count)
			end
		end
		table.insert(dataLines, "")
		table.insert(dataLines, "--- Runtime Logs ---")
		for _, line in ipairs(_G.N1V1LON.logs) do
			table.insert(dataLines, line)
		end
		table.insert(dataLines, "")
		table.insert(dataLines, "--- Players ---")
		for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
			local info = p.Name
			local c = p.Character
			if c then
				local h = c:FindFirstChildOfClass("Humanoid")
				if h then info = info .. " HP:" .. math.floor(h.Health) end
			end
			table.insert(dataLines, "  " .. info)
		end
		table.insert(dataLines, "")
		table.insert(dataLines, "=== End ===")

		local fullText = table.concat(dataLines, "\n")
		addLog("Log collected (" .. #dataLines .. " lines)")

		local saved = false
		local savePath = ""

		local attempts = {
			"logsave/log_save.txt",
			"N1V1LON_log_save.txt",
			"../logsave/log_save.txt",
			"/logsave/log_save.txt",
		}
		for _, path in ipairs(attempts) do
			if not saved then
				local okW = pcall(function()
					writefile(path, fullText)
					saved = true
					savePath = path
				end)
			end
		end
		if saved then
			addLog("Saved to " .. savePath)
			warn("N1V1LON: log saved to " .. savePath)
		else
			warn("N1V1LON: writefile not available, log printed below")
		end

		warn("=== N1V1LON LOG (" .. tostring(saved) .. ") ===")
		warn(fullText)
		warn("=== END LOG ===")
	end)
end)

if not ok then
	warn("N1V1LON error: " .. tostring(err))
end
