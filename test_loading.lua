-- N1V1LON Interface with Tabs (single-file beta)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

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
	if not player then return end

	local function chatLocal(msg, color)
		local char = player.Character
		if not char then return end
		local head = char:FindFirstChild("Head")
		if not head then return end
		local chat = game:GetService("Chat")
		pcall(function()
			chat:Chat(head, msg, color or Color3.fromRGB(200, 200, 255))
		end)
	end

	addLog("Player found: " .. player.Name)

	local pg = player:WaitForChild("PlayerGui", 10)
	if not pg then return end

	local existing = pg:FindFirstChild("N1V1LON")
	if existing then existing:Destroy(); addLog("Old GUI destroyed") end

	-- Block check
	local blockUrl = "https://raw.githubusercontent.com/N1V1LON/roblox_lua_script/main/users/players.lua"
	local okB, blockRaw = pcall(function()
		return game:HttpGet(blockUrl, true)
	end)
	if okB and blockRaw then
		local okFn, playersTbl = pcall(loadstring, blockRaw)
		if okFn and type(playersTbl) == "table" then
			local pData = playersTbl[player.UserId]
			if pData and pData.blocked == true then
				warn("N1V1LON: blocked " .. player.Name .. " (" .. player.UserId .. ")")
				chatLocal("N1V1LON: access blocked", Color3.fromRGB(255, 50, 50))
				return
			end
		end
	end

	local gui = Instance.new("ScreenGui")
	gui.Name = "N1V1LON"
	gui.ResetOnSpawn = false
	gui.Parent = pg

	-- Periodic block check
	task.spawn(function()
		while gui and gui.Parent do
			task.wait(5)
			local okB2, raw2 = pcall(function()
				return game:HttpGet(blockUrl, true)
			end)
			if okB2 and raw2 then
				local okFn2, tbl2 = pcall(loadstring, raw2)
				if okFn2 and type(tbl2) == "table" then
					local pData2 = tbl2[player.UserId]
					if pData2 and pData2.blocked == true then
						warn("N1V1LON: blocked " .. player.Name .. " (" .. player.UserId .. ")")
						chatLocal("N1V1LON: access blocked", Color3.fromRGB(255, 50, 50))
						if gui then pcall(function() gui:Destroy() end) end
						_G.N1V1LON.blocked = true
						return
					end
				end
			end
		end
	end)

	-- Message system
	local msgFrame = Instance.new("Frame")
	msgFrame.Size = UDim2.new(0.6, 0, 0, 24)
	msgFrame.Position = UDim2.new(0.2, 0, 0, 60)
	msgFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	msgFrame.BackgroundTransparency = 0.3
	msgFrame.BorderSizePixel = 0
	msgFrame.Parent = gui
	Instance.new("UICorner", msgFrame).CornerRadius = UDim.new(0, 6)

	local msgLabel = Instance.new("TextLabel")
	msgLabel.Size = UDim2.new(1, -12, 1, 0)
	msgLabel.Position = UDim2.new(0, 6, 0, 0)
	msgLabel.BackgroundTransparency = 1
	msgLabel.Text = ""
	msgLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	msgLabel.TextSize = 12
	msgLabel.TextXAlignment = Enum.TextXAlignment.Left
	msgLabel.Font = Enum.Font.Gotham
	msgLabel.Parent = msgFrame
	msgFrame.Visible = false

	_G.N1V1LON.showMsg = function(text)
		msgLabel.Text = text
		msgFrame.Visible = true
		msgFrame.BackgroundTransparency = 0.3
		task.delay(3, function()
			for i = 0, 20 do
				msgFrame.BackgroundTransparency = 0.3 + (i / 20) * 0.7
				msgLabel.TextTransparency = i / 20
				task.wait(0.05)
			end
			msgFrame.Visible = false
			msgLabel.TextTransparency = 0
		end)
	end

	-- Icon Button
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

	-- Menu Frame
	local menu = Instance.new("Frame")
	menu.Name = "Menu"
	menu.Size = UDim2.new(0, 340, 0, 480)
	menu.Position = UDim2.new(0.5, -170, 0.5, -240)
	menu.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	menu.BorderSizePixel = 0
	menu.Visible = false
	menu.Parent = gui
	Instance.new("UICorner", menu).CornerRadius = UDim.new(0, 10)

	-- Title Bar
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
	title.Text = "N1V1LON"
	title.TextColor3 = Color3.fromRGB(220, 220, 255)
	title.TextSize = 11
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Font = Enum.Font.GothamBold
	title.Parent = titleBar

	local betaBtn = Instance.new("TextButton")
	betaBtn.Size = UDim2.new(0, 28, 1, 0)
	betaBtn.Position = UDim2.new(1, -96, 0, 0)
	betaBtn.BackgroundTransparency = 1
	betaBtn.Text = "β"
	betaBtn.TextColor3 = Color3.fromRGB(255, 200, 50)
	betaBtn.TextSize = 18
	betaBtn.Font = Enum.Font.GothamBold
	betaBtn.Parent = titleBar

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

	-- Tabs
	local tabsFrame = Instance.new("Frame")
	tabsFrame.Size = UDim2.new(1, 0, 0, 32)
	tabsFrame.Position = UDim2.new(0, 0, 0, 32)
	tabsFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
	tabsFrame.BorderSizePixel = 0
	tabsFrame.Parent = menu

	local tabPlayer = Instance.new("TextButton")
	tabPlayer.Size = UDim2.new(1/3, 0, 1, 0)
	tabPlayer.Position = UDim2.new(0, 0, 0, 0)
	tabPlayer.BackgroundTransparency = 1
	tabPlayer.Text = "Player"
	tabPlayer.TextColor3 = Color3.fromRGB(120, 120, 160)
	tabPlayer.TextSize = 11
	tabPlayer.Font = Enum.Font.GothamBold
	tabPlayer.Parent = tabsFrame

	local tabServer = Instance.new("TextButton")
	tabServer.Size = UDim2.new(1/3, 0, 1, 0)
	tabServer.Position = UDim2.new(1/3, 0, 0, 0)
	tabServer.BackgroundTransparency = 1
	tabServer.Text = "Server"
	tabServer.TextColor3 = Color3.fromRGB(120, 120, 160)
	tabServer.TextSize = 11
	tabServer.Font = Enum.Font.GothamBold
	tabServer.Parent = tabsFrame

	local tabSettings = Instance.new("TextButton")
	tabSettings.Size = UDim2.new(1/3, 0, 1, 0)
	tabSettings.Position = UDim2.new(2/3, 0, 0, 0)
	tabSettings.BackgroundTransparency = 1
	tabSettings.Text = "Settings"
	tabSettings.TextColor3 = Color3.fromRGB(120, 120, 160)
	tabSettings.TextSize = 11
	tabSettings.Font = Enum.Font.GothamBold
	tabSettings.Parent = tabsFrame

	-- Content Container
	local content = Instance.new("ScrollingFrame")
	content.Size = UDim2.new(1, -20, 1, -74)
	content.Position = UDim2.new(0, 10, 0, 74)
	content.BackgroundTransparency = 1
	content.BorderSizePixel = 0
	content.ScrollBarThickness = 4
	content.CanvasSize = UDim2.new(0, 0, 0, 0)
	content.AutomaticCanvasSize = Enum.AutomaticSize.Y
	content.Parent = menu
	Instance.new("UIListLayout", content).Padding = UDim.new(0, 6)

	-- Tab Contents
	local playerTab = Instance.new("Frame")
	playerTab.Size = UDim2.new(1, 0, 0, 0)
	playerTab.BackgroundTransparency = 1
	playerTab.Visible = true
	playerTab.Parent = content
	local playerLayout = Instance.new("UIListLayout")
	playerLayout.Padding = UDim.new(0, 6)
	playerLayout.Parent = playerTab

	local serverTab = Instance.new("Frame")
	serverTab.Size = UDim2.new(1, 0, 0, 0)
	serverTab.BackgroundTransparency = 1
	serverTab.Visible = false
	serverTab.Parent = content
	local serverLayout = Instance.new("UIListLayout")
	serverLayout.Padding = UDim.new(0, 6)
	serverLayout.Parent = serverTab

	local settingsTab = Instance.new("Frame")
	settingsTab.Size = UDim2.new(1, 0, 0, 0)
	settingsTab.BackgroundTransparency = 1
	settingsTab.Visible = false
	settingsTab.Parent = content
	local settingsLayout = Instance.new("UIListLayout")
	settingsLayout.Padding = UDim.new(0, 6)
	settingsLayout.Parent = settingsTab

	-- Tab switching
	local function switchTab(activeTab)
		playerTab.Visible = false
		serverTab.Visible = false
		settingsTab.Visible = false

		tabPlayer.TextColor3 = Color3.fromRGB(120, 120, 160)
		tabServer.TextColor3 = Color3.fromRGB(120, 120, 160)
		tabSettings.TextColor3 = Color3.fromRGB(120, 120, 160)

		if activeTab == "player" then
			playerTab.Visible = true
			tabPlayer.TextColor3 = Color3.fromRGB(100, 200, 255)
		elseif activeTab == "server" then
			serverTab.Visible = true
			tabServer.TextColor3 = Color3.fromRGB(100, 200, 255)
		elseif activeTab == "settings" then
			settingsTab.Visible = true
			tabSettings.TextColor3 = Color3.fromRGB(100, 200, 255)
		end
	end

	tabPlayer.MouseButton1Click:Connect(function()
		switchTab("player")
	end)

	tabServer.MouseButton1Click:Connect(function()
		switchTab("server")
	end)

	tabSettings.MouseButton1Click:Connect(function()
		switchTab("settings")
	end)

	-- ==================== PLAYER TAB ====================

	-- Infinite Jump
	local infJumpOn = false
	local infJumpConn = nil
	local jumpReqConn = nil

	local infJumpBtn = Instance.new("TextButton")
	infJumpBtn.Size = UDim2.new(1, 0, 0, 32)
	infJumpBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
	infJumpBtn.BorderSizePixel = 0
	infJumpBtn.Text = "  Infinite Jump"
	infJumpBtn.TextColor3 = Color3.fromRGB(200, 200, 220)
	infJumpBtn.TextSize = 13
	infJumpBtn.TextXAlignment = Enum.TextXAlignment.Left
	infJumpBtn.Font = Enum.Font.Gotham
	infJumpBtn.Parent = playerTab
	Instance.new("UICorner", infJumpBtn).CornerRadius = UDim.new(0, 6)

	local infJumpStatus = Instance.new("TextLabel")
	infJumpStatus.Size = UDim2.new(0, 50, 1, 0)
	infJumpStatus.Position = UDim2.new(1, -55, 0, 0)
	infJumpStatus.BackgroundTransparency = 1
	infJumpStatus.Text = "OFF"
	infJumpStatus.TextColor3 = Color3.fromRGB(140, 60, 60)
	infJumpStatus.TextSize = 12
	infJumpStatus.Font = Enum.Font.GothamBold
	infJumpStatus.Parent = infJumpBtn

	infJumpBtn.MouseButton1Click:Connect(function()
		infJumpOn = not infJumpOn
		if infJumpOn then
			local function apply(char)
				local hum = char:FindFirstChildOfClass("Humanoid")
				if hum then
					hum.UseJumpPower = false
				end
			end
			local char = player.Character
			if char then apply(char) end
			infJumpConn = player.CharacterAdded:Connect(apply)
			jumpReqConn = UserInputService.JumpRequest:Connect(function()
				if infJumpOn then
					local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
					if hum then
						hum:ChangeState(Enum.HumanoidStateType.Jumping)
					end
				end
			end)
			infJumpStatus.Text = "ON"
			infJumpStatus.TextColor3 = Color3.fromRGB(60, 200, 120)
			addLog("InfJump ON")
			_G.N1V1LON.showMsg("InfJump ON")
		else
			if infJumpConn then infJumpConn:Disconnect(); infJumpConn = nil end
			if jumpReqConn then jumpReqConn:Disconnect(); jumpReqConn = nil end
			infJumpStatus.Text = "OFF"
			infJumpStatus.TextColor3 = Color3.fromRGB(140, 60, 60)
			addLog("InfJump OFF")
			_G.N1V1LON.showMsg("InfJump OFF")
		end
	end)

	-- Highlights Widget
	local highlightsFrame = Instance.new("Frame")
	highlightsFrame.Size = UDim2.new(1, 0, 0, 68)
	highlightsFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
	highlightsFrame.BorderSizePixel = 0
	highlightsFrame.Parent = playerTab
	Instance.new("UICorner", highlightsFrame).CornerRadius = UDim.new(0, 6)

	local highlightsTitle = Instance.new("TextLabel")
	highlightsTitle.Size = UDim2.new(0, 120, 0, 20)
	highlightsTitle.Position = UDim2.new(0, 8, 0, 4)
	highlightsTitle.BackgroundTransparency = 1
	highlightsTitle.Text = "  Highlights"
	highlightsTitle.TextColor3 = Color3.fromRGB(200, 200, 220)
	highlightsTitle.TextSize = 13
	highlightsTitle.TextXAlignment = Enum.TextXAlignment.Left
	highlightsTitle.Font = Enum.Font.Gotham
	highlightsTitle.Parent = highlightsFrame

	local npcBtnGroup = Instance.new("Frame")
	npcBtnGroup.Size = UDim2.new(0.5, -6, 0, 18)
	npcBtnGroup.Position = UDim2.new(0, 8, 0, 26)
	npcBtnGroup.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
	npcBtnGroup.BorderSizePixel = 0
	npcBtnGroup.Parent = highlightsFrame
	Instance.new("UICorner", npcBtnGroup).CornerRadius = UDim.new(0, 4)

	local npcLabel = Instance.new("TextLabel")
	npcLabel.Size = UDim2.new(0.7, -4, 1, 0)
	npcLabel.Position = UDim2.new(0, 6, 0, 0)
	npcLabel.BackgroundTransparency = 1
	npcLabel.Text = "NPC"
	npcLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
	npcLabel.TextSize = 12
	npcLabel.TextXAlignment = Enum.TextXAlignment.Left
	npcLabel.Font = Enum.Font.Gotham
	npcLabel.Parent = npcBtnGroup

	local npcStatus = Instance.new("TextLabel")
	npcStatus.Size = UDim2.new(0.3, -2, 1, 0)
	npcStatus.Position = UDim2.new(0.7, 2, 0, 0)
	npcStatus.BackgroundTransparency = 1
	npcStatus.Text = "OFF"
	npcStatus.TextColor3 = Color3.fromRGB(140, 60, 60)
	npcStatus.TextSize = 11
	npcStatus.TextXAlignment = Enum.TextXAlignment.Center
	npcStatus.Font = Enum.Font.GothamBold
	npcStatus.Parent = npcBtnGroup

	local itemBtnGroup = Instance.new("Frame")
	itemBtnGroup.Size = UDim2.new(0.5, -6, 0, 18)
	itemBtnGroup.Position = UDim2.new(0.5, 2, 0, 26)
	itemBtnGroup.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
	itemBtnGroup.BorderSizePixel = 0
	itemBtnGroup.Parent = highlightsFrame
	Instance.new("UICorner", itemBtnGroup).CornerRadius = UDim.new(0, 4)

	local itemLabel = Instance.new("TextLabel")
	itemLabel.Size = UDim2.new(0.7, -4, 1, 0)
	itemLabel.Position = UDim2.new(0, 6, 0, 0)
	itemLabel.BackgroundTransparency = 1
	itemLabel.Text = "Items"
	itemLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
	itemLabel.TextSize = 12
	itemLabel.TextXAlignment = Enum.TextXAlignment.Left
	itemLabel.Font = Enum.Font.Gotham
	itemLabel.Parent = itemBtnGroup

	local itemStatus = Instance.new("TextLabel")
	itemStatus.Size = UDim2.new(0.3, -2, 1, 0)
	itemStatus.Position = UDim2.new(0.7, 2, 0, 0)
	itemStatus.BackgroundTransparency = 1
	itemStatus.Text = "OFF"
	itemStatus.TextColor3 = Color3.fromRGB(140, 60, 60)
	itemStatus.TextSize = 11
	itemStatus.TextXAlignment = Enum.TextXAlignment.Center
	itemStatus.Font = Enum.Font.GothamBold
	itemStatus.Parent = itemBtnGroup

	local infoLabel = Instance.new("TextLabel")
	infoLabel.Size = UDim2.new(1, -16, 0, 14)
	infoLabel.Position = UDim2.new(0, 8, 0, 48)
	infoLabel.BackgroundTransparency = 1
	infoLabel.Text = ""
	infoLabel.TextColor3 = Color3.fromRGB(120, 120, 160)
	infoLabel.TextSize = 10
	infoLabel.TextXAlignment = Enum.TextXAlignment.Left
	infoLabel.Font = Enum.Font.Gotham
	infoLabel.Parent = highlightsFrame

	local npcOn = false
	local itemsOn = false
	local npcHighlights = {}
	local itemHighlights = {}

	local npcNames = {
		"Alpha Wolf", "Wolf", "Crossbow Cultist", "Cultist",
		"Bunny", "Bear", "Polar Bear",
	}

	local itemNames = {
		"Apple", "Berry", "Bolt", "Broken Fan", "Broken Microwave",
		"Bunny Foot", "Cake", "Carrot", "Chest", "Chilli", "Coal",
		"Coin Stack", "Cultist Gem", "Deer", "Fuel Canister",
		"Good Sack", "Good Axe", "Iron Body", "Item Chest",
		"Item Chest2", "Item Chest3", "Item Chest4", "Item Chest6",
		"Leather Body", "Log", "Medkit", "Meat? Sandwich", "Morsel",
		"Old Car Engine", "Old Flashlight", "Old Radio", "Oil Barrel",
		"Revolver", "Revolver Ammo", "Rifle", "Rifle Ammo",
		"Riot Shield", "Sapling", "Seed Box", "Sheet Metal", "Spear",
		"Steak", "Stronghold Diamond Chest", "Tyre", "Washing Machine",
		"Wolf Corpse", "Wolf Pelt", "Alpha Wolf Pelt", "Bandage",
		"Anvil Base", "Lost Child", "Lost Child2", "Lost Child3",
		"Lost Child4",
	}

	local function inList(name, list)
		for _, v in ipairs(list) do
			if v == name then return true end
		end
		return false
	end

	local function toggleNPC()
		if npcOn then
			for _, hl in ipairs(npcHighlights) do
				pcall(function() hl:Destroy() end)
			end
			npcHighlights = {}
			npcOn = false
			npcStatus.Text = "OFF"
			npcStatus.TextColor3 = Color3.fromRGB(140, 60, 60)
			npcBtnGroup.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
			infoLabel.Text = ""
			addLog("NPC highlight OFF")
			_G.N1V1LON.showMsg("NPC highlight OFF")
		else
			local count = 0
			for _, obj in ipairs(workspace:GetDescendants()) do
				if obj:IsA("Model") and inList(obj.Name, npcNames) then
					if not obj:FindFirstChildOfClass("Humanoid") then continue end
					local hl = Instance.new("Highlight")
					hl.Name = "N1V1LON_NPC"
					hl.FillColor = Color3.fromRGB(255, 50, 50)
					hl.FillTransparency = 0.5
					hl.OutlineColor = Color3.fromRGB(255, 200, 50)
					hl.OutlineTransparency = 0.3
					hl.Parent = obj
					hl.Adornee = obj
					table.insert(npcHighlights, hl)
					count = count + 1
				end
			end
			npcOn = true
			npcStatus.Text = "ON"
			npcStatus.TextColor3 = Color3.fromRGB(60, 200, 120)
			npcBtnGroup.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
			infoLabel.Text = "NPC: " .. count
			addLog("NPC ON — " .. count)
			_G.N1V1LON.showMsg("NPC ON — " .. count .. " найдено")
		end
	end

	local function toggleItems()
		if itemsOn then
			for _, hl in ipairs(itemHighlights) do
				pcall(function() hl:Destroy() end)
			end
			itemHighlights = {}
			itemsOn = false
			itemStatus.Text = "OFF"
			itemStatus.TextColor3 = Color3.fromRGB(140, 60, 60)
			itemBtnGroup.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
			infoLabel.Text = ""
			addLog("Items highlight OFF")
			_G.N1V1LON.showMsg("Items highlight OFF")
		else
			local count = 0
			local samples = {}
			for _, obj in ipairs(workspace:GetDescendants()) do
				if inList(obj.Name, itemNames) then
					local hl = Instance.new("Highlight")
					hl.Name = "N1V1LON_Item"
					hl.FillColor = Color3.fromRGB(50, 150, 255)
					hl.FillTransparency = 0.4
					hl.OutlineColor = Color3.fromRGB(255, 255, 100)
					hl.OutlineTransparency = 0.2
					hl.Parent = obj
					hl.Adornee = obj
					table.insert(itemHighlights, hl)
					count = count + 1
					if #samples < 5 then table.insert(samples, obj.Name) end
				end
			end
			itemsOn = true
			itemStatus.Text = "ON"
			itemStatus.TextColor3 = Color3.fromRGB(60, 200, 120)
			itemBtnGroup.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
			if #samples > 0 then
				infoLabel.Text = "Items: " .. count .. " (" .. table.concat(samples, ", ") .. ")"
				addLog("Items ON — " .. count)
				_G.N1V1LON.showMsg("Items ON — " .. count .. " (" .. table.concat(samples, ", ") .. ")")
			else
				infoLabel.Text = "Items: " .. count
				addLog("Items ON — " .. count)
				_G.N1V1LON.showMsg("Items ON — " .. count)
			end
		end
	end

	npcBtnGroup.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			toggleNPC()
		end
	end)

	itemBtnGroup.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			toggleItems()
		end
	end)

	-- Aimbot Widget
	local aimOn = false
	local zoneRadius = 50
	local hitCount = 5
	local damagePower = 15
	local aimConn = nil
	local spherePart = nil
	local sphereConn = nil

	local aimbotFrame = Instance.new("Frame")
	aimbotFrame.Size = UDim2.new(1, 0, 0, 106)
	aimbotFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
	aimbotFrame.BorderSizePixel = 0
	aimbotFrame.Parent = playerTab
	Instance.new("UICorner", aimbotFrame).CornerRadius = UDim.new(0, 6)

	local aimbotTitle = Instance.new("TextLabel")
	aimbotTitle.Size = UDim2.new(0, 120, 0, 20)
	aimbotTitle.Position = UDim2.new(0, 8, 0, 4)
	aimbotTitle.BackgroundTransparency = 1
	aimbotTitle.Text = "  Aimbot"
	aimbotTitle.TextColor3 = Color3.fromRGB(200, 200, 220)
	aimbotTitle.TextSize = 13
	aimbotTitle.TextXAlignment = Enum.TextXAlignment.Left
	aimbotTitle.Font = Enum.Font.Gotham
	aimbotTitle.Parent = aimbotFrame

	local aimbotStatus = Instance.new("TextButton")
	aimbotStatus.Size = UDim2.new(0, 50, 0, 20)
	aimbotStatus.Position = UDim2.new(1, -55, 0, 4)
	aimbotStatus.BackgroundTransparency = 1
	aimbotStatus.Text = "OFF"
	aimbotStatus.TextColor3 = Color3.fromRGB(140, 60, 60)
	aimbotStatus.TextSize = 12
	aimbotStatus.Font = Enum.Font.GothamBold
	aimbotStatus.Parent = aimbotFrame

	-- Slider function
	local function makeSlider(parent, yPos, label, getter, setter, maxVal, barColor, labelColor)
		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(0, 130, 0, 14)
		lbl.Position = UDim2.new(0, 8, 0, yPos)
		lbl.BackgroundTransparency = 1
		lbl.Text = label .. tostring(getter())
		lbl.TextColor3 = labelColor
		lbl.TextSize = 11
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Font = Enum.Font.Gotham
		lbl.Parent = parent

		local bar = Instance.new("TextButton")
		bar.Size = UDim2.new(1, -20, 0, 8)
		bar.Position = UDim2.new(0, 10, 0, yPos + 16)
		bar.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
		bar.BorderSizePixel = 0
		bar.Text = ""
		bar.AutoButtonColor = false
		bar.Parent = parent
		Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 3)

		local fill = Instance.new("Frame")
		fill.Size = UDim2.new(getter() / maxVal, 0, 1, 0)
		fill.BackgroundColor3 = barColor
		fill.BorderSizePixel = 0
		fill.Parent = bar
		Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 3)

		bar.MouseButton1Click:Connect(function()
			local mx = UserInputService:GetMouseLocation().X
			local px = bar.AbsolutePosition.X
			local sx = bar.AbsoluteSize.X
			if sx > 0 then
				local frac = math.clamp((mx - px) / sx, 0, 1)
				local val = math.max(1, math.floor(frac * maxVal))
				if maxVal == 500 then val = math.max(5, val) end
				setter(val)
				lbl.Text = label .. tostring(getter())
				fill.Size = UDim2.new(frac, 0, 1, 0)
			end
		end)

		return lbl, bar, fill
	end

	makeSlider(aimbotFrame, 24, "Zone: ", function() return zoneRadius end, function(v) zoneRadius = v end, 500, Color3.fromRGB(60, 200, 120), Color3.fromRGB(160, 200, 160))
	makeSlider(aimbotFrame, 50, "Hits: ", function() return hitCount end, function(v) hitCount = v end, 50, Color3.fromRGB(200, 200, 100), Color3.fromRGB(200, 200, 100))
	makeSlider(aimbotFrame, 76, "Damage: ", function() return damagePower end, function(v) damagePower = v end, 100, Color3.fromRGB(200, 100, 100), Color3.fromRGB(200, 120, 120))

	local function createSphere()
		if spherePart then pcall(function() spherePart:Destroy() end) end
		spherePart = Instance.new("Part")
		spherePart.Name = "N1V1LON_Sphere"
		spherePart.Shape = Enum.PartType.Ball
		spherePart.Size = Vector3.new(zoneRadius * 2, zoneRadius * 2, zoneRadius * 2)
		spherePart.Anchored = true
		spherePart.CanCollide = false
		spherePart.Transparency = 0.85
		spherePart.Color = Color3.fromRGB(100, 200, 255)
		spherePart.Material = Enum.Material.Neon
		spherePart.Parent = workspace

		if sphereConn then sphereConn:Disconnect() end
		sphereConn = RunService.RenderStepped:Connect(function()
			if not aimOn or not spherePart then
				if sphereConn then sphereConn:Disconnect(); sphereConn = nil end
				return
			end
			local char = player.Character
			if char then
				local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
				if root then
					spherePart.Position = root.Position
					spherePart.Size = Vector3.new(zoneRadius * 2, zoneRadius * 2, zoneRadius * 2)
				end
			end
		end)
	end

	local function destroySphere()
		if sphereConn then sphereConn:Disconnect(); sphereConn = nil end
		if spherePart then pcall(function() spherePart:Destroy() end); spherePart = nil end
	end

	local function getNPCPos(parent)
		local r = parent:FindFirstChild("HumanoidRootPart") or parent:FindFirstChild("Torso")
		if r then return r.Position end
		if parent:IsA("BasePart") then return parent.Position end
		if parent.PrimaryPart then return parent.PrimaryPart.Position end
		for _, child in ipairs(parent:GetChildren()) do
			if child:IsA("BasePart") then
				return child.Position
			end
		end
		return nil
	end

	local function doAimbot()
		local char = player.Character
		if not char then return end
		local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
		if not root then return end
		local pos = root.Position

		local targets = {}
		for _, obj in ipairs(workspace:GetDescendants()) do
			if not obj:IsA("Model") then continue end
			if not inList(obj.Name, npcNames) then continue end
			local hum = obj:FindFirstChildOfClass("Humanoid")
			if not hum or hum.Health <= 0 then continue end
			local npcPos = getNPCPos(obj)
			if npcPos and (npcPos - pos).Magnitude <= zoneRadius then
				table.insert(targets, hum)
			end
		end

		_G.N1V1LON.showMsg("Aimbot: " .. #targets .. " NPC, " .. damagePower .. " dmg x" .. hitCount)
		addLog("Aimbot: " .. #targets .. " targets, " .. damagePower .. " dmg x" .. hitCount)
		for h = 1, hitCount do
			for _, nhum in ipairs(targets) do
				if nhum.Health > 0 then
					nhum.Health = nhum.Health - damagePower
					if nhum.Health <= 0 then
						pcall(function() nhum:BreakJoints() end)
					end
				end
			end
		end
	end

	aimbotStatus.MouseButton1Click:Connect(function()
		aimOn = not aimOn
		if aimOn then
			aimbotStatus.Text = "ON"
			aimbotStatus.TextColor3 = Color3.fromRGB(60, 200, 120)
			createSphere()
			addLog("Aimbot ON — zone " .. zoneRadius)
			_G.N1V1LON.showMsg("Aimbot ON — zone " .. zoneRadius)
			if aimConn then aimConn:Disconnect() end
			aimConn = UserInputService.InputBegan:Connect(function(input, processed)
				if processed then return end
				if aimOn and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
					doAimbot()
				end
			end)
		else
			aimbotStatus.Text = "OFF"
			aimbotStatus.TextColor3 = Color3.fromRGB(140, 60, 60)
			destroySphere()
			addLog("Aimbot OFF")
			_G.N1V1LON.showMsg("Aimbot OFF")
			if aimConn then aimConn:Disconnect(); aimConn = nil end
		end
	end)

	-- ==================== SERVER TAB ====================

	-- Category Label
	local teleportLabel = Instance.new("TextLabel")
	teleportLabel.Size = UDim2.new(1, -8, 0, 20)
	teleportLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
	teleportLabel.BorderSizePixel = 0
	teleportLabel.Text = "   Teleport"
	teleportLabel.TextColor3 = Color3.fromRGB(150, 150, 200)
	teleportLabel.TextSize = 12
	teleportLabel.TextXAlignment = Enum.TextXAlignment.Left
	teleportLabel.Font = Enum.Font.GothamBold
	teleportLabel.Parent = serverTab
	Instance.new("UICorner", teleportLabel).CornerRadius = UDim.new(0, 4)

	-- Checkpoints Widget
	local checkpoints = {}

	local cpFrame = Instance.new("Frame")
	cpFrame.Size = UDim2.new(1, 0, 0, 120)
	cpFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
	cpFrame.BorderSizePixel = 0
	cpFrame.Parent = serverTab
	Instance.new("UICorner", cpFrame).CornerRadius = UDim.new(0, 6)

	local cpHeader = Instance.new("Frame")
	cpHeader.Size = UDim2.new(1, 0, 0, 20)
	cpHeader.BackgroundTransparency = 1
	cpHeader.Parent = cpFrame

	local cpLabel = Instance.new("TextLabel")
	cpLabel.Size = UDim2.new(0, 140, 1, 0)
	cpLabel.Position = UDim2.new(0, 8, 0, 0)
	cpLabel.BackgroundTransparency = 1
	cpLabel.Text = "  Checkpoints"
	cpLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
	cpLabel.TextSize = 13
	cpLabel.TextXAlignment = Enum.TextXAlignment.Left
	cpLabel.Font = Enum.Font.Gotham
	cpLabel.Parent = cpHeader

	local cpAddBtn = Instance.new("TextButton")
	cpAddBtn.Size = UDim2.new(0, 20, 0, 20)
	cpAddBtn.Position = UDim2.new(1, -26, 0, 0)
	cpAddBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
	cpAddBtn.BorderSizePixel = 0
	cpAddBtn.Text = "+"
	cpAddBtn.TextColor3 = Color3.fromRGB(160, 200, 160)
	cpAddBtn.TextSize = 14
	cpAddBtn.Font = Enum.Font.GothamBold
	cpAddBtn.Parent = cpHeader
	Instance.new("UICorner", cpAddBtn).CornerRadius = UDim.new(0, 3)

	local cpList = Instance.new("ScrollingFrame")
	cpList.Size = UDim2.new(1, -8, 1, -24)
	cpList.Position = UDim2.new(0, 4, 0, 22)
	cpList.BackgroundTransparency = 1
	cpList.BorderSizePixel = 0
	cpList.ScrollBarThickness = 3
	cpList.CanvasSize = UDim2.new(0, 0, 0, 0)
	cpList.Parent = cpFrame
	local cpLayout = Instance.new("UIListLayout")
	cpLayout.FillDirection = Enum.FillDirection.Vertical
	cpLayout.Padding = UDim.new(0, 2)
	cpLayout.Parent = cpList

	local function addCP()
		local char = player.Character
		if not char then return end
		local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
		if not root then return end
		local pos = root.Position
		local id = #checkpoints + 1

		local row = Instance.new("TextButton")
		row.Size = UDim2.new(1, -6, 0, 22)
		row.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
		row.BorderSizePixel = 0
		row.Text = "  CP " .. tostring(id) .. "  (" .. math.floor(pos.X) .. ", " .. math.floor(pos.Y) .. ", " .. math.floor(pos.Z) .. ")"
		row.TextColor3 = Color3.fromRGB(200, 200, 220)
		row.TextSize = 11
		row.Font = Enum.Font.Gotham
		row.TextXAlignment = Enum.TextXAlignment.Left
		row.Parent = cpList
		Instance.new("UICorner", row).CornerRadius = UDim.new(0, 3)

		local entry = { pos = pos, row = row, id = id }
		table.insert(checkpoints, entry)

		local held = false
		local holdTask = nil

		row.MouseButton1Down:Connect(function()
			held = false
			holdTask = task.delay(0.5, function()
				held = true
				row.BackgroundColor3 = Color3.fromRGB(80, 40, 40)
				task.delay(0.6, function()
					row:Destroy()
					for i, e in ipairs(checkpoints) do
						if e == entry then table.remove(checkpoints, i); break end
					end
				end)
			end)
		end)

		row.MouseButton1Up:Connect(function()
			if holdTask then task.cancel(holdTask); holdTask = nil end
			if not held then
				local c = player.Character
				if c then
					local r = c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso")
					if r then r.CFrame = CFrame.new(entry.pos) end
				end
				addLog("TP to CP #" .. id)
				_G.N1V1LON.showMsg("TP to CP #" .. id)
			end
		end)

		addLog("CP saved #" .. id .. " at " .. math.floor(pos.X) .. "," .. math.floor(pos.Y) .. "," .. math.floor(pos.Z))
		_G.N1V1LON.showMsg("CP saved #" .. id)
	end

	cpAddBtn.MouseButton1Click:Connect(function()
		addCP()
	end)

	-- ==================== SETTINGS TAB ====================

	-- Language Setting
	local langFrame = Instance.new("Frame")
	langFrame.Size = UDim2.new(1, 0, 0, 50)
	langFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
	langFrame.BorderSizePixel = 0
	langFrame.Parent = settingsTab
	Instance.new("UICorner", langFrame).CornerRadius = UDim.new(0, 6)

	local langLabel = Instance.new("TextLabel")
	langLabel.Size = UDim2.new(1, -16, 0, 14)
	langLabel.Position = UDim2.new(0, 8, 0, 6)
	langLabel.BackgroundTransparency = 1
	langLabel.Text = "Язык / Language"
	langLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
	langLabel.TextSize = 12
	langLabel.TextXAlignment = Enum.TextXAlignment.Left
	langLabel.Font = Enum.Font.Gotham
	langLabel.Parent = langFrame

	local langRuBtn = Instance.new("TextButton")
	langRuBtn.Size = UDim2.new(0.5, -6, 0, 24)
	langRuBtn.Position = UDim2.new(0, 8, 0, 22)
	langRuBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
	langRuBtn.BorderSizePixel = 2
	langRuBtn.BorderColor3 = Color3.fromRGB(100, 200, 255)
	langRuBtn.Text = "Русский ✓"
	langRuBtn.TextColor3 = Color3.fromRGB(200, 200, 220)
	langRuBtn.TextSize = 12
	langRuBtn.Font = Enum.Font.Gotham
	langRuBtn.Parent = langFrame
	Instance.new("UICorner", langRuBtn).CornerRadius = UDim.new(0, 4)

	local langEnBtn = Instance.new("TextButton")
	langEnBtn.Size = UDim2.new(0.5, -6, 0, 24)
	langEnBtn.Position = UDim2.new(0.5, 2, 0, 22)
	langEnBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
	langEnBtn.BorderSizePixel = 2
	langEnBtn.BorderColor3 = Color3.fromRGB(45, 45, 60)
	langEnBtn.Text = "English"
	langEnBtn.TextColor3 = Color3.fromRGB(200, 200, 220)
	langEnBtn.TextSize = 12
	langEnBtn.Font = Enum.Font.Gotham
	langEnBtn.Parent = langFrame
	Instance.new("UICorner", langEnBtn).CornerRadius = UDim.new(0, 4)

	langRuBtn.MouseButton1Click:Connect(function()
		langRuBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
		langRuBtn.BorderColor3 = Color3.fromRGB(100, 200, 255)
		langRuBtn.Text = "Русский ✓"
		langEnBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
		langEnBtn.BorderColor3 = Color3.fromRGB(45, 45, 60)
		langEnBtn.Text = "English"
		addLog("Language: Русский")
		_G.N1V1LON.showMsg("Language set to: Русский")
	end)

	langEnBtn.MouseButton1Click:Connect(function()
		langEnBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
		langEnBtn.BorderColor3 = Color3.fromRGB(100, 200, 255)
		langEnBtn.Text = "English ✓"
		langRuBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
		langRuBtn.BorderColor3 = Color3.fromRGB(45, 45, 60)
		langRuBtn.Text = "Русский"
		addLog("Language: English")
		_G.N1V1LON.showMsg("Language set to: English")
	end)

	-- Theme Setting
	local themeFrame = Instance.new("Frame")
	themeFrame.Size = UDim2.new(1, 0, 0, 50)
	themeFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
	themeFrame.BorderSizePixel = 0
	themeFrame.Parent = settingsTab
	Instance.new("UICorner", themeFrame).CornerRadius = UDim.new(0, 6)

	local themeLabel = Instance.new("TextLabel")
	themeLabel.Size = UDim2.new(1, -16, 0, 14)
	themeLabel.Position = UDim2.new(0, 8, 0, 6)
	themeLabel.BackgroundTransparency = 1
	themeLabel.Text = "Тема оформления"
	themeLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
	themeLabel.TextSize = 12
	themeLabel.TextXAlignment = Enum.TextXAlignment.Left
	themeLabel.Font = Enum.Font.Gotham
	themeLabel.Parent = themeFrame

	local themeDarkBtn = Instance.new("TextButton")
	themeDarkBtn.Size = UDim2.new(0.5, -6, 0, 24)
	themeDarkBtn.Position = UDim2.new(0, 8, 0, 22)
	themeDarkBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
	themeDarkBtn.BorderSizePixel = 2
	themeDarkBtn.BorderColor3 = Color3.fromRGB(100, 200, 255)
	themeDarkBtn.Text = "Тёмная ✓"
	themeDarkBtn.TextColor3 = Color3.fromRGB(200, 200, 220)
	themeDarkBtn.TextSize = 12
	themeDarkBtn.Font = Enum.Font.Gotham
	themeDarkBtn.Parent = themeFrame
	Instance.new("UICorner", themeDarkBtn).CornerRadius = UDim.new(0, 4)

	local themeLightBtn = Instance.new("TextButton")
	themeLightBtn.Size = UDim2.new(0.5, -6, 0, 24)
	themeLightBtn.Position = UDim2.new(0.5, 2, 0, 22)
	themeLightBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
	themeLightBtn.BorderSizePixel = 2
	themeLightBtn.BorderColor3 = Color3.fromRGB(45, 45, 60)
	themeLightBtn.Text = "Светлая"
	themeLightBtn.TextColor3 = Color3.fromRGB(200, 200, 220)
	themeLightBtn.TextSize = 12
	themeLightBtn.Font = Enum.Font.Gotham
	themeLightBtn.Parent = themeFrame
	Instance.new("UICorner", themeLightBtn).CornerRadius = UDim.new(0, 4)

	themeDarkBtn.MouseButton1Click:Connect(function()
		themeDarkBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
		themeDarkBtn.BorderColor3 = Color3.fromRGB(100, 200, 255)
		themeDarkBtn.Text = "Тёмная ✓"
		themeLightBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
		themeLightBtn.BorderColor3 = Color3.fromRGB(45, 45, 60)
		themeLightBtn.Text = "Светлая"
		addLog("Theme: Тёмная")
		_G.N1V1LON.showMsg("Theme set to: Тёмная")
	end)

	themeLightBtn.MouseButton1Click:Connect(function()
		themeLightBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
		themeLightBtn.BorderColor3 = Color3.fromRGB(100, 200, 255)
		themeLightBtn.Text = "Светлая ✓"
		themeDarkBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
		themeDarkBtn.BorderColor3 = Color3.fromRGB(45, 45, 60)
		themeDarkBtn.Text = "Тёмная"
		addLog("Theme: Светлая")
		_G.N1V1LON.showMsg("Theme set to: Светлая")
	end)

	-- Version Info
	local versionFrame = Instance.new("Frame")
	versionFrame.Size = UDim2.new(1, 0, 0, 40)
	versionFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
	versionFrame.BorderSizePixel = 0
	versionFrame.Parent = settingsTab
	Instance.new("UICorner", versionFrame).CornerRadius = UDim.new(0, 6)

	local versionLabel = Instance.new("TextLabel")
	versionLabel.Size = UDim2.new(1, -16, 0, 14)
	versionLabel.Position = UDim2.new(0, 8, 0, 6)
	versionLabel.BackgroundTransparency = 1
	versionLabel.Text = "Версия: v26.2.1.0 Beta"
	versionLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
	versionLabel.TextSize = 12
	versionLabel.TextXAlignment = Enum.TextXAlignment.Left
	versionLabel.Font = Enum.Font.Gotham
	versionLabel.Parent = versionFrame

	local buildLabel = Instance.new("TextLabel")
	buildLabel.Size = UDim2.new(1, -16, 0, 14)
	buildLabel.Position = UDim2.new(0, 8, 0, 22)
	buildLabel.BackgroundTransparency = 1
	buildLabel.Text = "Build: beta (scripts_beta)"
	buildLabel.TextColor3 = Color3.fromRGB(120, 120, 160)
	buildLabel.TextSize = 10
	buildLabel.TextXAlignment = Enum.TextXAlignment.Left
	buildLabel.Font = Enum.Font.Gotham
	buildLabel.Parent = versionFrame

	-- ==================== LOG BUTTON ====================
	logBtn.MouseButton1Click:Connect(function()
		local dataLines = {}
		table.insert(dataLines, "=== N1V1LON Debug Log ===")
		table.insert(dataLines, "Version: v26.2.1.0 Beta")
		table.insert(dataLines, "Build: beta (scripts_beta)")
		table.insert(dataLines, "")
		table.insert(dataLines, "--- Game Info ---")
		local okG, gName = pcall(function() return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name end)
		table.insert(dataLines, "Game: " .. (okG and gName or "unknown"))
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
			if root then table.insert(dataLines, "Position: " .. tostring(root.Position)) end
			local hum = char:FindFirstChildOfClass("Humanoid")
			if hum then table.insert(dataLines, "Health: " .. hum.Health .. "/" .. hum.MaxHealth .. " WS:" .. hum.WalkSpeed) end
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
						if (part.Position - pos).Magnitude < 30 then
							count = count + 1
							if count <= 50 then
								table.insert(dataLines, "  " .. part.Name .. " (" .. part.ClassName .. ")")
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
		pcall(function() makefolder("logsave") end)
		for _, path in ipairs({ "logsave/N1V1LON_log.txt", "N1V1LON_log_save.txt", "log_save.txt", "logsave/log_save.txt" }) do
			if not saved then
				local okW = pcall(function() writefile(path, fullText); saved = true; savePath = path end)
			end
		end
		if saved then
			addLog("Saved to " .. savePath)
			warn("N1V1LON: log saved to " .. savePath)
			chatLocal("N1V1LON: log saved (" .. #dataLines .. " lines)", Color3.fromRGB(100, 255, 100))
		else
			warn("N1V1LON: writefile not available, log below")
			chatLocal("N1V1LON: writefile not available, check console", Color3.fromRGB(255, 100, 100))
		end
		warn("=== N1V1LON LOG ===")
		warn(fullText)
		warn("=== END LOG ===")
	end)

	-- ==================== BETA SELF-UPDATE ====================
	betaBtn.MouseButton1Click:Connect(function()
		addLog("β self-update triggered")
		warn("N1V1LON: β self-update...")
		if gui then pcall(function() gui:Destroy() end) end
		if _G.N1V1LON.cleanup then
			for _, fn in ipairs(_G.N1V1LON.cleanup) do
				pcall(fn)
			end
		end
		task.wait(0.3)
		local url = "https://raw.githubusercontent.com/N1V1LON/roblox_lua_script/main/test_loading.lua"
		local okS, script = pcall(function()
			return game:HttpGet(url, true)
		end)
		if okS and script then
			local fn, errS = loadstring(script)
			if fn then
				_G.N1V1LON.cleanup = {}
				task.spawn(fn)
			end
		end
	end)

	addLog("Interface loaded successfully!")
	print("[N1V1LON] Interface loaded successfully!")
end)

if not ok then
	warn("N1V1LON error: " .. tostring(err))
end
