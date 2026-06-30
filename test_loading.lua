-- N1V1LON Interface v2 (single-file beta)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
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
	local ok = pcall(function()
		info = HttpService:FormatUtc(HttpService:GetCurrentDateTime(), "!time")
	end)
	if not ok then info = tostring(t) end
	table.insert(_G.N1V1LON.logs, "[" .. info .. "] " .. msg)
end

-- ==================== SETTINGS ====================
local SETTINGS_PATH = "N1V1LON_settings.txt"
local settings = { language = "ru", theme = "dark" }

local function saveSettings()
	local ok = pcall(function() writefile(SETTINGS_PATH, HttpService:JSONEncode(settings)) end)
	if ok then addLog("Settings saved") end
end

local function loadSettings()
	local ok, raw = pcall(function() return readfile(SETTINGS_PATH) end)
	if ok and raw then
		local ok2, data = pcall(function() return HttpService:JSONDecode(raw) end)
		if ok2 and type(data) == "table" then
			if data.language then settings.language = data.language end
			if data.theme then settings.theme = data.theme end
		end
	end
end
loadSettings()

-- ==================== THEME ====================
local themes = {
	dark = {
		menuBg = Color3.fromRGB(20, 20, 30),
		titleBarBg = Color3.fromRGB(30, 30, 45),
		tabsBg = Color3.fromRGB(30, 30, 45),
		widgetBg = Color3.fromRGB(35, 35, 50),
		btnBg = Color3.fromRGB(45, 45, 60),
		btnActiveBg = Color3.fromRGB(60, 60, 90),
		textMain = Color3.fromRGB(200, 200, 220),
		textDim = Color3.fromRGB(120, 120, 160),
		textTitle = Color3.fromRGB(220, 220, 255),
		accentBlue = Color3.fromRGB(100, 200, 255),
		accentGold = Color3.fromRGB(255, 200, 50),
		statusOn = Color3.fromRGB(60, 200, 120),
		statusOff = Color3.fromRGB(140, 60, 60),
	},
	light = {
		menuBg = Color3.fromRGB(240, 240, 245),
		titleBarBg = Color3.fromRGB(225, 225, 235),
		tabsBg = Color3.fromRGB(225, 225, 235),
		widgetBg = Color3.fromRGB(230, 230, 240),
		btnBg = Color3.fromRGB(215, 215, 225),
		btnActiveBg = Color3.fromRGB(200, 215, 235),
		textMain = Color3.fromRGB(40, 40, 55),
		textDim = Color3.fromRGB(100, 100, 120),
		textTitle = Color3.fromRGB(20, 20, 35),
		accentBlue = Color3.fromRGB(30, 120, 200),
		accentGold = Color3.fromRGB(180, 130, 20),
		statusOn = Color3.fromRGB(30, 150, 80),
		statusOff = Color3.fromRGB(180, 50, 50),
	},
}

local currentTheme = themes[settings.theme] or themes.dark
local allThemed = {}

local function themeRegister(obj, prop, colorKey)
	table.insert(allThemed, { obj = obj, prop = prop, colorKey = colorKey })
	pcall(function()
		if prop == "BackgroundColor3" then
			obj.BackgroundColor3 = currentTheme[colorKey]
		elseif prop == "TextColor3" then
			obj.TextColor3 = currentTheme[colorKey]
		end
	end)
end

local function themeApply()
	for _, entry in ipairs(allThemed) do
		pcall(function()
			if entry.prop == "BackgroundColor3" then
				entry.obj.BackgroundColor3 = currentTheme[entry.colorKey]
			elseif entry.prop == "TextColor3" then
				entry.obj.TextColor3 = currentTheme[entry.colorKey]
			end
		end)
	end
end

-- ==================== I18N ====================
local T = {
	ru = {
		player = "Игрок",
		server = "Сервер",
		settings = "Настройки",
		speed = "Скорость",
		infJump = "Бесконечный прыжок",
		on = "ВКЛ",
		off = "ВЫКЛ",
		highlights = "Подсветка",
		npc = "NPC",
		items = "Предметы",
		teleport = "Телепорт",
		checkpoints = "Чекпоинты",
		aimbot = "Aimbot",
		zone = "Зона: ",
		hits = "Удары: ",
		damage = "Урон: ",
		language = "Язык / Language",
		theme = "Тема оформления",
		dark = "Тёмная",
		light = "Светлая",
		version = "v26.2.1.0 Beta",
		build = "Сборка: beta (scripts_beta)",
	},
	en = {
		player = "Player",
		server = "Server",
		settings = "Settings",
		speed = "Speed",
		infJump = "Infinite Jump",
		on = "ON",
		off = "OFF",
		highlights = "Highlights",
		npc = "NPC",
		items = "Items",
		teleport = "Teleport",
		checkpoints = "Checkpoints",
		aimbot = "Aimbot",
		zone = "Zone: ",
		hits = "Hits: ",
		damage = "Damage: ",
		language = "Language / Язык",
		theme = "Theme",
		dark = "Dark",
		light = "Light",
		version = "v26.2.1.0 Beta",
		build = "Build: beta (scripts_beta)",
	},
}

local currentLang = T[settings.language] or T.ru
local langLabels = {}
local sliderUpdates = {}

local function langRegister(key, obj)
	table.insert(langLabels, { key = key, obj = obj })
	if obj then pcall(function() obj.Text = currentLang[key] end) end
end

