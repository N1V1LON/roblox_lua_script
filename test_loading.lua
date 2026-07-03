-- N1V1LON Interface v2 (Beta Loader)
-- Optimized, Modular, and Stabilized
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local getEngineSettings = settings
local player = Players.LocalPlayer

_G.N1V1LON = _G.N1V1LON or {}
if _G.N1V1LON.cleanup then
	for _, fn in ipairs(_G.N1V1LON.cleanup) do
		pcall(fn)
	end
end
_G.N1V1LON.cleanup = {}
_G.N1V1LON.logs = _G.N1V1LON.logs or {}

local function addLog(msg)
	local info = os.date("!%X")
	table.insert(_G.N1V1LON.logs, "[" .. info .. "] " .. msg)
	print("[N1V1LON LOG] " .. msg)
end

-- ==================== SETTINGS ====================
local SETTINGS_PATH = "N1V1LON_beta_settings.txt"
local settings = { language = "ru", theme = "dark" }

local function saveSettings()
	pcall(function() writefile(SETTINGS_PATH, HttpService:JSONEncode(settings)) end)
end

local function loadSettings()
	local ok, raw = pcall(function() return readfile(SETTINGS_PATH) end)
	if ok and raw then
		local ok2, data = pcall(function() return HttpService:JSONDecode(raw) end)
		if ok2 and type(data) == "table" then
			for k, v in pairs(data) do settings[k] = v end
		end
	end
end
loadSettings()

-- ==================== THEMES ====================
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
	pcall(function() obj[prop] = currentTheme[colorKey] end)
end

local function themeApply()
	currentTheme = themes[settings.theme] or themes.dark
	for _, entry in ipairs(allThemed) do
		pcall(function() entry.obj[entry.prop] = currentTheme[entry.colorKey] end)
	end
end

-- ==================== I18N ====================
local T = {
	ru = {
		player = "Игрок",
		server = "Сервер",
		settings = "Настройки",
		optimization = "Оптимизация",
		version = "v26.2.2.0 Beta",
		build = "Сборка: beta (modular)",
		language = "Язык / Language",
		theme = "Тема оформления",
		dark = "Тёмная",
		light = "Светлая",
		fps = "FPS Boost",
		graphics = "Качество графики",
		fog = "Туман",
		clouds = "Облака",
		particles = "Частицы",
		charVis = "Прозрачность персонажа",
		reset = "Сброс",
		on = "ВКЛ",
		off = "ВЫКЛ",
	},
	en = {
		player = "Player",
		server = "Server",
		settings = "Settings",
		optimization = "Optimization",
		version = "v26.2.2.0 Beta",
		build = "Build: beta (modular)",
		language = "Language / Язык",
		theme = "Theme",
		dark = "Dark",
		light = "Light",
		fps = "FPS Boost",
		graphics = "Graphics Quality",
		fog = "Fog",
		clouds = "Clouds",
		particles = "Particles",
		charVis = "Character Transparency",
		reset = "Reset",
		on = "ON",
		off = "OFF",
	},
}

local currentLang = T[settings.language] or T.ru
local langLabels = {}

local function langRegister(key, obj)
	table.insert(langLabels, { key = key, obj = obj })
	pcall(function() obj.Text = currentLang[key] or key end)
end

local function langApply()
	currentLang = T[settings.language] or T.ru
	for _, item in ipairs(langLabels) do
		pcall(function() item.obj.Text = currentLang[item.key] or item.key end)
	end
end

local function makeDraggable(obj, target)
	target = target or obj
	local dragging, dragStart, startPos
	local dragConn

	obj.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = target.Position

			if dragConn then dragConn:Disconnect() end
			dragConn = UserInputService.InputChanged:Connect(function(moveInput)
				if moveInput.UserInputType == Enum.UserInputType.MouseMovement or moveInput.UserInputType == Enum.UserInputType.Touch then
					local delta = moveInput.Position - dragStart
					target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
				end
			end)

			local releaseConn
			releaseConn = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
					if dragConn then dragConn:Disconnect(); dragConn = nil end
					if releaseConn then releaseConn:Disconnect() end
				end
			end)
		end
	end)
