-- N1V1LON User Block Manager
-- Run separately to manage who can use the script

local playersUrl = "https://raw.githubusercontent.com/N1V1LON/roblox_lua_script/main/users/players.lua"
local baseUrl = "https://raw.githubusercontent.com/N1V1LON/roblox_lua_script/main/"

local uis = game:GetService("UserInputService")
local ps = game:GetService("Players")

local player = ps.LocalPlayer
if not player then return end

_G.N1V1LON = _G.N1V1LON or {}
_G.N1V1LON.guiBlock = _G.N1V1LON.guiBlock or {}
if _G.N1V1LON.guiBlock.cleanup then
	for _, fn in ipairs(_G.N1V1LON.guiBlock.cleanup) do
		pcall(fn)
	end
end
_G.N1V1LON.guiBlock.cleanup = {}
_G.N1V1LON.guiBlock.playersData = {} -- loaded from GitHub
_G.N1V1LON.guiBlock.modified = {} -- {[userId] = true/false} for pending changes
_G.N1V1LON.guiBlock.running = true

local pg = player:WaitForChild("PlayerGui", 10)
if not pg then return end

local existing = pg:FindFirstChild("N1V1LON_Admin")
if existing then existing:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "N1V1LON_Admin"
gui.ResetOnSpawn = false
gui.Parent = pg

local icon = Instance.new("TextButton")
icon.Name = "Icon"
icon.Size = UDim2.new(0, 48, 0, 48)
icon.Position = UDim2.new(1, -68, 0, 80)
icon.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
icon.BorderSizePixel = 0
icon.Text = "A"
icon.TextColor3 = Color3.fromRGB(255, 255, 255)
icon.TextSize = 28
icon.Font = Enum.Font.GothamBold
icon.Draggable = true
icon.Parent = gui
Instance.new("UICorner", icon).CornerRadius = UDim.new(0, 12)

local menu = Instance.new("Frame")
menu.Name = "Menu"
menu.Size = UDim2.new(0, 400, 0, 400)
menu.Position = UDim2.new(0.5, -200, 0.5, -200)
menu.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
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
title.Size = UDim2.new(0, 200, 1, 0)
title.Position = UDim2.new(0, 8, 0, 0)
title.BackgroundTransparency = 1
title.Text = "N1V1LON Block Manager"
title.TextColor3 = Color3.fromRGB(220, 220, 255)
title.TextSize = 12
title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.GothamBold
title.Parent = titleBar

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0, 100, 1, 0)
statusLabel.Position = UDim2.new(1, -148, 0, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "online"
statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
statusLabel.TextSize = 11
statusLabel.TextXAlignment = Enum.TextXAlignment.Right
statusLabel.Font = Enum.Font.Gotham
statusLabel.Parent = titleBar

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

-- top bar with buttons
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, -20, 0, 28)
topBar.Position = UDim2.new(0, 10, 0, 38)
topBar.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
topBar.BorderSizePixel = 0
topBar.Parent = menu
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 6)

local genBtn = Instance.new("TextButton")
genBtn.Size = UDim2.new(0, 100, 0, 22)
genBtn.Position = UDim2.new(0, 6, 0, 3)
genBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
genBtn.BorderSizePixel = 0
genBtn.Text = "Generate Code"
genBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
genBtn.TextSize = 10
genBtn.Font = Enum.Font.GothamBold
genBtn.Parent = topBar
Instance.new("UICorner", genBtn).CornerRadius = UDim.new(0, 4)

local refreshBtn = Instance.new("TextButton")
refreshBtn.Size = UDim2.new(0, 70, 0, 22)
refreshBtn.Position = UDim2.new(0, 112, 0, 3)
refreshBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 60)
refreshBtn.BorderSizePixel = 0
refreshBtn.Text = "Refresh"
refreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
refreshBtn.TextSize = 10
refreshBtn.Font = Enum.Font.GothamBold
refreshBtn.Parent = topBar
Instance.new("UICorner", refreshBtn).CornerRadius = UDim.new(0, 4)

local statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(0, 180, 1, 0)
statusText.Position = UDim2.new(1, -184, 0, 0)
statusText.BackgroundTransparency = 1
statusText.Text = "Players: 0 | Blocked: 0"
statusText.TextColor3 = Color3.fromRGB(180, 180, 200)
statusText.TextSize = 10
statusText.TextXAlignment = Enum.TextXAlignment.Right
statusText.Font = Enum.Font.Gotham
statusText.Parent = topBar