-- ==================== MAIN SCRIPT ====================
local ok, err = pcall(function()
	if not player then return end

	local function chatLocal(msg, color)
		local char = player.Character
		if not char then return end
		local head = char:FindFirstChild("Head")
		if not head then return end
		pcall(function()
			game:GetService("Chat"):Chat(head, msg, color or Color3.fromRGB(200, 200, 255))
		end)
	end

	addLog("Player: " .. player.Name)

	local pg = player:WaitForChild("PlayerGui", 10)
	if not pg then return end

	local existing = pg:FindFirstChild("N1V1LON")
	if existing then existing:Destroy(); addLog("Old GUI destroyed") end

	-- Block check
	local blockUrl = "https://raw.githubusercontent.com/N1V1LON/roblox_lua_script/main/users/players.lua"
	local okB, blockRaw = pcall(function() return game:HttpGet(blockUrl, true) end)
	if okB and blockRaw then
		local okFn, playersTbl = pcall(loadstring, blockRaw)
		if okFn and type(playersTbl) == "table" and playersTbl[player.UserId] and playersTbl[player.UserId].blocked == true then
			warn("N1V1LON: blocked " .. player.Name)
			chatLocal("N1V1LON: access blocked", Color3.fromRGB(255, 50, 50))
			return
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
			local okB2, raw2 = pcall(function() return game:HttpGet(blockUrl, true) end)
			if okB2 and raw2 then
				local okFn2, tbl2 = pcall(loadstring, raw2)
				if okFn2 and type(tbl2) == "table" and tbl2[player.UserId] and tbl2[player.UserId].blocked == true then
					chatLocal("N1V1LON: access blocked", Color3.fromRGB(255, 50, 50))
					if gui then pcall(function() gui:Destroy() end) end
					_G.N1V1LON.blocked = true
					return
				end
			end
		end
	end)

	-- Message toast
	local msgFrame = Instance.new("Frame")
	msgFrame.Size = UDim2.new(0, 220, 0, 24)
	msgFrame.Position = UDim2.new(0.5, -110, 0, 12)
	msgFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	msgFrame.BackgroundTransparency = 0.3
	msgFrame.BorderSizePixel = 0
	msgFrame.ZIndex = 100
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
	msgLabel.ZIndex = 101
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

	-- Icon with β
	local icon = Instance.new("TextButton")
	icon.Name = "Icon"
	icon.Size = UDim2.new(0, 48, 0, 48)
	icon.Position = UDim2.new(1, -68, 0, 12)
	icon.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
	icon.BorderSizePixel = 0
	icon.Text = "N"
	icon.TextColor3 = Color3.fromRGB(220, 220, 255)
	icon.TextSize = 28
	icon.Font = Enum.Font.GothamBold
	icon.Draggable = true
	icon.AutoButtonColor = false
	icon.Parent = gui
	Instance.new("UICorner", icon).CornerRadius = UDim.new(0, 12)

	local betaLabel = Instance.new("TextLabel")
	betaLabel.Size = UDim2.new(0, 14, 0, 14)
	betaLabel.Position = UDim2.new(1, -14, 1, -14)
	betaLabel.BackgroundTransparency = 1
	betaLabel.Text = "β"
	betaLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
	betaLabel.TextSize = 11
	betaLabel.Font = Enum.Font.GothamBold
	betaLabel.ZIndex = 2
	betaLabel.Parent = icon

	-- Menu
	local menu = Instance.new("Frame")
	menu.Name = "Menu"
	menu.Size = UDim2.new(0, 300, 0, 400)
	menu.Position = UDim2.new(0.5, -150, 0.5, -200)
	menu.BackgroundColor3 = currentTheme.menuBg
	menu.BorderSizePixel = 0
	menu.Visible = false
	menu.Parent = gui
	Instance.new("UICorner", menu).CornerRadius = UDim.new(0, 10)
	themeRegister(menu, "BackgroundColor3", "menuBg")

	-- Title
	local titleBar = Instance.new("Frame")
	titleBar.Size = UDim2.new(1, 0, 0, 30)
	titleBar.BackgroundColor3 = currentTheme.titleBarBg
	titleBar.BorderSizePixel = 0
	titleBar.Parent = menu
	Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 10)
	themeRegister(titleBar, "BackgroundColor3", "titleBarBg")

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(0, 120, 1, 0)
	title.Position = UDim2.new(0, 8, 0, 0)
	title.BackgroundTransparency = 1
	title.Text = "N1V1LON"
	title.TextColor3 = currentTheme.textTitle
	title.TextSize = 11
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Font = Enum.Font.GothamBold
	title.Parent = titleBar
	themeRegister(title, "TextColor3", "textTitle")

	-- Dragging logic
	local dragging = false
	local dragInput, dragStart, startPos

	titleBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = menu.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	titleBar.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and input == dragInput then
			local delta = input.Position - dragStart
			menu.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)

	local betaBtn = Instance.new("TextButton")
	betaBtn.Size = UDim2.new(0, 26, 1, 0)
	betaBtn.Position = UDim2.new(1, -90, 0, 0)
	betaBtn.BackgroundTransparency = 1
	betaBtn.Text = "β"
	betaBtn.TextColor3 = currentTheme.accentGold
	betaBtn.TextSize = 16
	betaBtn.Font = Enum.Font.GothamBold
	betaBtn.Parent = titleBar
	themeRegister(betaBtn, "TextColor3", "accentGold")

	local logBtn = Instance.new("TextButton")
	logBtn.Size = UDim2.new(0, 26, 1, 0)
	logBtn.Position = UDim2.new(1, -60, 0, 0)
	logBtn.BackgroundTransparency = 1
	logBtn.Text = "^"
	logBtn.TextColor3 = currentTheme.accentBlue
	logBtn.TextSize = 16
	logBtn.Font = Enum.Font.GothamBold
	logBtn.Parent = titleBar
	themeRegister(logBtn, "TextColor3", "accentBlue")

	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, 30, 1, 0)
	closeBtn.Position = UDim2.new(1, -30, 0, 0)
	closeBtn.BackgroundTransparency = 1
	closeBtn.Text = "X"
	closeBtn.TextColor3 = Color3.fromRGB(200, 60, 60)
	closeBtn.TextSize = 16
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.Parent = titleBar

	closeBtn.MouseButton1Click:Connect(function() menu.Visible = false end)
	icon.MouseButton1Click:Connect(function() menu.Visible = not menu.Visible end)

	-- Tabs
	local tabsFrame = Instance.new("Frame")
	tabsFrame.Size = UDim2.new(1, 0, 0, 30)
	tabsFrame.Position = UDim2.new(0, 0, 0, 30)
	tabsFrame.BackgroundColor3 = currentTheme.tabsBg
	tabsFrame.BorderSizePixel = 0
	tabsFrame.Parent = menu
	themeRegister(tabsFrame, "BackgroundColor3", "tabsBg")

	local tabPlayer = Instance.new("TextButton")
	tabPlayer.Size = UDim2.new(1/3, 0, 1, 0)
	tabPlayer.Position = UDim2.new(0, 0, 0, 0)
	tabPlayer.BackgroundTransparency = 1
	tabPlayer.Text = currentLang.player
	tabPlayer.TextColor3 = currentTheme.textDim
	tabPlayer.TextSize = 11
	tabPlayer.Font = Enum.Font.GothamBold
	tabPlayer.AutoButtonColor = false
	tabPlayer.Parent = tabsFrame
	themeRegister(tabPlayer, "TextColor3", "textDim")
	langRegister("player", tabPlayer)

	local tabServer = Instance.new("TextButton")
	tabServer.Size = UDim2.new(1/3, 0, 1, 0)
	tabServer.Position = UDim2.new(1/3, 0, 0, 0)
	tabServer.BackgroundTransparency = 1
	tabServer.Text = currentLang.server
	tabServer.TextColor3 = currentTheme.textDim
	tabServer.TextSize = 11
	tabServer.Font = Enum.Font.GothamBold
	tabServer.AutoButtonColor = false
	tabServer.Parent = tabsFrame
	themeRegister(tabServer, "TextColor3", "textDim")
	langRegister("server", tabServer)

	local tabSettings = Instance.new("TextButton")
	tabSettings.Size = UDim2.new(1/3, 0, 1, 0)
	tabSettings.Position = UDim2.new(2/3, 0, 0, 0)
	tabSettings.BackgroundTransparency = 1
	tabSettings.Text = currentLang.settings
	tabSettings.TextColor3 = currentTheme.textDim
	tabSettings.TextSize = 11
	tabSettings.Font = Enum.Font.GothamBold
	tabSettings.AutoButtonColor = false
	tabSettings.Parent = tabsFrame
	themeRegister(tabSettings, "TextColor3", "textDim")
	langRegister("settings", tabSettings)

	-- Content
	local content = Instance.new("ScrollingFrame")
	content.Size = UDim2.new(1, -16, 1, -70)
	content.Position = UDim2.new(0, 8, 0, 68)
	content.BackgroundTransparency = 1
	content.BorderSizePixel = 0
	content.ScrollBarThickness = 3
	content.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 100)
	content.CanvasSize = UDim2.new(0, 0, 0, 0)
	content.AutomaticCanvasSize = Enum.AutomaticSize.Y
	content.Parent = menu
	Instance.new("UIListLayout", content).Padding = UDim.new(0, 5)

	local playerTab = Instance.new("Frame")
	playerTab.Size = UDim2.new(1, 0, 0, 0)
	playerTab.BackgroundTransparency = 1
	playerTab.Visible = true
	playerTab.Parent = content
	Instance.new("UIListLayout", playerTab).Padding = UDim.new(0, 5)

	local serverTab = Instance.new("Frame")
	serverTab.Size = UDim2.new(1, 0, 0, 0)
	serverTab.BackgroundTransparency = 1
	serverTab.Visible = false
	serverTab.Parent = content
	Instance.new("UIListLayout", serverTab).Padding = UDim.new(0, 5)

	local settingsTab = Instance.new("Frame")
	settingsTab.Size = UDim2.new(1, 0, 0, 0)
	settingsTab.BackgroundTransparency = 1
	settingsTab.Visible = false
	settingsTab.Parent = content
	Instance.new("UIListLayout", settingsTab).Padding = UDim.new(0, 5)

	local activeTab = "player"
	local function switchTab(name)
		activeTab = name
		playerTab.Visible = name == "player"
		serverTab.Visible = name == "server"
		settingsTab.Visible = name == "settings"
		tabPlayer.TextColor3 = name == "player" and currentTheme.accentBlue or currentTheme.textDim
		tabServer.TextColor3 = name == "server" and currentTheme.accentBlue or currentTheme.textDim
		tabSettings.TextColor3 = name == "settings" and currentTheme.accentBlue or currentTheme.textDim
	end

	tabPlayer.MouseButton1Click:Connect(function() switchTab("player") end)
	tabServer.MouseButton1Click:Connect(function() switchTab("server") end)
	tabSettings.MouseButton1Click:Connect(function() switchTab("settings") end)

	-- ==================== PLAYER TAB ====================

	-- Speed
	local speedOn = false
	local speedConn = nil
	local currentSpeed = 50
	local normalSpeed = 16

	local speedBtn = Instance.new("TextButton")
	speedBtn.Size = UDim2.new(1, 0, 0, 30)
	speedBtn.BackgroundColor3 = currentTheme.widgetBg
	speedBtn.BorderSizePixel = 0
	speedBtn.Text = "  " .. currentLang.speed
	speedBtn.TextColor3 = currentTheme.textMain
	speedBtn.TextSize = 12
	speedBtn.TextXAlignment = Enum.TextXAlignment.Left
	speedBtn.Font = Enum.Font.Gotham
	speedBtn.AutoButtonColor = false
	speedBtn.Parent = playerTab
	Instance.new("UICorner", speedBtn).CornerRadius = UDim.new(0, 6)
	themeRegister(speedBtn, "BackgroundColor3", "widgetBg")
	themeRegister(speedBtn, "TextColor3", "textMain")
	langRegister("speed", speedBtn)

	local speedStatus = Instance.new("TextLabel")
	speedStatus.Size = UDim2.new(0, 70, 1, 0)
	speedStatus.Position = UDim2.new(1, -74, 0, 0)
	speedStatus.BackgroundTransparency = 1
	speedStatus.Text = currentLang.off
	speedStatus.TextColor3 = currentTheme.statusOff
	speedStatus.TextSize = 11
	speedStatus.Font = Enum.Font.GothamBold
	speedStatus.Parent = speedBtn

	local function updateSpeedStatus()
		if speedOn then
			speedStatus.Text = currentLang.on .. " " .. currentSpeed
			speedStatus.TextColor3 = currentTheme.statusOn
		else
			speedStatus.Text = currentLang.off
			speedStatus.TextColor3 = currentTheme.statusOff
		end
	end

	speedBtn.MouseButton1Click:Connect(function()
		speedOn = not speedOn
		if speedOn then
			local function apply(char)
				local hum = char:FindFirstChildOfClass("Humanoid")
				if hum then hum.WalkSpeed = currentSpeed end
			end
			local char = player.Character
			if char then apply(char) end
			speedConn = player.CharacterAdded:Connect(apply)
			updateSpeedStatus()
			addLog("Speed ON: " .. currentSpeed)
			_G.N1V1LON.showMsg("Speed: " .. currentSpeed)
		else
			if speedConn then speedConn:Disconnect(); speedConn = nil end
			local char = player.Character
			if char then
				local hum = char:FindFirstChildOfClass("Humanoid")
				if hum then hum.WalkSpeed = normalSpeed end
			end
			updateSpeedStatus()
			addLog("Speed OFF")
			_G.N1V1LON.showMsg("Speed OFF")
		end
	end)

	-- Infinite Jump
	local infJumpOn = false
	local infJumpConn = nil
	local jumpReqConn = nil

	local infJumpBtn = Instance.new("TextButton")
	infJumpBtn.Size = UDim2.new(1, 0, 0, 30)
	infJumpBtn.BackgroundColor3 = currentTheme.widgetBg
	infJumpBtn.BorderSizePixel = 0
	infJumpBtn.Text = "  " .. currentLang.infJump
	infJumpBtn.TextColor3 = currentTheme.textMain
	infJumpBtn.TextSize = 12
	infJumpBtn.TextXAlignment = Enum.TextXAlignment.Left
	infJumpBtn.Font = Enum.Font.Gotham
	infJumpBtn.AutoButtonColor = false
	infJumpBtn.Parent = playerTab
	Instance.new("UICorner", infJumpBtn).CornerRadius = UDim.new(0, 6)
	themeRegister(infJumpBtn, "BackgroundColor3", "widgetBg")
	themeRegister(infJumpBtn, "TextColor3", "textMain")
	langRegister("infJump", infJumpBtn)

	local infJumpStatus = Instance.new("TextLabel")
	infJumpStatus.Size = UDim2.new(0, 44, 1, 0)
	infJumpStatus.Position = UDim2.new(1, -48, 0, 0)
	infJumpStatus.BackgroundTransparency = 1
	infJumpStatus.Text = currentLang.off
	infJumpStatus.TextColor3 = currentTheme.statusOff
	infJumpStatus.TextSize = 11
	infJumpStatus.Font = Enum.Font.GothamBold
	infJumpStatus.Parent = infJumpBtn

	local function updateInfJumpStatus()
		infJumpStatus.Text = infJumpOn and currentLang.on or currentLang.off
		infJumpStatus.TextColor3 = infJumpOn and currentTheme.statusOn or currentTheme.statusOff
	end

	infJumpBtn.MouseButton1Click:Connect(function()
		infJumpOn = not infJumpOn
		if infJumpOn then
			local function apply(char)
				local hum = char:FindFirstChildOfClass("Humanoid")
				if hum then hum.UseJumpPower = false end
			end
			local char = player.Character
			if char then apply(char) end
			infJumpConn = player.CharacterAdded:Connect(apply)
			jumpReqConn = UserInputService.JumpRequest:Connect(function()
				if infJumpOn then
					local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
					if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
				end
			end)
			updateInfJumpStatus()
			addLog("InfJump ON")
			_G.N1V1LON.showMsg("InfJump ON")
		else
			if infJumpConn then infJumpConn:Disconnect(); infJumpConn = nil end
			if jumpReqConn then jumpReqConn:Disconnect(); jumpReqConn = nil end
			updateInfJumpStatus()
			addLog("InfJump OFF")
			_G.N1V1LON.showMsg("InfJump OFF")
		end
	end)

	-- Highlights
	local highlightsFrame = Instance.new("Frame")
	highlightsFrame.Size = UDim2.new(1, 0, 0, 60)
	highlightsFrame.BackgroundColor3 = currentTheme.widgetBg
	highlightsFrame.BorderSizePixel = 0
	highlightsFrame.Parent = playerTab
	Instance.new("UICorner", highlightsFrame).CornerRadius = UDim.new(0, 6)
	themeRegister(highlightsFrame, "BackgroundColor3", "widgetBg")

	local highlightsTitle = Instance.new("TextLabel")
	highlightsTitle.Size = UDim2.new(1, -12, 0, 18)
	highlightsTitle.Position = UDim2.new(0, 8, 0, 3)
	highlightsTitle.BackgroundTransparency = 1
	highlightsTitle.Text = currentLang.highlights
	highlightsTitle.TextColor3 = currentTheme.textMain
	highlightsTitle.TextSize = 12
	highlightsTitle.TextXAlignment = Enum.TextXAlignment.Left
	highlightsTitle.Font = Enum.Font.Gotham
	highlightsTitle.Parent = highlightsFrame
	themeRegister(highlightsTitle, "TextColor3", "textMain")
	langRegister("highlights", highlightsTitle)

	local function makeHighlightBtn(parent, labelText, key, posX)
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(0.5, -6, 0, 18)
		btn.Position = UDim2.new(posX, posX == 0 and 8 or 2, 0, 24)
		btn.BackgroundColor3 = currentTheme.btnBg
		btn.BorderSizePixel = 0
		btn.Text = ""
		btn.AutoButtonColor = false
		btn.Parent = parent
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
		themeRegister(btn, "BackgroundColor3", "btnBg")

		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(0.65, -4, 1, 0)
		lbl.Position = UDim2.new(0, 6, 0, 0)
		lbl.BackgroundTransparency = 1
		lbl.Text = labelText
		lbl.TextColor3 = currentTheme.textMain
		lbl.TextSize = 11
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Font = Enum.Font.Gotham
		lbl.Parent = btn
		themeRegister(lbl, "TextColor3", "textMain")
		langRegister(key, lbl)

		local st = Instance.new("TextLabel")
		st.Size = UDim2.new(0.35, -2, 1, 0)
		st.Position = UDim2.new(0.65, 2, 0, 0)
		st.BackgroundTransparency = 1
		st.Text = currentLang.off
		st.TextColor3 = currentTheme.statusOff
		st.TextSize = 10
		st.TextXAlignment = Enum.TextXAlignment.Center
		st.Font = Enum.Font.GothamBold
		st.Parent = btn

		return btn, st, lbl
	end

	local npcBtnGroup, npcStatus = makeHighlightBtn(highlightsFrame, currentLang.npc, "npc", 0)
	local itemBtnGroup, itemStatus = makeHighlightBtn(highlightsFrame, currentLang.items, "items", 0.5)

	local infoLabel = Instance.new("TextLabel")
	infoLabel.Size = UDim2.new(1, -12, 0, 12)
	infoLabel.Position = UDim2.new(0, 8, 0, 46)
	infoLabel.BackgroundTransparency = 1
	infoLabel.Text = ""
	infoLabel.TextColor3 = currentTheme.textDim
	infoLabel.TextSize = 9
	infoLabel.TextXAlignment = Enum.TextXAlignment.Left
	infoLabel.Font = Enum.Font.Gotham
	infoLabel.Parent = highlightsFrame
	themeRegister(infoLabel, "TextColor3", "textDim")

	local npcOn = false
	local itemsOn = false
	local npcHighlights = {}
	local itemHighlights = {}
	local npcCount = 0
	local itemCount = 0

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
		"Anvil Base", "Lost Child", "Lost Child2", "Lost Child3", "Lost Child4",
	}

	local function inList(name, list)
		for _, v in ipairs(list) do
			if v == name then return true end
		end
		return false
	end

	-- Descendants cache
	local descCache = nil
	local descCacheTime = 0
	local function getDesc()
		local now = tick()
		if not descCache or now - descCacheTime > 1 then
			descCache = workspace:GetDescendants()
			descCacheTime = now
		end
		return descCache
	end

	local function updateInfoLabel()
		if npcOn then
			infoLabel.Text = currentLang.npc .. ": " .. npcCount
		elseif itemsOn then
			infoLabel.Text = currentLang.items .. ": " .. itemCount
		else
			infoLabel.Text = ""
		end
	end

	local function toggleNPC()
		if npcOn then
			for _, hl in ipairs(npcHighlights) do pcall(function() hl:Destroy() end) end
			npcHighlights = {}; npcOn = false; npcCount = 0
			npcStatus.Text = currentLang.off
			npcStatus.TextColor3 = currentTheme.statusOff
			npcBtnGroup.BackgroundColor3 = currentTheme.btnBg
			updateInfoLabel()
			addLog("NPC OFF"); _G.N1V1LON.showMsg("NPC highlight OFF")
		else
			npcCount = 0
			for _, obj in ipairs(getDesc()) do
				if obj:IsA("Model") and inList(obj.Name, npcNames) then
					if not obj:FindFirstChildOfClass("Humanoid") then continue end
					local hl = Instance.new("Highlight")
					hl.FillColor = Color3.fromRGB(255, 50, 50)
					hl.FillTransparency = 0.5
					hl.OutlineColor = Color3.fromRGB(255, 200, 50)
					hl.OutlineTransparency = 0.3
					hl.Parent = obj; hl.Adornee = obj
					table.insert(npcHighlights, hl)
					npcCount = npcCount + 1
				end
			end
			npcOn = true
			npcStatus.Text = currentLang.on
			npcStatus.TextColor3 = currentTheme.statusOn
			npcBtnGroup.BackgroundColor3 = currentTheme.btnActiveBg
			updateInfoLabel()
			addLog("NPC ON: " .. npcCount)
			_G.N1V1LON.showMsg(currentLang.npc .. ": " .. npcCount)
		end
	end

	local function toggleItems()
		if itemsOn then
			for _, hl in ipairs(itemHighlights) do pcall(function() hl:Destroy() end) end
			itemHighlights = {}; itemsOn = false; itemCount = 0
			itemStatus.Text = currentLang.off
			itemStatus.TextColor3 = currentTheme.statusOff
			itemBtnGroup.BackgroundColor3 = currentTheme.btnBg
			updateInfoLabel()
			addLog("Items OFF"); _G.N1V1LON.showMsg("Items highlight OFF")
		else
			itemCount = 0
			for _, obj in ipairs(getDesc()) do
				if inList(obj.Name, itemNames) then
					local hl = Instance.new("Highlight")
					hl.FillColor = Color3.fromRGB(50, 150, 255)
					hl.FillTransparency = 0.4
					hl.OutlineColor = Color3.fromRGB(255, 255, 100)
					hl.OutlineTransparency = 0.2
					hl.Parent = obj; hl.Adornee = obj
					table.insert(itemHighlights, hl)
					itemCount = itemCount + 1
				end
			end
			itemsOn = true
			itemStatus.Text = currentLang.on
			itemStatus.TextColor3 = currentTheme.statusOn
			itemBtnGroup.BackgroundColor3 = currentTheme.btnActiveBg
			updateInfoLabel()
			addLog("Items ON: " .. itemCount)
			_G.N1V1LON.showMsg(currentLang.items .. ": " .. itemCount)
		end
	end

	npcBtnGroup.MouseButton1Click:Connect(toggleNPC)
	itemBtnGroup.MouseButton1Click:Connect(toggleItems)

	-- Aimbot
	local aimOn = false
	local zoneRadius = 50
	local hitCount = 5
	local damagePower = 15
	local aimConn = nil
	local spherePart = nil
	local sphereConn = nil

	local aimbotFrame = Instance.new("Frame")
	aimbotFrame.Size = UDim2.new(1, 0, 0, 100)
	aimbotFrame.BackgroundColor3 = currentTheme.widgetBg
	aimbotFrame.BorderSizePixel = 0
	aimbotFrame.Parent = playerTab
	Instance.new("UICorner", aimbotFrame).CornerRadius = UDim.new(0, 6)
	themeRegister(aimbotFrame, "BackgroundColor3", "widgetBg")

	local aimbotTitle = Instance.new("TextLabel")
	aimbotTitle.Size = UDim2.new(0, 100, 0, 18)
	aimbotTitle.Position = UDim2.new(0, 8, 0, 3)
	aimbotTitle.BackgroundTransparency = 1
	aimbotTitle.Text = currentLang.aimbot
	aimbotTitle.TextColor3 = currentTheme.textMain
	aimbotTitle.TextSize = 12
	aimbotTitle.TextXAlignment = Enum.TextXAlignment.Left
	aimbotTitle.Font = Enum.Font.Gotham
	aimbotTitle.Parent = aimbotFrame
	themeRegister(aimbotTitle, "TextColor3", "textMain")
	langRegister("aimbot", aimbotTitle)

	local aimbotStatus = Instance.new("TextButton")
	aimbotStatus.Size = UDim2.new(0, 44, 0, 18)
	aimbotStatus.Position = UDim2.new(1, -50, 0, 3)
	aimbotStatus.BackgroundTransparency = 1
	aimbotStatus.Text = currentLang.off
	aimbotStatus.TextColor3 = currentTheme.statusOff
	aimbotStatus.TextSize = 11
	aimbotStatus.Font = Enum.Font.GothamBold
	aimbotStatus.Parent = aimbotFrame

	local function updateAimbotStatus()
		aimbotStatus.Text = aimOn and currentLang.on or currentLang.off
		aimbotStatus.TextColor3 = aimOn and currentTheme.statusOn or currentTheme.statusOff
	end

	local function makeSlider(parent, yPos, labelKey, getter, setter, maxVal, barColor, labelColor)
		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(0, 120, 0, 12)
		lbl.Position = UDim2.new(0, 8, 0, yPos)
		lbl.BackgroundTransparency = 1
		lbl.Text = currentLang[labelKey] .. tostring(getter())
		lbl.TextColor3 = labelColor
		lbl.TextSize = 10
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Font = Enum.Font.Gotham
		lbl.Parent = parent

		local bar = Instance.new("TextButton")
		bar.Size = UDim2.new(1, -20, 0, 7)
		bar.Position = UDim2.new(0, 10, 0, yPos + 13)
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

		local function updateSliderText()
			lbl.Text = currentLang[labelKey] .. tostring(getter())
			fill.Size = UDim2.new(math.clamp(getter() / maxVal, 0, 1), 0, 1, 0)
		end

		table.insert(sliderUpdates, updateSliderText)

		local sliding = false
		local function updateSlider(input)
			local mx = input.Position.X
			local px = bar.AbsolutePosition.X
			local sx = bar.AbsoluteSize.X
			if sx > 0 then
				local frac = math.clamp((mx - px) / sx, 0, 1)
				local val = math.max(1, math.floor(frac * maxVal))
				if maxVal == 500 then val = math.max(5, val) end
				setter(val)
				updateSliderText()
			end
		end

		bar.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				sliding = true
				updateSlider(input)
			end
		end)

		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				sliding = false
			end
		end)

		UserInputService.InputChanged:Connect(function(input)
			if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				updateSlider(input)
			end
		end)
	end

	makeSlider(aimbotFrame, 22, "zone", function() return zoneRadius end, function(v) zoneRadius = v end, 500, Color3.fromRGB(60, 200, 120), Color3.fromRGB(160, 200, 160))
	makeSlider(aimbotFrame, 46, "hits", function() return hitCount end, function(v) hitCount = v end, 50, Color3.fromRGB(200, 200, 100), Color3.fromRGB(200, 200, 100))
	makeSlider(aimbotFrame, 70, "damage", function() return damagePower end, function(v) damagePower = v end, 100, Color3.fromRGB(200, 100, 100), Color3.fromRGB(200, 120, 120))

	local function createSphere()
		if spherePart then pcall(function() spherePart:Destroy() end) end
		spherePart = Instance.new("Part")
		spherePart.Name = "N1V1LON_Sphere"
		spherePart.Shape = Enum.PartType.Ball
		spherePart.Size = Vector3.new(zoneRadius * 2, zoneRadius * 2, zoneRadius * 2)
		spherePart.Anchored = true; spherePart.CanCollide = false
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
			if child:IsA("BasePart") then return child.Position end
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
		for _, obj in ipairs(getDesc()) do
			if not obj:IsA("Model") then continue end
			if not inList(obj.Name, npcNames) then continue end
			local hum = obj:FindFirstChildOfClass("Humanoid")
			if not hum or hum.Health <= 0 then continue end
			local npcPos = getNPCPos(obj)
			if npcPos and (npcPos - pos).Magnitude <= zoneRadius then
				table.insert(targets, hum)
			end
		end
		addLog("Aimbot: " .. #targets .. " targets")
		for h = 1, hitCount do
			for _, nhum in ipairs(targets) do
				if nhum.Health > 0 then
					nhum.Health = nhum.Health - damagePower
					if nhum.Health <= 0 then pcall(function() nhum:BreakJoints() end) end
				end
			end
		end
	end

	aimbotStatus.MouseButton1Click:Connect(function()
		aimOn = not aimOn
		updateAimbotStatus()
		if aimOn then
			createSphere()
			addLog("Aimbot ON"); _G.N1V1LON.showMsg("Aimbot ON")
			if aimConn then aimConn:Disconnect() end
			aimConn = UserInputService.InputBegan:Connect(function(input, processed)
				if processed then return end
				if aimOn and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
					doAimbot()
				end
			end)
		else
			destroySphere()
			addLog("Aimbot OFF"); _G.N1V1LON.showMsg("Aimbot OFF")
			if aimConn then aimConn:Disconnect(); aimConn = nil end
		end
	end)

	-- ==================== SERVER TAB ====================

	local teleportLabel = Instance.new("TextLabel")
	teleportLabel.Size = UDim2.new(1, 0, 0, 18)
	teleportLabel.BackgroundColor3 = currentTheme.btnBg
	teleportLabel.BorderSizePixel = 0
	teleportLabel.Text = "  " .. currentLang.teleport
	teleportLabel.TextColor3 = currentTheme.textDim
	teleportLabel.TextSize = 11
	teleportLabel.TextXAlignment = Enum.TextXAlignment.Left
	teleportLabel.Font = Enum.Font.GothamBold
	teleportLabel.Parent = serverTab
	Instance.new("UICorner", teleportLabel).CornerRadius = UDim.new(0, 4)
	themeRegister(teleportLabel, "BackgroundColor3", "btnBg")
	themeRegister(teleportLabel, "TextColor3", "textDim")
	langRegister("teleport", teleportLabel)

	-- Checkpoints
	local checkpoints = {}

	local cpFrame = Instance.new("Frame")
	cpFrame.Size = UDim2.new(1, 0, 0, 110)
	cpFrame.BackgroundColor3 = currentTheme.widgetBg
	cpFrame.BorderSizePixel = 0
	cpFrame.Parent = serverTab
	Instance.new("UICorner", cpFrame).CornerRadius = UDim.new(0, 6)
	themeRegister(cpFrame, "BackgroundColor3", "widgetBg")

	local cpHeader = Instance.new("Frame")
	cpHeader.Size = UDim2.new(1, 0, 0, 20)
	cpHeader.BackgroundTransparency = 1
	cpHeader.Parent = cpFrame

	local cpLabel = Instance.new("TextLabel")
	cpLabel.Size = UDim2.new(0, 120, 1, 0)
	cpLabel.Position = UDim2.new(0, 8, 0, 0)
	cpLabel.BackgroundTransparency = 1
	cpLabel.Text = currentLang.checkpoints
	cpLabel.TextColor3 = currentTheme.textMain
	cpLabel.TextSize = 12
	cpLabel.TextXAlignment = Enum.TextXAlignment.Left
	cpLabel.Font = Enum.Font.Gotham
	cpLabel.Parent = cpHeader
	themeRegister(cpLabel, "TextColor3", "textMain")
	langRegister("checkpoints", cpLabel)

	local cpAddBtn = Instance.new("TextButton")
	cpAddBtn.Size = UDim2.new(0, 18, 0, 18)
	cpAddBtn.Position = UDim2.new(1, -24, 0, 1)
	cpAddBtn.BackgroundColor3 = currentTheme.btnBg
	cpAddBtn.BorderSizePixel = 0
	cpAddBtn.Text = "+"
	cpAddBtn.TextColor3 = currentTheme.statusOn
	cpAddBtn.TextSize = 13
	cpAddBtn.Font = Enum.Font.GothamBold
	cpAddBtn.Parent = cpHeader
	Instance.new("UICorner", cpAddBtn).CornerRadius = UDim.new(0, 3)
	themeRegister(cpAddBtn, "BackgroundColor3", "btnBg")

	local cpList = Instance.new("ScrollingFrame")
	cpList.Size = UDim2.new(1, -8, 1, -24)
	cpList.Position = UDim2.new(0, 4, 0, 22)
	cpList.BackgroundTransparency = 1
	cpList.BorderSizePixel = 0
	cpList.ScrollBarThickness = 3
	cpList.CanvasSize = UDim2.new(0, 0, 0, 0)
	cpList.Parent = cpFrame
	local cpLayout = Instance.new("UIListLayout"); cpLayout.Padding = UDim.new(0, 2); cpLayout.Parent = cpList

	local function addCP()
		local char = player.Character
		if not char then return end
		local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
		if not root then return end
		local pos = root.Position
		local id = #checkpoints + 1

		local row = Instance.new("TextButton")
		row.Size = UDim2.new(1, -4, 0, 20)
		row.BackgroundColor3 = currentTheme.btnBg
		row.BorderSizePixel = 0
		row.Text = "  CP " .. id .. "  (" .. math.floor(pos.X) .. ", " .. math.floor(pos.Y) .. ", " .. math.floor(pos.Z) .. ")"
		row.TextColor3 = currentTheme.textMain
		row.TextSize = 10; row.Font = Enum.Font.Gotham
		row.TextXAlignment = Enum.TextXAlignment.Left
		row.Parent = cpList
		Instance.new("UICorner", row).CornerRadius = UDim.new(0, 3)

		local entry = { pos = pos, row = row, id = id }
		table.insert(checkpoints, entry)

		local held = false; local holdTask = nil
		row.MouseButton1Down:Connect(function()
			held = false
			holdTask = task.delay(0.5, function()
				held = true
				row.BackgroundColor3 = Color3.fromRGB(80, 40, 40)
				task.delay(0.6, function()
					row:Destroy()
					for i, e in ipairs(checkpoints) do if e == entry then table.remove(checkpoints, i); break end end
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

		addLog("CP #" .. id .. " saved")
		_G.N1V1LON.showMsg("CP saved #" .. id)
	end

	cpAddBtn.MouseButton1Click:Connect(addCP)

	-- ==================== SETTINGS TAB ====================

	-- Language
	local langFrame = Instance.new("Frame")
	langFrame.Size = UDim2.new(1, 0, 0, 44)
	langFrame.BackgroundColor3 = currentTheme.widgetBg
	langFrame.BorderSizePixel = 0
	langFrame.Parent = settingsTab
	Instance.new("UICorner", langFrame).CornerRadius = UDim.new(0, 6)
	themeRegister(langFrame, "BackgroundColor3", "widgetBg")

	local langLabel = Instance.new("TextLabel")
	langLabel.Size = UDim2.new(1, -12, 0, 14)
	langLabel.Position = UDim2.new(0, 8, 0, 4)
	langLabel.BackgroundTransparency = 1
	langLabel.Text = currentLang.language
	langLabel.TextColor3 = currentTheme.textMain
	langLabel.TextSize = 11
	langLabel.TextXAlignment = Enum.TextXAlignment.Left
	langLabel.Font = Enum.Font.Gotham
	langLabel.Parent = langFrame
	themeRegister(langLabel, "TextColor3", "textMain")
	langRegister("language", langLabel)

	local langRuBtn = Instance.new("TextButton")
	langRuBtn.Size = UDim2.new(0.5, -6, 0, 20)
	langRuBtn.Position = UDim2.new(0, 8, 0, 20)
	langRuBtn.BorderSizePixel = 2
	langRuBtn.Text = "Русский"
	langRuBtn.TextColor3 = currentTheme.textMain
	langRuBtn.TextSize = 11
	langRuBtn.Font = Enum.Font.Gotham
	langRuBtn.Parent = langFrame
	Instance.new("UICorner", langRuBtn).CornerRadius = UDim.new(0, 4)

	local langEnBtn = Instance.new("TextButton")
	langEnBtn.Size = UDim2.new(0.5, -6, 0, 20)
	langEnBtn.Position = UDim2.new(0.5, 2, 0, 20)
	langEnBtn.BorderSizePixel = 2
	langEnBtn.Text = "English"
	langEnBtn.TextColor3 = currentTheme.textMain
	langEnBtn.TextSize = 11
	langEnBtn.Font = Enum.Font.Gotham
	langEnBtn.Parent = langFrame
	Instance.new("UICorner", langEnBtn).CornerRadius = UDim.new(0, 4)

	local function updateLangBtns()
		if settings.language == "ru" then
			langRuBtn.BackgroundColor3 = currentTheme.btnActiveBg
			langRuBtn.BorderColor3 = currentTheme.accentBlue
			langRuBtn.Text = "Русский ✓"
			langEnBtn.BackgroundColor3 = currentTheme.btnBg
			langEnBtn.BorderColor3 = currentTheme.btnBg
			langEnBtn.Text = "English"
		else
			langEnBtn.BackgroundColor3 = currentTheme.btnActiveBg
			langEnBtn.BorderColor3 = currentTheme.accentBlue
			langEnBtn.Text = "English ✓"
			langRuBtn.BackgroundColor3 = currentTheme.btnBg
			langRuBtn.BorderColor3 = currentTheme.btnBg
			langRuBtn.Text = "Русский"
		end
	end
	updateLangBtns()

	-- ==================== APPLY LANG ====================
	local function applyLang()
		currentLang = T[settings.language] or T.ru
		for _, item in ipairs(langLabels) do
			pcall(function()
				if currentLang[item.key] then
					item.obj.Text = currentLang[item.key]
				end
			end)
		end
		for _, fn in ipairs(sliderUpdates) do pcall(fn) end
		updateSpeedStatus()
		updateInfJumpStatus()
		updateAimbotStatus()
		npcStatus.Text = npcOn and currentLang.on or currentLang.off
		itemStatus.Text = itemsOn and currentLang.on or currentLang.off
		updateInfoLabel()
		if settings.theme == "dark" then
			themeDarkBtn.Text = currentLang.dark .. " ✓"
			themeLightBtn.Text = currentLang.light
		else
			themeLightBtn.Text = currentLang.light .. " ✓"
			themeDarkBtn.Text = currentLang.dark
		end
		updateLangBtns()
	end

	-- ==================== APPLY THEME ====================
	local function applyTheme(themeName)
		settings.theme = themeName
		currentTheme = themes[themeName] or themes.dark
		themeApply()
		tabPlayer.TextColor3 = activeTab == "player" and currentTheme.accentBlue or currentTheme.textDim
		tabServer.TextColor3 = activeTab == "server" and currentTheme.accentBlue or currentTheme.textDim
		tabSettings.TextColor3 = activeTab == "settings" and currentTheme.accentBlue or currentTheme.textDim
		updateSpeedStatus()
		updateInfJumpStatus()
		updateAimbotStatus()
		npcStatus.TextColor3 = npcOn and currentTheme.statusOn or currentTheme.statusOff
		npcBtnGroup.BackgroundColor3 = npcOn and currentTheme.btnActiveBg or currentTheme.btnBg
		itemStatus.TextColor3 = itemsOn and currentTheme.statusOn or currentTheme.statusOff
		itemBtnGroup.BackgroundColor3 = itemsOn and currentTheme.btnActiveBg or currentTheme.btnBg
		infoLabel.TextColor3 = currentTheme.textDim
		if settings.theme == "dark" then
			themeDarkBtn.BackgroundColor3 = currentTheme.btnActiveBg
			themeDarkBtn.BorderColor3 = currentTheme.accentBlue
			themeDarkBtn.Text = currentLang.dark .. " ✓"
			themeLightBtn.BackgroundColor3 = currentTheme.btnBg
			themeLightBtn.BorderColor3 = currentTheme.btnBg
			themeLightBtn.Text = currentLang.light
		else
			themeLightBtn.BackgroundColor3 = currentTheme.btnActiveBg
			themeLightBtn.BorderColor3 = currentTheme.accentBlue
			themeLightBtn.Text = currentLang.light .. " ✓"
			themeDarkBtn.BackgroundColor3 = currentTheme.btnBg
			themeDarkBtn.BorderColor3 = currentTheme.btnBg
			themeDarkBtn.Text = currentLang.dark
		end
		updateLangBtns()
	end

	langRuBtn.MouseButton1Click:Connect(function()
		settings.language = "ru"
		applyLang()
		saveSettings()
		_G.N1V1LON.showMsg("Язык: Русский")
	end)

	langEnBtn.MouseButton1Click:Connect(function()
		settings.language = "en"
		applyLang()
		saveSettings()
		_G.N1V1LON.showMsg("Language: English")
	end)

	-- Theme
	local themeFrame = Instance.new("Frame")
	themeFrame.Size = UDim2.new(1, 0, 0, 44)
	themeFrame.BackgroundColor3 = currentTheme.widgetBg
	themeFrame.BorderSizePixel = 0
	themeFrame.Parent = settingsTab
	Instance.new("UICorner", themeFrame).CornerRadius = UDim.new(0, 6)
	themeRegister(themeFrame, "BackgroundColor3", "widgetBg")

	local themeLabel = Instance.new("TextLabel")
	themeLabel.Size = UDim2.new(1, -12, 0, 14)
	themeLabel.Position = UDim2.new(0, 8, 0, 4)
	themeLabel.BackgroundTransparency = 1
	themeLabel.Text = currentLang.theme
	themeLabel.TextColor3 = currentTheme.textMain
	themeLabel.TextSize = 11
	themeLabel.TextXAlignment = Enum.TextXAlignment.Left
	themeLabel.Font = Enum.Font.Gotham
	themeLabel.Parent = themeFrame
	themeRegister(themeLabel, "TextColor3", "textMain")
	langRegister("theme", themeLabel)

	local themeDarkBtn = Instance.new("TextButton")
	themeDarkBtn.Size = UDim2.new(0.5, -6, 0, 20)
	themeDarkBtn.Position = UDim2.new(0, 8, 0, 20)
	themeDarkBtn.BorderSizePixel = 2
	themeDarkBtn.Text = currentLang.dark
	themeDarkBtn.TextColor3 = currentTheme.textMain
	themeDarkBtn.TextSize = 11
	themeDarkBtn.Font = Enum.Font.Gotham
	themeDarkBtn.Parent = themeFrame
	Instance.new("UICorner", themeDarkBtn).CornerRadius = UDim.new(0, 4)
	langRegister("dark", themeDarkBtn)

	local themeLightBtn = Instance.new("TextButton")
	themeLightBtn.Size = UDim2.new(0.5, -6, 0, 20)
	themeLightBtn.Position = UDim2.new(0.5, 2, 0, 20)
	themeLightBtn.BorderSizePixel = 2
	themeLightBtn.Text = currentLang.light
	themeLightBtn.TextColor3 = currentTheme.textMain
	themeLightBtn.TextSize = 11
	themeLightBtn.Font = Enum.Font.Gotham
	themeLightBtn.Parent = themeFrame
	Instance.new("UICorner", themeLightBtn).CornerRadius = UDim.new(0, 4)
	langRegister("light", themeLightBtn)

	-- Init theme btns
	if settings.theme == "dark" then
		themeDarkBtn.BackgroundColor3 = currentTheme.btnActiveBg
		themeDarkBtn.BorderColor3 = currentTheme.accentBlue
		themeDarkBtn.Text = currentLang.dark .. " ✓"
		themeLightBtn.BackgroundColor3 = currentTheme.btnBg
		themeLightBtn.BorderColor3 = currentTheme.btnBg
		themeLightBtn.Text = currentLang.light
	else
		themeLightBtn.BackgroundColor3 = currentTheme.btnActiveBg
		themeLightBtn.BorderColor3 = currentTheme.accentBlue
		themeLightBtn.Text = currentLang.light .. " ✓"
		themeDarkBtn.BackgroundColor3 = currentTheme.btnBg
		themeDarkBtn.BorderColor3 = currentTheme.btnBg
		themeDarkBtn.Text = currentLang.dark
	end

	-- Version
	local versionFrame = Instance.new("Frame")
	versionFrame.Size = UDim2.new(1, 0, 0, 32)
	versionFrame.BackgroundColor3 = currentTheme.widgetBg
	versionFrame.BorderSizePixel = 0
	versionFrame.Parent = settingsTab
	Instance.new("UICorner", versionFrame).CornerRadius = UDim.new(0, 6)
	themeRegister(versionFrame, "BackgroundColor3", "widgetBg")

	local versionLabel = Instance.new("TextLabel")
	versionLabel.Size = UDim2.new(1, -12, 0, 14)
	versionLabel.Position = UDim2.new(0, 8, 0, 2)
	versionLabel.BackgroundTransparency = 1
	versionLabel.Text = currentLang.version
	versionLabel.TextColor3 = currentTheme.textMain
	versionLabel.TextSize = 11
	versionLabel.TextXAlignment = Enum.TextXAlignment.Left
	versionLabel.Font = Enum.Font.Gotham
	versionLabel.Parent = versionFrame
	themeRegister(versionLabel, "TextColor3", "textMain")
	langRegister("version", versionLabel)

	local buildLabel = Instance.new("TextLabel")
	buildLabel.Size = UDim2.new(1, -12, 0, 12)
	buildLabel.Position = UDim2.new(0, 8, 0, 16)
	buildLabel.BackgroundTransparency = 1
	buildLabel.Text = currentLang.build
	buildLabel.TextColor3 = currentTheme.textDim
	buildLabel.TextSize = 9
	buildLabel.TextXAlignment = Enum.TextXAlignment.Left
	buildLabel.Font = Enum.Font.Gotham
	buildLabel.Parent = versionFrame
	themeRegister(buildLabel, "TextColor3", "textDim")
	langRegister("build", buildLabel)

	themeDarkBtn.MouseButton1Click:Connect(function()
		applyTheme("dark")
		saveSettings()
		_G.N1V1LON.showMsg(currentLang.dark)
	end)

	themeLightBtn.MouseButton1Click:Connect(function()
		applyTheme("light")
		saveSettings()
		_G.N1V1LON.showMsg(currentLang.light)
	end)

	-- ==================== CLEANUP ====================
	table.insert(_G.N1V1LON.cleanup, function()
		if speedConn then speedConn:Disconnect() end
		if infJumpConn then infJumpConn:Disconnect() end
		if jumpReqConn then jumpReqConn:Disconnect() end
		if aimConn then aimConn:Disconnect() end
		destroySphere()
	end)

	-- ==================== LOG ====================
	logBtn.MouseButton1Click:Connect(function()
		local dataLines = {}
		table.insert(dataLines, "=== N1V1LON Debug Log ===")
		table.insert(dataLines, "Version: v26.2.1.0 Beta")
		table.insert(dataLines, "")
		local okG, gName = pcall(function() return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name end)
		table.insert(dataLines, "Game: " .. (okG and gName or "?"))
		table.insert(dataLines, "PlaceId: " .. game.PlaceId)
		table.insert(dataLines, "JobId: " .. game.JobId)
		table.insert(dataLines, "CreatorId: " .. game.CreatorId)
		table.insert(dataLines, "")
		table.insert(dataLines, "Player: " .. player.Name .. " (" .. player.UserId .. ")")
		table.insert(dataLines, "AccountAge: " .. player.AccountAge)
		local char = player.Character
		if char then
			local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
			if root then table.insert(dataLines, "Pos: " .. tostring(root.Position)) end
			local hum = char:FindFirstChildOfClass("Humanoid")
			if hum then table.insert(dataLines, "HP: " .. math.floor(hum.Health) .. "/" .. hum.MaxHealth .. " WS:" .. hum.WalkSpeed) end
			table.insert(dataLines, "--- Inventory ---")
			local backpack = player:FindFirstChild("Backpack")
			if backpack then
				for _, item in ipairs(backpack:GetChildren()) do
					table.insert(dataLines, "  [Backpack] " .. item.Name .. " (" .. item.ClassName .. ")")
				end
			end
			for _, item in ipairs(char:GetChildren()) do
				if item:IsA("Tool") or item:IsA("Accoutrement") or item:IsA("Accessory") then
					table.insert(dataLines, "  [Char] " .. item.Name .. " (" .. item.ClassName .. ")")
				end
			end
			if root then
				table.insert(dataLines, "--- Nearby Parts (30 studs) ---")
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
		for _, line in ipairs(_G.N1V1LON.logs) do table.insert(dataLines, line) end
		table.insert(dataLines, "")
		table.insert(dataLines, "--- Players ---")
		for _, p in ipairs(Players:GetPlayers()) do
			local info = p.Name
			local c = p.Character
			if c then local h = c:FindFirstChildOfClass("Humanoid"); if h then info = info .. " HP:" .. math.floor(h.Health) end end
			table.insert(dataLines, "  " .. info)
		end
		table.insert(dataLines, "=== End ===")
		local fullText = table.concat(dataLines, "\n")
		local saved = false; local savePath = ""
		pcall(function() makefolder("logsave") end)
		for _, path in ipairs({ "logsave/N1V1LON_log.txt", "N1V1LON_log_save.txt", "log_save.txt", "logsave/log_save.txt" }) do
			if not saved then pcall(function() writefile(path, fullText); saved = true; savePath = path end) end
		end
		if saved then
			addLog("Log: " .. savePath)
			chatLocal("Log saved (" .. #dataLines .. " lines)", Color3.fromRGB(100, 255, 100))
		end
		warn("=== N1V1LON LOG ===\n" .. fullText .. "\n=== END ===")
	end)

	-- ==================== BETA ====================
	betaBtn.MouseButton1Click:Connect(function()
		addLog("β self-update")
		if gui then pcall(function() gui:Destroy() end) end
		if _G.N1V1LON.cleanup then for _, fn in ipairs(_G.N1V1LON.cleanup) do pcall(fn) end end
		task.wait(0.3)
		local okS, script = pcall(function()
			return game:HttpGet("https://raw.githubusercontent.com/N1V1LON/roblox_lua_script/main/test_loading.lua", true)
		end)
		if okS and script then
			local fn = loadstring(script)
			if fn then _G.N1V1LON.cleanup = {}; task.spawn(fn) end
		end
	end)

	-- Apply initial language
	applyLang()

	addLog("Interface v2 loaded!")
	print("[N1V1LON] Interface v2 loaded!")
end)

if not ok then warn("N1V1LON error: " .. tostring(err)) end