end

-- ==================== SAFE EXECUTION ====================
local ok, err = pcall(function()

-- ==================== GUI ROOT ====================
local pg = player:WaitForChild("PlayerGui")
local existing = pg:FindFirstChild("N1V1LON_BETA")
if existing then existing:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "N1V1LON_BETA"
gui.ResetOnSpawn = false
gui.Parent = pg

-- Message Toast System
_G.N1V1LON.showMsg = function(text)
	return text
end

-- Icon
local icon = Instance.new("TextButton")
icon.Size = UDim2.new(0, 48, 0, 48)
icon.Position = UDim2.new(1, -68, 0, 20)
icon.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
icon.BorderSizePixel = 0
icon.Text = "N"
icon.TextColor3 = Color3.fromRGB(220, 220, 255)
icon.TextSize = 28
icon.Font = Enum.Font.GothamBold
icon.Parent = gui
makeDraggable(icon)
Instance.new("UICorner", icon).CornerRadius = UDim.new(0, 12)

local betaTag = Instance.new("TextLabel")
betaTag.Size = UDim2.new(0, 14, 0, 14)
betaTag.Position = UDim2.new(1, -14, 1, -14)
betaTag.BackgroundTransparency = 1
betaTag.Text = "β"
betaTag.TextColor3 = Color3.fromRGB(100, 200, 255)
betaTag.TextSize = 11
betaTag.Font = Enum.Font.GothamBold
betaTag.Parent = icon

-- Main Menu
local menu = Instance.new("Frame")
menu.Size = UDim2.new(0, 320, 0, 420)
menu.Position = UDim2.new(0.5, -160, 0.5, -210)
menu.BackgroundColor3 = currentTheme.menuBg
menu.BorderSizePixel = 0
menu.Visible = false
menu.ClipsDescendants = true
menu.Parent = gui
Instance.new("UICorner", menu).CornerRadius = UDim.new(0, 10)
themeRegister(menu, "BackgroundColor3", "menuBg")

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 36)
titleBar.BackgroundColor3 = currentTheme.titleBarBg
titleBar.BorderSizePixel = 0
titleBar.Parent = menu
themeRegister(titleBar, "BackgroundColor3", "titleBarBg")
makeDraggable(titleBar, menu)

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(0, 100, 1, 0)
titleText.Position = UDim2.new(0, 12, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "N1V1LON"
titleText.TextColor3 = currentTheme.textTitle
titleText.TextSize = 14
titleText.Font = Enum.Font.GothamBold
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Parent = titleBar
themeRegister(titleText, "TextColor3", "textTitle")

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 36, 0, 36)
closeBtn.Position = UDim2.new(1, -36, 0, 0)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(200, 60, 60)
closeBtn.TextSize = 18
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = titleBar

closeBtn.MouseEnter:Connect(function() closeBtn.BackgroundTransparency = 0.8 end)
closeBtn.MouseLeave:Connect(function() closeBtn.BackgroundTransparency = 1 end)

closeBtn.MouseButton1Click:Connect(function() menu.Visible = false end)
icon.MouseButton1Click:Connect(function() menu.Visible = not menu.Visible end)

-- Tabs System
local tabsFrame = Instance.new("Frame")
tabsFrame.Size = UDim2.new(1, 0, 0, 32)
tabsFrame.Position = UDim2.new(0, 0, 0, 36)
tabsFrame.BackgroundColor3 = currentTheme.tabsBg
tabsFrame.BorderSizePixel = 0
tabsFrame.Parent = menu
themeRegister(tabsFrame, "BackgroundColor3", "tabsBg")