-- player list
local listFrame = Instance.new("ScrollingFrame")
listFrame.Size = UDim2.new(1, -20, 1, -76)
listFrame.Position = UDim2.new(0, 10, 0, 72)
listFrame.BackgroundTransparency = 1
listFrame.BorderSizePixel = 0
listFrame.ScrollBarThickness = 4
listFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
listFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
listFrame.Parent = menu
local listLayout = Instance.new("UIListLayout")
listLayout.FillDirection = Enum.FillDirection.Vertical
listLayout.Padding = UDim.new(0, 2)
listLayout.Parent = listFrame

local playerRows = {}

local function addLogAdmin(msg)
	if _G.N1V1LON.logs then
		table.insert(_G.N1V1LON.logs, "[Admin] " .. msg)
	end
end

local function fetchBlocklist()
	local ok, raw = pcall(function()
		return game:HttpGet(playersUrl, true)
	end)
	if ok and raw then
		local okFn, data = pcall(loadstring, raw)
		if okFn and type(data) == "table" then
			_G.N1V1LON.guiBlock.playersData = data
			statusLabel.Text = "online"
			statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
			return true
		end
	end
	statusLabel.Text = "offline"
	statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
	return false
end

local function buildPlayerRow(p)
	local userId = p.UserId
	local name = p.Name
	local displayName = p.DisplayName

	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 28)
	row.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
	row.BorderSizePixel = 0
	local rowCorner = Instance.new("UICorner", row)
	rowCorner.CornerRadius = UDim.new(0, 4)

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(0, 140, 1, 0)
	nameLabel.Position = UDim2.new(0, 6, 0, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = displayName ~= name and (displayName .. " [" .. name .. "]") or name
	nameLabel.TextColor3 = Color3.fromRGB(220, 220, 255)
	nameLabel.TextSize = 11
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Font = Enum.Font.Gotham
	nameLabel.Parent = row

	local idLabel = Instance.new("TextLabel")
	idLabel.Size = UDim2.new(0, 70, 1, 0)
	idLabel.Position = UDim2.new(0, 150, 0, 0)
	idLabel.BackgroundTransparency = 1
	idLabel.Text = tostring(userId)
	idLabel.TextColor3 = Color3.fromRGB(140, 140, 160)
	idLabel.TextSize = 10
	idLabel.TextXAlignment = Enum.TextXAlignment.Left
	idLabel.Font = Enum.Font.Gotham
	idLabel.Parent = row

	-- Has N1V1LON indicator
	local hasModLabel = Instance.new("TextLabel")
	hasModLabel.Size = UDim2.new(0, 50, 1, 0)
	hasModLabel.Position = UDim2.new(0, 222, 0, 0)
	hasModLabel.BackgroundTransparency = 1
	hasModLabel.Text = "..."
	hasModLabel.TextColor3 = Color3.fromRGB(180, 180, 100)
	hasModLabel.TextSize = 10
	hasModLabel.Font = Enum.Font.Gotham
	hasModLabel.Parent = row
	task.spawn(function()
		while _G.N1V1LON.guiBlock.running and row.Parent do
			local pg2 = p and p:FindFirstChild("PlayerGui")
			local has = pg2 and pg2:FindFirstChild("N1V1LON")
			hasModLabel.Text = has and "YES" or ""
			hasModLabel.TextColor3 = has and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(80, 80, 80)
			task.wait(2)
		end
	end)

	local data = _G.N1V1LON.guiBlock.playersData
	local isBlocked = data and data[userId] and data[userId].blocked == true
	local modified = _G.N1V1LON.guiBlock.modified[userId]

	local finalBlocked = modified ~= nil and modified or isBlocked

	local statusLabel2 = Instance.new("TextLabel")
	statusLabel2.Size = UDim2.new(0, 50, 1, 0)
	statusLabel2.Position = UDim2.new(0, 274, 0, 0)
	statusLabel2.BackgroundTransparency = 1
	statusLabel2.Text = finalBlocked and "BLOCKED" or "ALLOWED"
	statusLabel2.TextColor3 = finalBlocked and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(100, 255, 100)
	statusLabel2.TextSize = 10
	statusLabel2.Font = Enum.Font.GothamBold
	statusLabel2.Parent = row

	local toggleBtn = Instance.new("TextButton")
	toggleBtn.Size = UDim2.new(0, 60, 0, 22)
	toggleBtn.Position = UDim2.new(1, -66, 0, 3)
	toggleBtn.BackgroundColor3 = finalBlocked and Color3.fromRGB(60, 180, 60) or Color3.fromRGB(180, 60, 60)
	toggleBtn.BorderSizePixel = 0
	toggleBtn.Text = finalBlocked and "Unblock" or "Block"
	toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	toggleBtn.TextSize = 10
	toggleBtn.Font = Enum.Font.GothamBold
	toggleBtn.Parent = row
	Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 4)

	local function updateRowState(blocked)
		local curBlocked = blocked
		statusLabel2.Text = curBlocked and "BLOCKED" or "ALLOWED"
		statusLabel2.TextColor3 = curBlocked and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(100, 255, 100)
		toggleBtn.Text = curBlocked and "Unblock" or "Block"
		toggleBtn.BackgroundColor3 = curBlocked and Color3.fromRGB(60, 180, 60) or Color3.fromRGB(180, 60, 60)
	end

	toggleBtn.MouseButton1Click:Connect(function()
		local data2 = _G.N1V1LON.guiBlock.playersData
		local curBlocked = data2 and data2[userId] and data2[userId].blocked == true
		if _G.N1V1LON.guiBlock.modified[userId] ~= nil then
			curBlocked = _G.N1V1LON.guiBlock.modified[userId]
		end
		_G.N1V1LON.guiBlock.modified[userId] = not curBlocked
		updateRowState(not curBlocked)
	end)

	return row
