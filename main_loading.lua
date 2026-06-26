local uis = game:GetService("UserInputService")
local rs = game:GetService("RunService")

-- Cleanup old event connections on re-run
_G.N1V1LON = _G.N1V1LON or {}
if _G.N1V1LON.cleanup then
	for _, fn in ipairs(_G.N1V1LON.cleanup) do
		pcall(fn)
	end
end
_G.N1V1LON.cleanup = {}

local ok, err = pcall(function()
	local player = game:GetService("Players").LocalPlayer
	if not player then
		warn("N1V1LON: No player")
		return
	end

	local pg = player:WaitForChild("PlayerGui", 10)
	if not pg then
		warn("N1V1LON: No PlayerGui")
		return
	end

	local existing = pg:FindFirstChild("N1V1LON")
	if existing then
		existing:Destroy()
	end

	local markerFolder = workspace:FindFirstChild("N1V1LON_Markers")
	if markerFolder then
		markerFolder:Destroy()
	end
	markerFolder = Instance.new("Folder")
	markerFolder.Name = "N1V1LON_Markers"
	markerFolder.Parent = workspace

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
	menu.Size = UDim2.new(0, 300, 0, 380)
	menu.Position = UDim2.new(0.5, -150, 0.5, -125)
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
	version.Text = "v26.1.3.7 Beta"
	version.TextColor3 = Color3.fromRGB(120, 120, 160)
	version.TextSize = 10
	version.TextXAlignment = Enum.TextXAlignment.Left
	version.Font = Enum.Font.Gotham
	version.Parent = titleBar

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(0, 140, 1, 0)
	title.Position = UDim2.new(0, 110, 0, 0)
	title.BackgroundTransparency = 1
	title.Text = "N1V1LON v26.1.3.7 Beta"
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
		if menu.Visible then
			toggleBtn.Text = "<"
		end
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

	local spdStatus = Instance.new("TextLabel")
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

	-- Click entire Speed area to toggle
	local spdClick = Instance.new("TextButton")
	spdClick.Size = UDim2.new(1, 0, 1, 0)
	spdClick.BackgroundTransparency = 1
	spdClick.Text = ""
	spdClick.AutoButtonColor = false
	spdClick.Parent = spdBtn

	spdClick.MouseButton1Click:Connect(function()
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

	-- Row: Infinite Jump + Auto Attack
	local row2 = Instance.new("Frame")
	row2.Size = UDim2.new(1, 0, 0, 40)
	row2.BackgroundTransparency = 1
	row2.Parent = container
	local row2Layout = Instance.new("UIListLayout")
	row2Layout.FillDirection = Enum.FillDirection.Horizontal
	row2Layout.Padding = UDim.new(0, 6)
	row2Layout.Parent = row2

	local function makeHalfCard(parent, label, val, valColor)
		local card = Instance.new("Frame")
		card.Size = UDim2.new(0.5, -3, 1, 0)
		card.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
		card.BorderSizePixel = 0
		card.Parent = parent
		Instance.new("UICorner", card).CornerRadius = UDim.new(0, 6)

		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(0, 120, 1, 0)
		lbl.Position = UDim2.new(0, 8, 0, 0)
		lbl.BackgroundTransparency = 1
		lbl.Text = "  " .. label
		lbl.TextColor3 = Color3.fromRGB(200, 200, 220)
		lbl.TextSize = 13
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Font = Enum.Font.Gotham
		lbl.Parent = card

		local st = Instance.new("TextLabel")
		st.Size = UDim2.new(0, 50, 1, 0)
		st.Position = UDim2.new(1, -55, 0, 0)
		st.BackgroundTransparency = 1
		st.Text = val or "OFF"
		st.TextColor3 = valColor or Color3.fromRGB(140, 60, 60)
		st.TextSize = 12
		st.Font = Enum.Font.GothamBold
		st.Parent = card

		local click = Instance.new("TextButton")
		click.Size = UDim2.new(1, 0, 1, 0)
		click.BackgroundTransparency = 1
		click.Text = ""
		click.AutoButtonColor = false
		click.Parent = card

		return { card = card, status = st, click = click }
	end

	-- Infinite Jump
	local infJumpOn = false
	local infJumpConn = nil
	local jumpReqConn = nil

	local inf = makeHalfCard(row2, "Infinite Jump")
	inf.click.MouseButton1Click:Connect(function()
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
			inf.status.Text = "ON"
			inf.status.TextColor3 = Color3.fromRGB(60, 200, 120)
		else
			if infJumpConn then infJumpConn:Disconnect(); infJumpConn = nil end
			if jumpReqConn then jumpReqConn:Disconnect(); jumpReqConn = nil end
			inf.status.Text = "OFF"
			inf.status.TextColor3 = Color3.fromRGB(140, 60, 60)
		end
	end)

	-- Auto Attack
	local aaOn = false
	local aaHeartbeat = nil

	local aa = makeHalfCard(row2, "Auto Attack")
	aa.click.MouseButton1Click:Connect(function()
		aaOn = not aaOn
		if aaOn then
			aa.status.Text = "ON"
			aa.status.TextColor3 = Color3.fromRGB(60, 200, 120)
			if aaHeartbeat then aaHeartbeat:Disconnect() end
			aaHeartbeat = rs.Heartbeat:Connect(function()
				if not aaOn then return end
				local char = player.Character
				if not char then return end
				local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
				if not root then return end
				local pos = root.Position
				for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
					if p ~= player then
						local c = p.Character
						if c then
							local r = c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso")
							local h = c:FindFirstChildOfClass("Humanoid")
							if r and h and h.Health > 0 then
								if (r.Position - pos).Magnitude < 30 then
									h:TakeDamage(5)
								end
							end
						end
					end
				end
			end)
		else
			aa.status.Text = "OFF"
			aa.status.TextColor3 = Color3.fromRGB(140, 60, 60)
			if aaHeartbeat then aaHeartbeat:Disconnect(); aaHeartbeat = nil end
		end
	end)
end)

if not ok then
	warn("N1V1LON error: " .. tostring(err))
end