local function createTab(name, key, index)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1/4, 0, 1, 0)
	btn.Position = UDim2.new((index-1)/4, 0, 0, 0)
	btn.BackgroundTransparency = 1
	btn.Text = ""
	btn.TextColor3 = currentTheme.textDim
	btn.TextSize = 12
	btn.Font = Enum.Font.GothamBold
	btn.Parent = tabsFrame
	langRegister(key, btn)
	themeRegister(btn, "TextColor3", "textDim")

	btn.MouseEnter:Connect(function()
		btn.TextColor3 = currentTheme.accentBlue
	end)

	local indicator = Instance.new("Frame")

	btn.MouseLeave:Connect(function()
		if not indicator.Visible then
			btn.TextColor3 = currentTheme.textDim
		end
	end)

	indicator.Size = UDim2.new(0.6, 0, 0, 2)
	indicator.Position = UDim2.new(0.2, 0, 1, -2)
	indicator.BackgroundColor3 = currentTheme.accentBlue
	indicator.BorderSizePixel = 0
	indicator.Visible = false
	indicator.Parent = btn
	themeRegister(indicator, "BackgroundColor3", "accentBlue")

	return btn, indicator
end

local tabPlayer, indPlayer = createTab("Player", "player", 1)
local tabServer, indServer = createTab("Server", "server", 2)
local tabSettings, indSettings = createTab("Settings", "settings", 3)
local tabOptimization, indOptimization = createTab("Optimization", "optimization", 4)

local content = Instance.new("Frame")
content.Size = UDim2.new(1, 0, 1, -68)
content.Position = UDim2.new(0, 0, 0, 68)
content.BackgroundTransparency = 1
content.Parent = menu

local function createContentFrame()
	local f = Instance.new("ScrollingFrame")
	f.Size = UDim2.new(1, -16, 1, -10)
	f.Position = UDim2.new(0, 8, 0, 5)
	f.BackgroundTransparency = 1
	f.BorderSizePixel = 0
	f.ScrollBarThickness = 2
	f.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 120)
	f.CanvasSize = UDim2.new(0, 0, 0, 0)
	f.Visible = false
	f.Parent = content
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 8)
	layout.Parent = f
	local function updateCanvas()
		f.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
	end
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
	task.spawn(updateCanvas)
	return f
end

local framePlayer = createContentFrame()
local frameServer = createContentFrame()
local frameSettings = createContentFrame()
local frameOptimization = createContentFrame()

local function switchTab(tabName)
	framePlayer.Visible = (tabName == "player")
	frameServer.Visible = (tabName == "server")
	frameSettings.Visible = (tabName == "settings")
	frameOptimization.Visible = (tabName == "optimization")

	indPlayer.Visible = (tabName == "player")
	indServer.Visible = (tabName == "server")
	indSettings.Visible = (tabName == "settings")
	indOptimization.Visible = (tabName == "optimization")

	tabPlayer.TextColor3 = (tabName == "player") and currentTheme.accentBlue or currentTheme.textDim
	tabServer.TextColor3 = (tabName == "server") and currentTheme.accentBlue or currentTheme.textDim
	tabSettings.TextColor3 = (tabName == "settings") and currentTheme.accentBlue or currentTheme.textDim
	tabOptimization.TextColor3 = (tabName == "optimization") and currentTheme.accentBlue or currentTheme.textDim
end

tabPlayer.MouseButton1Click:Connect(function() switchTab("player") end)
tabServer.MouseButton1Click:Connect(function() switchTab("server") end)
tabSettings.MouseButton1Click:Connect(function() switchTab("settings") end)
tabOptimization.MouseButton1Click:Connect(function() switchTab("optimization") end)

switchTab("player")

-- ==================== MODULAR LOADING ====================
local baseUrl = "https://raw.githubusercontent.com/N1V1LON/roblox_lua_script/main/scripts_beta/"

local function loadWidget(fileName, container)
	task.spawn(function()
		local success, result = pcall(function()
			return game:HttpGet(baseUrl .. fileName, true)
		end)

		if success and result then
			local fn, err = loadstring(result)
			if fn then
				local moduleOk, widgetOrErr = pcall(fn)
				if moduleOk and type(widgetOrErr) == "function" then
					local ok, runErr = pcall(widgetOrErr, container, player, UserInputService, RunService)
					if ok then
						addLog("Widget loaded: " .. fileName)
					else
						warn("[N1V1LON] Runtime error in " .. fileName .. ": " .. tostring(runErr))
					end
				elseif moduleOk then
					warn("[N1V1LON] Invalid widget module " .. fileName)
				else
					warn("[N1V1LON] Runtime error in " .. fileName .. ": " .. tostring(widgetOrErr))
				end
			else
				warn("[N1V1LON] Syntax error in " .. fileName .. ": " .. tostring(err))
			end
		else
			warn("[N1V1LON] Failed to download " .. fileName)
		end
	end)
