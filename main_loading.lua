local uis = game:GetService("UserInputService")
local rs = game:GetService("RunService")

_G.N1V1LON = _G.N1V1LON or {}
if _G.N1V1LON.cleanup then
	for _, fn in ipairs(_G.N1V1LON.cleanup) do
		pcall(fn)
	end
end
_G.N1V1LON.cleanup = {}

local ok, err = pcall(function()
	local player = game:GetService("Players").LocalPlayer
	if not player then return end

	local pg = player:WaitForChild("PlayerGui", 10)
	if not pg then return end

	local existing = pg:FindFirstChild("N1V1LON")
	if existing then existing:Destroy() end

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
				return
			end
		end
	end

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

	local version = Instance.new("TextLabel")
	version.Size = UDim2.new(0, 100, 1, 0)
	version.Position = UDim2.new(0, 8, 0, 0)
	version.BackgroundTransparency = 1
	version.Text = "v26.2.1.0 Realse"
	version.TextColor3 = Color3.fromRGB(120, 120, 160)
	version.TextSize = 10
	version.TextXAlignment = Enum.TextXAlignment.Left
	version.Font = Enum.Font.Gotham
	version.Parent = titleBar

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(0, 140, 1, 0)
	title.Position = UDim2.new(0, 110, 0, 0)
	title.BackgroundTransparency = 1
	title.Text = "N1V1LON v26.2.1.0 Realse"
	title.TextColor3 = Color3.fromRGB(220, 220, 255)
	title.TextSize = 11
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Font = Enum.Font.GothamBold
	title.Parent = titleBar

	local toggleBtn = Instance.new("TextButton")
	toggleBtn.Size = UDim2.new(0, 28, 1, 0)
	toggleBtn.Position = UDim2.new(1, -64, 0, 0)
	toggleBtn.BackgroundTransparency = 1
	toggleBtn.Text = "<"
	toggleBtn.TextColor3 = Color3.fromRGB(200, 200, 100)
	toggleBtn.TextSize = 18
	toggleBtn.Font = Enum.Font.GothamBold
	toggleBtn.Parent = titleBar

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

	toggleBtn.MouseButton1Click:Connect(function()
		menu.Visible = false
		toggleBtn.Text = ">"
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
		if menu.Visible then toggleBtn.Text = "<" end
	end)

	-- Speed
	local speedOn = false
	local speedVal = 32
	local speedHeartbeat = nil

	local spdBtn = Instance.new("Frame")
	spdBtn.Size = UDim2.new(1, 0, 0, 48)
	spdBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
	spdBtn.BorderSizePixel = 0
	spdBtn.Parent = container
	Instance.new("UICorner", spdBtn).CornerRadius = UDim.new(0, 6)

	local spdLabel = Instance.new("TextLabel")
	spdLabel.Size = UDim2.new(0, 120, 0, 20)
	spdLabel.Position = UDim2.new(0, 8, 0, 4)
	spdLabel.BackgroundTransparency = 1
	spdLabel.Text = "  Speed"
	spdLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
	spdLabel.TextSize = 13
	spdLabel.TextXAlignment = Enum.TextXAlignment.Left
	spdLabel.Font = Enum.Font.Gotham
	spdLabel.Parent = spdBtn

	local spdStatus = Instance.new("TextButton")
	spdStatus.Size = UDim2.new(0, 50, 0, 20)
	spdStatus.Position = UDim2.new(1, -55, 0, 4)
	spdStatus.BackgroundTransparency = 1
	spdStatus.Text = "OFF"
	spdStatus.TextColor3 = Color3.fromRGB(140, 60, 60)
	spdStatus.TextSize = 12
	spdStatus.Font = Enum.Font.GothamBold
	spdStatus.Parent = spdBtn

	local spdVal = Instance.new("TextLabel")
	spdVal.Size = UDim2.new(0, 50, 0, 20)
	spdVal.Position = UDim2.new(1, -105, 0, 4)
	spdVal.BackgroundTransparency = 1
	spdVal.Text = tostring(speedVal)
	spdVal.TextColor3 = Color3.fromRGB(160, 200, 160)
	spdVal.TextSize = 12
	spdVal.Font = Enum.Font.GothamBold
	spdVal.Parent = spdBtn

	local spdBg = Instance.new("TextButton")
	spdBg.Size = UDim2.new(1, -20, 0, 10)
	spdBg.Position = UDim2.new(0, 10, 0, 28)
	spdBg.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
	spdBg.BorderSizePixel = 0
	spdBg.Text = ""
	spdBg.AutoButtonColor = false
	spdBg.Parent = spdBtn
	Instance.new("UICorner", spdBg).CornerRadius = UDim.new(0, 3)

	local spdFill = Instance.new("Frame")
	spdFill.Size = UDim2.new((speedVal - 16) / 100, 0, 1, 0)
	spdFill.BackgroundColor3 = Color3.fromRGB(60, 200, 120)
	spdFill.BorderSizePixel = 0
	spdFill.Parent = spdBg
	Instance.new("UICorner", spdFill).CornerRadius = UDim.new(0, 3)

	spdBg.MouseButton1Click:Connect(function()
		local mx = uis:GetMouseLocation().X
		local posX = spdBg.AbsolutePosition.X
		local sizeX = spdBg.AbsoluteSize.X
		if sizeX > 0 then
			local frac = math.clamp((mx - posX) / sizeX, 0, 1)
			speedVal = math.floor(frac * 100 + 16)
			spdVal.Text = tostring(speedVal)
			spdFill.Size = UDim2.new(frac, 0, 1, 0)
		end
	end)

	local function applySpeed()
		if not speedOn then return end
		local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		if hum then hum.WalkSpeed = speedVal end
	end

	spdStatus.MouseButton1Click:Connect(function()
		speedOn = not speedOn
		if speedOn then
			applySpeed()
			if not speedHeartbeat then
				speedHeartbeat = rs.Heartbeat:Connect(applySpeed)
			end
			spdStatus.Text = "ON"
			spdStatus.TextColor3 = Color3.fromRGB(60, 200, 120)
		else
			if speedHeartbeat then
				speedHeartbeat:Disconnect()
				speedHeartbeat = nil
			end
			local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
			if hum then hum.WalkSpeed = 16 end
			spdStatus.Text = "OFF"
			spdStatus.TextColor3 = Color3.fromRGB(140, 60, 60)
		end
	end)

	-- Infinite Jump
	local infJumpOn = false
	local infJumpConn = nil
	local jumpReqConn = nil

	local infBtn = Instance.new("TextButton")
	infBtn.Size = UDim2.new(1, 0, 0, 32)
	infBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
	infBtn.BorderSizePixel = 0
	infBtn.Text = "  Infinite Jump"
	infBtn.TextColor3 = Color3.fromRGB(200, 200, 220)
	infBtn.TextSize = 13
	infBtn.TextXAlignment = Enum.TextXAlignment.Left
	infBtn.Font = Enum.Font.Gotham
	infBtn.Parent = container
	Instance.new("UICorner", infBtn).CornerRadius = UDim.new(0, 6)

	local infStatus = Instance.new("TextLabel")
	infStatus.Size = UDim2.new(0, 50, 1, 0)
	infStatus.Position = UDim2.new(1, -55, 0, 0)
	infStatus.BackgroundTransparency = 1
	infStatus.Text = "OFF"
	infStatus.TextColor3 = Color3.fromRGB(140, 60, 60)
	infStatus.TextSize = 12
	infStatus.Font = Enum.Font.GothamBold
	infStatus.Parent = infBtn

	infBtn.MouseButton1Click:Connect(function()
		infJumpOn = not infJumpOn
		if infJumpOn then
			local function apply(char)
				local hum = char:FindFirstChildOfClass("Humanoid")
				if hum then hum.UseJumpPower = false end
			end
			local char = player.Character
			if char then apply(char) end
			infJumpConn = player.CharacterAdded:Connect(apply)
			jumpReqConn = uis.JumpRequest:Connect(function()
				if infJumpOn then
					local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
					if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
				end
			end)
			table.insert(_G.N1V1LON.cleanup, function()
				if jumpReqConn then jumpReqConn:Disconnect() end
				if infJumpConn then infJumpConn:Disconnect() end
			end)
			infStatus.Text = "ON"
			infStatus.TextColor3 = Color3.fromRGB(60, 200, 120)
		else
			if infJumpConn then infJumpConn:Disconnect(); infJumpConn = nil end
			if jumpReqConn then jumpReqConn:Disconnect(); jumpReqConn = nil end
			infStatus.Text = "OFF"
			infStatus.TextColor3 = Color3.fromRGB(140, 60, 60)
		end
	end)

	-- Auto Attack
	local aaOn = false
	local aaHeartbeat = nil
	local aaRange = 30
	local aaZoneParts = {}

	local aaBtn = Instance.new("TextButton")
	aaBtn.Size = UDim2.new(1, 0, 0, 32)
	aaBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
	aaBtn.BorderSizePixel = 0
	aaBtn.Text = "  Auto Attack"
	aaBtn.TextColor3 = Color3.fromRGB(200, 200, 220)
	aaBtn.TextSize = 13
	aaBtn.TextXAlignment = Enum.TextXAlignment.Left
	aaBtn.Font = Enum.Font.Gotham
	aaBtn.Parent = container
	Instance.new("UICorner", aaBtn).CornerRadius = UDim.new(0, 6)

	local aaStatus = Instance.new("TextLabel")
	aaStatus.Size = UDim2.new(0, 50, 1, 0)
	aaStatus.Position = UDim2.new(1, -55, 0, 0)
	aaStatus.BackgroundTransparency = 1
	aaStatus.Text = "OFF"
	aaStatus.TextColor3 = Color3.fromRGB(140, 60, 60)
	aaStatus.TextSize = 12
	aaStatus.Font = Enum.Font.GothamBold
	aaStatus.Parent = aaBtn

	local function clearZone()
		for _, p in ipairs(aaZoneParts) do
			pcall(function() p:Destroy() end)
		end
		aaZoneParts = {}
	end

	local function drawZone(posY)
		clearZone()
		for i = 1, 24 do
			local angle = (i / 24) * math.pi * 2
			local p = Instance.new("Part")
			p.Size = Vector3.new(0.4, 0.1, 0.4)
			p.Shape = Enum.PartType.Ball
			p.Position = Vector3.new(math.cos(angle) * aaRange, posY, math.sin(angle) * aaRange)
			p.Anchored = true
			p.CanCollide = false
			p.Transparency = 0.3
			p.Color = Color3.fromRGB(255, 50, 50)
			p.Material = Enum.Material.Neon
			p.Parent = workspace
			table.insert(aaZoneParts, p)
		end
	end

	aaBtn.MouseButton1Click:Connect(function()
		aaOn = not aaOn
		if aaOn then
			aaStatus.Text = "ON"
			aaStatus.TextColor3 = Color3.fromRGB(60, 200, 120)
			if aaHeartbeat then aaHeartbeat:Disconnect() end
			aaHeartbeat = rs.Heartbeat:Connect(function()
				if not aaOn then return end
				local char = player.Character
				if not char then return end
				local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
				if not root then return end
				local pos = root.Position
				drawZone(pos.Y - (root.Size.Y / 2) - 0.5)

				local playerChars = {}
				for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
					if p ~= player and p.Character then
						playerChars[p.Character] = true
					end
				end

				for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
					if p ~= player then
						local c = p.Character
						if c then
							local r = c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso")
							local h = c:FindFirstChildOfClass("Humanoid")
							if r and h and h.Health > 0 then
								if (r.Position - pos).Magnitude < aaRange then
									local ok = pcall(function() h:TakeDamage(5) end)
									if not ok then pcall(function() h:BreakJoints() end) end
								end
							end
						end
					end
				end

				for _, part in ipairs(workspace:GetDescendants()) do
					local h = part:FindFirstChildOfClass("Humanoid")
					if h and h.Health > 0 then
						local r = part:FindFirstChild("HumanoidRootPart") or part:FindFirstChild("Torso")
						if r and not playerChars[part] then
							if (r.Position - pos).Magnitude < aaRange then
								local ok = pcall(function() h:TakeDamage(5) end)
								if not ok then pcall(function() h:BreakJoints() end) end
							end
						end
					end
				end
			end)
		else
			aaStatus.Text = "OFF"
			aaStatus.TextColor3 = Color3.fromRGB(140, 60, 60)
			if aaHeartbeat then aaHeartbeat:Disconnect(); aaHeartbeat = nil end
			clearZone()
		end
	end)

	-- Checkpoints
	local checkpoints = {}

	local cpFrame = Instance.new("Frame")
	cpFrame.Size = UDim2.new(1, 0, 0, 120)
	cpFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
	cpFrame.BorderSizePixel = 0
	cpFrame.Parent = container
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
		row.Text = "  CP" .. tostring(id) .. "  (" .. math.floor(pos.X) .. ", " .. math.floor(pos.Y) .. ", " .. math.floor(pos.Z) .. ")"
		row.TextColor3 = Color3.fromRGB(200, 200, 220)
		row.TextSize = 11
		row.Font = Enum.Font.Gotham
		row.TextXAlignment = Enum.TextXAlignment.Left
		row.Parent = cpList
		Instance.new("UICorner", row).CornerRadius = UDim.new(0, 3)

		local entry = { pos = pos, row = row }
		checkpoints[id] = entry

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
					if r then r.Position = entry.pos end
				end
			end
		end)
	end

	cpAddBtn.MouseButton1Click:Connect(addCP)
end)

if not ok then
	warn("N1V1LON error: " .. tostring(err))
end