end

local function rebuildList()
	for _, row in ipairs(playerRows) do
		if row then
			row:Destroy()
		end
	end
	playerRows = {}

	local players = ps:GetPlayers()
	table.sort(players, function(a, b) return a.Name < b.Name end)

	for _, p in ipairs(players) do
		local row = buildPlayerRow(p)
		row.Parent = listFrame
		table.insert(playerRows, row)
	end

	-- update status
	local data = _G.N1V1LON.guiBlock.playersData
	local blockedCount = 0
	if data then
		for uid, info in pairs(data) do
			if type(uid) == "number" and info.blocked then
				blockedCount = blockedCount + 1
			end
		end
	end
	statusText.Text = "Players: " .. #players .. " | Blocked: " .. blockedCount
end

local function generateCode()
	local data = _G.N1V1LON.guiBlock.playersData or {}
	local result = {}
	table.insert(result, "-- N1V1LON player database")
	table.insert(result, "-- keys: player UserId (number)")
	table.insert(result, "-- fields: name, note, first_seen, blocked (bool)")
	table.insert(result, "-- If fetch fails or player not listed -> allowed by default")
	table.insert(result, "-- blocked = true -> script will not run for that player")
	table.insert(result, "")
	table.insert(result, "return {")

	local uids = {}
	for uid in pairs(data) do
		if type(uid) == "number" then
			table.insert(uids, uid)
		end
	end
	-- merge modified
	for uid, val in pairs(_G.N1V1LON.guiBlock.modified) do
		local found = false
		for _, e in ipairs(uids) do
			if e == uid then found = true; break end
		end
		if not found then
			table.insert(uids, uid)
		end
	end
	table.sort(uids)

	for _, uid in ipairs(uids) do
		local info = data[uid] or {}
		local blocked = info.blocked
		if _G.N1V1LON.guiBlock.modified[uid] ~= nil then
			blocked = _G.N1V1LON.guiBlock.modified[uid]
		end
		table.insert(result, "  [" .. uid .. "] = {")
		table.insert(result, "    name = " .. string.format("%q", info.name or "unknown") .. ",")
		table.insert(result, "    blocked = " .. tostring(blocked == true) .. ",")
		if info.note then
			table.insert(result, "    note = " .. string.format("%q", info.note) .. ",")
		end
		table.insert(result, "  },")
	end

	table.insert(result, "}")
	table.insert(result, "")

	local full = table.concat(result, "\n")
	warn("=== N1V1LON BLOCK CODE ===")
	warn(full)
	warn("=== END ===")

	local saved = false
	pcall(function() makefolder("logsave") end)
	pcall(function() makefolder("users") end)
	for _, path in ipairs({ "logsave/N1V1LON_blocklist.lua", "N1V1LON_blocklist.lua", "users/players.lua" }) do
		if not saved then
			local okW = pcall(function() writefile(path, full); saved = true end)
		end
	end
	if saved then
		warn("Written to file. Copy this content and push to GitHub to apply.")
	else
		warn("writefile not available. Copy the code above and push to GitHub.")
	end
end

-- periodic blocklist fetch
task.spawn(function()
	while _G.N1V1LON.guiBlock.running do
		fetchBlocklist()
		task.wait(8)
	end
end)

-- periodic player list refresh
task.spawn(function()
	while _G.N1V1LON.guiBlock.running do
		rebuildList()
		-- update hasMod indicators every 4s
		task.wait(4)
	end
end)

genBtn.MouseButton1Click:Connect(generateCode)
refreshBtn.MouseButton1Click:Connect(function()
	fetchBlocklist()
	rebuildList()
end)

-- initial fetch
task.wait(0.5)
fetchBlocklist()
rebuildList()
addLogAdmin("Block Manager loaded")