end

-- Load Widgets
loadWidget("widget_speed.lua", framePlayer)
loadWidget("widget_infjump.lua", framePlayer)
loadWidget("widget_esp.lua", framePlayer)
loadWidget("widget_aimbot.lua", framePlayer)
loadWidget("widget_farm.lua", frameServer)

loadWidget("widget_checkpoints.lua", frameServer)

-- ==================== OPTIMIZATION TAB ====================
local originalOpt = {
	fogEnd = game:GetService("Lighting").FogEnd,
	globalShadows = game:GetService("Lighting").GlobalShadows,
	quality = getEngineSettings().Rendering.QualityLevel,
	particles = {},
	cloudsEnabled = true,
}

do
	local terrain = workspace:FindFirstChildOfClass("Terrain")
	local clouds = terrain and terrain:FindFirstChildOfClass("Clouds")
	if clouds then originalOpt.cloudsEnabled = clouds.Enabled end
end

local function setClouds(enabled)
	local terrain = workspace:FindFirstChildOfClass("Terrain")
	local clouds = terrain and terrain:FindFirstChildOfClass("Clouds")
	if clouds then clouds.Enabled = enabled end
end

local function setParticles(enabled)
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
			if originalOpt.particles[obj] == nil then originalOpt.particles[obj] = obj.Enabled end
			obj.Enabled = enabled
		end
	end
end

local function resetOptimization()
	local lighting = game:GetService("Lighting")
	lighting.FogEnd = originalOpt.fogEnd
	lighting.GlobalShadows = originalOpt.globalShadows
	getEngineSettings().Rendering.QualityLevel = originalOpt.quality
	setClouds(originalOpt.cloudsEnabled)
	for obj, enabled in pairs(originalOpt.particles) do
		if obj and obj.Parent then obj.Enabled = enabled end
	end
	local char = player.Character
	if char then
		for _, v in ipairs(char:GetDescendants()) do
			if v:IsA("BasePart") then v.Transparency = 0 end
		end
	end
end

local buildOptUI

local function refreshOptimizationUI()
	if frameOptimization and frameOptimization.Parent then
		buildOptUI()
	end
end

buildOptUI = function()
	for _, v in ipairs(frameOptimization:GetChildren()) do
		if not v:IsA("UIListLayout") then v:Destroy() end
	end

	local optState = {
		fps = false, fog = false, clouds = false,
		particles = false, charVis = false, graphics = 3,
	}

	local function applyOpt(name)
		pcall(function()
			local lighting = game:GetService("Lighting")
			if name == "fps" then
				lighting.GlobalShadows = not optState.fps
				getEngineSettings().Rendering.QualityLevel = optState.fps and Enum.QualityLevel.Level01 or originalOpt.quality
			elseif name == "fog" then
				lighting.FogEnd = optState.fog and 9e9 or originalOpt.fogEnd
			elseif name == "clouds" then
				setClouds(not optState.clouds)
			elseif name == "particles" then
				setParticles(not optState.particles)
			elseif name == "charVis" then
				local char = player.Character
				if char then
					for _, v in ipairs(char:GetDescendants()) do
						if v:IsA("BasePart") then v.Transparency = optState.charVis and 0.9 or 0 end
					end
				end
			end
		end)
	end

	local function makeToggle(key, name)
		local f = Instance.new("Frame")
		f.Size = UDim2.new(1, 0, 0, 44)
		f.BackgroundColor3 = currentTheme.widgetBg
		f.BorderSizePixel = 0
		f.Parent = frameOptimization
		Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)
		themeRegister(f, "BackgroundColor3", "widgetBg")

		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(0, 140, 1, 0)
		lbl.Position = UDim2.new(0, 10, 0, 0)
		lbl.BackgroundTransparency = 1
		lbl.TextColor3 = currentTheme.textMain
		lbl.TextSize = 13
		lbl.Font = Enum.Font.Gotham
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Parent = f
		langRegister(key, lbl)
		themeRegister(lbl, "TextColor3", "textMain")

		local stat = Instance.new("TextLabel")
		stat.Size = UDim2.new(0, 40, 0, 20)
		stat.Position = UDim2.new(1, -50, 0, 12)
		stat.BackgroundTransparency = 1
		stat.Text = currentLang.off
		stat.TextColor3 = currentTheme.statusOff
		stat.TextSize = 11
		stat.Font = Enum.Font.GothamBold
		stat.Parent = f
		themeRegister(stat, "TextColor3", "statusOff")

		local toggleBg = Instance.new("Frame")
		toggleBg.Size = UDim2.new(0, 54, 0, 24)
		toggleBg.Position = UDim2.new(1, -64, 0.5, -12)
		toggleBg.BackgroundColor3 = currentTheme.btnBg
		toggleBg.BorderSizePixel = 0
		toggleBg.Parent = f
		Instance.new("UICorner", toggleBg).CornerRadius = UDim.new(0, 12)
		themeRegister(toggleBg, "BackgroundColor3", "btnBg")

		local knob = Instance.new("Frame")
		knob.Size = UDim2.new(0, 18, 0, 18)
		knob.Position = UDim2.new(0, 3, 0.5, -9)
		knob.BackgroundColor3 = currentTheme.textMain
		knob.BorderSizePixel = 0
		knob.Parent = toggleBg
		Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
		themeRegister(knob, "BackgroundColor3", "textMain")

		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(0, 64, 1, 0)
		btn.Position = UDim2.new(1, -64, 0, 0)
		btn.BackgroundTransparency = 1
		btn.Text = ""
		btn.Parent = f

		local function syncToggleVisual(on)
			stat.Text = on and currentLang.on or currentLang.off
			stat.TextColor3 = on and currentTheme.statusOn or currentTheme.statusOff
			toggleBg.BackgroundColor3 = on and currentTheme.btnActiveBg or currentTheme.btnBg
			knob.Position = on and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
		end

		syncToggleVisual(false)
		btn.MouseButton1Click:Connect(function()
			optState[name] = not optState[name]
			syncToggleVisual(optState[name])
			applyOpt(name)
		end)
	end

	makeToggle("fps", "fps")
	makeToggle("fog", "fog")
	makeToggle("clouds", "clouds")
	makeToggle("particles", "particles")
	makeToggle("charVis", "charVis")

	-- Graphics slider
	local gfx = Instance.new("Frame")
	gfx.Size = UDim2.new(1, 0, 0, 44)
	gfx.BackgroundColor3 = currentTheme.widgetBg
	gfx.BorderSizePixel = 0
	gfx.Parent = frameOptimization
	Instance.new("UICorner", gfx).CornerRadius = UDim.new(0, 6)
	themeRegister(gfx, "BackgroundColor3", "widgetBg")

	local gfxLbl = Instance.new("TextLabel")
	gfxLbl.Size = UDim2.new(0, 140, 1, 0)
	gfxLbl.Position = UDim2.new(0, 10, 0, 0)
	gfxLbl.BackgroundTransparency = 1
	gfxLbl.TextColor3 = currentTheme.textMain
	gfxLbl.TextSize = 13
	gfxLbl.Font = Enum.Font.Gotham
	gfxLbl.TextXAlignment = Enum.TextXAlignment.Left
	gfxLbl.Parent = gfx
	langRegister("graphics", gfxLbl)
	themeRegister(gfxLbl, "TextColor3", "textMain")

	local gfxVal = Instance.new("TextLabel")
	gfxVal.Size = UDim2.new(0, 30, 0, 20)
	gfxVal.Position = UDim2.new(1, -40, 0, 12)
	gfxVal.BackgroundTransparency = 1
	gfxVal.Text = tostring(optState.graphics)
	gfxVal.TextColor3 = currentTheme.accentBlue
	gfxVal.TextSize = 12
	gfxVal.Font = Enum.Font.GothamBold
	gfxVal.Parent = gfx

	local gfxBg = Instance.new("TextButton")
	gfxBg.Size = UDim2.new(0, 80, 0, 6)
	gfxBg.Position = UDim2.new(1, -130, 0, 19)
	gfxBg.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
	gfxBg.BorderSizePixel = 0
	gfxBg.Text = ""
	gfxBg.AutoButtonColor = false
	gfxBg.Parent = gfx
	Instance.new("UICorner", gfxBg).CornerRadius = UDim.new(0, 3)

	local gfxFill = Instance.new("Frame")
	gfxFill.Size = UDim2.new(optState.graphics / 10, 0, 1, 0)
	gfxFill.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
	gfxFill.BorderSizePixel = 0
	gfxFill.Parent = gfxBg
	Instance.new("UICorner", gfxFill).CornerRadius = UDim.new(0, 3)

	gfxBg.MouseButton1Click:Connect(function()
		local mx = uis:GetMouseLocation().X
		local posX = gfxBg.AbsolutePosition.X
		local sizeX = gfxBg.AbsoluteSize.X
		if sizeX > 0 then
			local frac = math.clamp((mx - posX) / sizeX, 0, 1)
			optState.graphics = math.clamp(math.floor(frac * 10), 1, 10)
			gfxVal.Text = tostring(optState.graphics)
			gfxFill.Size = UDim2.new(optState.graphics / 10, 0, 1, 0)
			getEngineSettings().Rendering.QualityLevel = Enum.QualityLevel["Level" .. string.format("%02d", optState.graphics)] or Enum.QualityLevel.Automatic
		end
	end)

	local resetBtn = Instance.new("TextButton")
	resetBtn.Size = UDim2.new(1, -16, 0, 32)
	resetBtn.BackgroundColor3 = currentTheme.btnBg
	resetBtn.Text = currentLang.reset
	resetBtn.TextColor3 = currentTheme.textMain
	resetBtn.TextSize = 14
	resetBtn.Font = Enum.Font.GothamBold
	resetBtn.Parent = frameOptimization
	Instance.new("UICorner", resetBtn).CornerRadius = UDim.new(0, 6)
	themeRegister(resetBtn, "BackgroundColor3", "btnBg")
	themeRegister(resetBtn, "TextColor3", "textMain")

	resetBtn.MouseButton1Click:Connect(function()
		resetOptimization()
		buildOptUI()
		addLog("Optimization reset")
		if _G.N1V1LON.showMsg then _G.N1V1LON.showMsg("Optimization Reset") end
	end)
end

buildOptUI()

table.insert(_G.N1V1LON.cleanup, function()
	resetOptimization()
end)

-- ==================== SETTINGS TAB ====================
local function createSettingGroup(titleKey, parent)
	local f = Instance.new("Frame")
	f.Size = UDim2.new(1, 0, 0, 60)
	f.BackgroundColor3 = currentTheme.widgetBg
	f.BorderSizePixel = 0
	f.Parent = parent
	Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)
	themeRegister(f, "BackgroundColor3", "widgetBg")

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, -12, 0, 20)
	lbl.Position = UDim2.new(0, 8, 0, 4)
	lbl.BackgroundTransparency = 1
	lbl.TextColor3 = currentTheme.textMain
	lbl.TextSize = 12
	lbl.Font = Enum.Font.GothamMedium
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = f
	langRegister(titleKey, lbl)
	themeRegister(lbl, "TextColor3", "textMain")

	return f
end

-- Language Group
local langGroup = createSettingGroup("language", frameSettings)
local btnRu = Instance.new("TextButton")
btnRu.Size = UDim2.new(0.5, -12, 0, 24)
btnRu.Position = UDim2.new(0, 8, 0, 28)
btnRu.BackgroundColor3 = settings.language == "ru" and currentTheme.btnActiveBg or currentTheme.btnBg
btnRu.Text = "Русский"
btnRu.TextColor3 = currentTheme.textMain
btnRu.Font = Enum.Font.Gotham
btnRu.Parent = langGroup
Instance.new("UICorner", btnRu).CornerRadius = UDim.new(0, 4)

local btnEn = Instance.new("TextButton")
btnEn.Size = UDim2.new(0.5, -12, 0, 24)
btnEn.Position = UDim2.new(0.5, 4, 0, 28)
btnEn.BackgroundColor3 = settings.language == "en" and currentTheme.btnActiveBg or currentTheme.btnBg
btnEn.Text = "English"
btnEn.TextColor3 = currentTheme.textMain
btnEn.Font = Enum.Font.Gotham
btnEn.Parent = langGroup
Instance.new("UICorner", btnEn).CornerRadius = UDim.new(0, 4)

btnRu.MouseButton1Click:Connect(function()
	settings.language = "ru"
	langApply()
	refreshOptimizationUI()
	saveSettings()
	btnRu.BackgroundColor3 = currentTheme.btnActiveBg
	btnEn.BackgroundColor3 = currentTheme.btnBg
end)

btnEn.MouseButton1Click:Connect(function()
	settings.language = "en"
	langApply()
	refreshOptimizationUI()
	saveSettings()
	btnEn.BackgroundColor3 = currentTheme.btnActiveBg
	btnRu.BackgroundColor3 = currentTheme.btnBg
end)

-- Theme Group
local themeGroup = createSettingGroup("theme", frameSettings)
local btnDark = Instance.new("TextButton")
btnDark.Size = UDim2.new(0.5, -12, 0, 24)
btnDark.Position = UDim2.new(0, 8, 0, 28)
btnDark.BackgroundColor3 = settings.theme == "dark" and currentTheme.btnActiveBg or currentTheme.btnBg
btnDark.TextColor3 = currentTheme.textMain
btnDark.Font = Enum.Font.Gotham
btnDark.Parent = themeGroup
Instance.new("UICorner", btnDark).CornerRadius = UDim.new(0, 4)
langRegister("dark", btnDark)

local btnLight = Instance.new("TextButton")
btnLight.Size = UDim2.new(0.5, -12, 0, 24)
btnLight.Position = UDim2.new(0.5, 4, 0, 28)
btnLight.BackgroundColor3 = settings.theme == "light" and currentTheme.btnActiveBg or currentTheme.btnBg
btnLight.TextColor3 = currentTheme.textMain
btnLight.Font = Enum.Font.Gotham
btnLight.Parent = themeGroup
Instance.new("UICorner", btnLight).CornerRadius = UDim.new(0, 4)
langRegister("light", btnLight)

btnDark.MouseButton1Click:Connect(function()
	settings.theme = "dark"
	themeApply()
	refreshOptimizationUI()
	saveSettings()
	btnDark.BackgroundColor3 = currentTheme.btnActiveBg
	btnLight.BackgroundColor3 = currentTheme.btnBg
end)

btnLight.MouseButton1Click:Connect(function()
	settings.theme = "light"
	themeApply()
	refreshOptimizationUI()
	saveSettings()
	btnLight.BackgroundColor3 = currentTheme.btnActiveBg
	btnDark.BackgroundColor3 = currentTheme.btnBg
end)

-- Version Info
local verFrame = Instance.new("Frame")
verFrame.Size = UDim2.new(1, 0, 0, 40)
verFrame.BackgroundTransparency = 1
verFrame.Parent = frameSettings

local verLabel = Instance.new("TextLabel")
verLabel.Size = UDim2.new(1, 0, 0, 18)
verLabel.BackgroundTransparency = 1
verLabel.TextColor3 = currentTheme.textDim
verLabel.TextSize = 11
verLabel.Font = Enum.Font.Gotham
verLabel.Parent = verFrame
langRegister("version", verLabel)

local buildLabel = Instance.new("TextLabel")
buildLabel.Size = UDim2.new(1, 0, 0, 14)
buildLabel.Position = UDim2.new(0, 0, 0, 18)
buildLabel.BackgroundTransparency = 1
buildLabel.TextColor3 = currentTheme.textDim
buildLabel.TextSize = 9
buildLabel.Font = Enum.Font.Gotham
buildLabel.Parent = verFrame
langRegister("build", buildLabel)

-- ==================== FINAL ====================
addLog("Interface v2.2 Beta Loaded")
_G.N1V1LON.showMsg("N1V1LON Beta Loaded")

end) -- pcall

if not ok then
	warn("N1V1LON Beta error: " .. tostring(err))
end
