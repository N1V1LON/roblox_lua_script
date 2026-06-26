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
	version.Text = "v26.1.3.6 Beta"
	version.TextColor3 = Color3.fromRGB(120, 120, 160)
	version.TextSize = 10
	version.TextXAlignment = Enum.TextXAlignment.Left
	version.Font = Enum.Font.Gotham
	version.Parent = titleBar

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(0, 140, 1, 0)
	title.Position = UDim2.new(0, 110, 0, 0)
	title.BackgroundTransparency = 1
	title.Text = "N1V1LON v26.1.3.6 Beta"
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

	local infJumpOn = false
	local infJumpConn = nil
	local jumpReqConn = nil

	local function makeToggle(label, parent)
		local status = Instance.new("TextLabel")
		status.Size = UDim2.new(0, 50, 0, 20)
		status.Position = UDim2.new(1, -55, 0, 4)
		status.BackgroundTransparency = 1
		status.Text = "OFF"
		status.TextColor3 = Color3.fromRGB(140, 60, 60)
		status.TextSize = 12
		status.Font = Enum.Font.GothamBold
		status.Parent = parent

		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(0, 120, 0, 20)
		lbl.Position = UDim2.new(0, 8, 0, 4)
		lbl.BackgroundTransparency = 1
		lbl.Text = "  " .. label
		lbl.TextColor3 = Color3.fromRGB(200, 200, 220)
		lbl.TextSize = 13
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Font = Enum.Font.Gotham
		lbl.Parent = parent
		return status
	end

	-- Row: Speed + Infinite Jump
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 48)
	row.BackgroundTransparency = 1
	row.Parent = container
	local rowLayout = Instance.new("UIListLayout")
	rowLayout.FillDirection = Enum.FillDirection.Horizontal
	rowLayout.Padding = UDim.new(0, 6)
	rowLayout.Parent = row

	-- Speed
	local spdBtn = Instance.new("Frame")
	spdBtn.Size = UDim2.new(0.5, -3, 1, 0)
	spdBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
	spdBtn.BorderSizePixel = 0
	spdBtn.Parent = row
	Instance.new("UICorner", spdBtn).CornerRadius = UDim.new(0, 6)

	local spdLbl = Instance.new("TextLabel")
	spdLbl.Size = UDim2.new(0, 120, 0, 20)
	spdLbl.Position = UDim2.new(0, 8, 0, 4)
	spdLbl.BackgroundTransparency = 1
	spdLbl.Text = "  Speed"
	spdLbl.TextColor3 = Color3.fromRGB(200, 200, 220)
	spdLbl.TextSize = 13
	spdLbl.TextXAlignment = Enum.TextXAlignment.Left
	spdLbl.Font = Enum.Font.Gotham
	spdLbl.Parent = spdBtn

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
	spdVal.Text = "32"
	spdVal.TextColor3 = Color3.fromRGB(160, 200, 160)
	spdVal.TextSize = 12
	spdVal.Font = Enum.Font.GothamBold
	spdVal.Parent = spdBtn

	local speedOn = false
	local speedVal = 32
	local speedHeartbeat = nil

	local spdBg = Instance.new("TextButton")
	spdBg.Size = UDim2.new(1, -12, 0, 8)
	spdBg.Position = UDim2.new(0, 6, 0, 30)
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

	spdBtn.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
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
		end
	end)

	-- Infinite Jump
	local infBtn = Instance.new("Frame")
	infBtn.Size = UDim2.new(0.5, -3, 1, 0)
	infBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
	infBtn.BorderSizePixel = 0
	infBtn.Parent = row
	Instance.new("UICorner", infBtn).CornerRadius = UDim.new(0, 6)

	local infStatus = makeToggle("Infinite Jump", infBtn)

	infBtn.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
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
		end
	end)

	-- Checkpoints
	local checkpoints = {}
	local cpColors = {
		Color3.fromRGB(255, 80, 80),
		Color3.fromRGB(80, 255, 80),
		Color3.fromRGB(80, 130, 255),
		Color3.fromRGB(255, 200, 50),
		Color3.fromRGB(200, 80, 255),
		Color3.fromRGB(80, 255, 230),
		Color3.fromRGB(255, 130, 50),
		Color3.fromRGB(255, 80, 200),
	}
	local cpColorIdx = 0

	local cpFrame = Instance.new("Frame")
	cpFrame.Size = UDim2.new(1, 0, 0, 100)
	cpFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
	cpFrame.BorderSizePixel = 0
	cpFrame.Parent = container
	Instance.new("UICorner", cpFrame).CornerRadius = UDim.new(0, 6)

	local cpHeader = Instance.new("Frame")
	cpHeader.Size = UDim2.new(1, 0, 0, 20)
	cpHeader.BackgroundTransparency = 1
	cpHeader.Parent = cpFrame

	local cpLabel = Instance.new("TextLabel")
	cpLabel.Size = UDim2.new(0, 100, 1, 0)
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

		cpColorIdx = cpColorIdx + 1
		local color = cpColors[((cpColorIdx - 1) % #cpColors) + 1]
		local pos = root.Position
		local id = #checkpoints + 1

		local marker = Instance.new("Part")
		marker.Size = Vector3.new(2, 2, 2)
		marker.Shape = Enum.PartType.Ball
		marker.Material = Enum.Material.Neon
		marker.Color = color
		marker.Position = pos
		marker.Anchored = true
		marker.CanCollide = false
		marker.Parent = markerFolder

		local bbg = Instance.new("BillboardGui")
		bbg.Size = UDim2.new(0, 60, 0, 20)
		bbg.StudsOffset = Vector3.new(0, 2.5, 0)
		bbg.AlwaysOnTop = true
		bbg.Parent = marker
		local bl = Instance.new("TextLabel")
		bl.Size = UDim2.new(1, 0, 1, 0)
		bl.BackgroundTransparency = 1
		bl.Text = "CP" .. tostring(id)
		bl.TextColor3 = color
		bl.TextSize = 12
		bl.Font = Enum.Font.GothamBold
		bl.Parent = bbg

		local entry = { pos = pos, row = nil, marker = marker }

		local row = Instance.new("TextButton")
		row.Size = UDim2.new(1, -6, 0, 18)
		row.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
		row.BorderSizePixel = 0
		row.Text = ""
		row.AutoButtonColor = false
		row.Parent = cpList
		Instance.new("UICorner", row).CornerRadius = UDim.new(0, 3)
		entry.row = row

		local dot = Instance.new("Frame")
		dot.Size = UDim2.new(0, 8, 0, 8)
		dot.Position = UDim2.new(0, 4, 0.5, -4)
		dot.BackgroundColor3 = color
		dot.BorderSizePixel = 0
		dot.Parent = row
		Instance.new("UICorner", dot).CornerRadius = UDim.new(0, 4)

		local nameLbl = Instance.new("TextLabel")
		nameLbl.Size = UDim2.new(0, 30, 1, 0)
		nameLbl.Position = UDim2.new(0, 16, 0, 0)
		nameLbl.BackgroundTransparency = 1
		nameLbl.Text = "CP" .. tostring(id)
		nameLbl.TextColor3 = Color3.fromRGB(200, 200, 220)
		nameLbl.TextSize = 10
		nameLbl.TextXAlignment = Enum.TextXAlignment.Left
		nameLbl.Font = Enum.Font.Gotham
		nameLbl.Parent = row

		local posLbl = Instance.new("TextLabel")
		posLbl.Size = UDim2.new(0, 120, 1, 0)
		posLbl.Position = UDim2.new(0, 48, 0, 0)
		posLbl.BackgroundTransparency = 1
		posLbl.Text = "(" .. math.floor(pos.X) .. ")"
		posLbl.TextColor3 = Color3.fromRGB(140, 140, 160)
		posLbl.TextSize = 9
		posLbl.TextXAlignment = Enum.TextXAlignment.Left
		posLbl.Font = Enum.Font.Gotham
		posLbl.Parent = row

		local held = false
		local holdTask = nil

		row.MouseButton1Down:Connect(function()
			held = false
			holdTask = task.delay(0.5, function()
				held = true
				row.BackgroundColor3 = Color3.fromRGB(80, 40, 40)
				if entry.marker then pcall(function() entry.marker:Destroy() end) end
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

		checkpoints[id] = entry
	end

	cpAddBtn.MouseButton1Click:Connect(addCP)

	-- Auto Attack
	local aaOn = false
	local aaHeartbeat = nil

	local aaBtn = Instance.new("Frame")
	aaBtn.Size = UDim2.new(1, 0, 0, 32)
	aaBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
	aaBtn.BorderSizePixel = 0
	aaBtn.Parent = container
	Instance.new("UICorner", aaBtn).CornerRadius = UDim.new(0, 6)

	local aaLbl = Instance.new("TextLabel")
	aaLbl.Size = UDim2.new(0, 200, 1, 0)
	aaLbl.Position = UDim2.new(0, 8, 0, 0)
	aaLbl.BackgroundTransparency = 1
	aaLbl.Text = "  Auto Attack"
	aaLbl.TextColor3 = Color3.fromRGB(200, 200, 220)
	aaLbl.TextSize = 13
	aaLbl.TextXAlignment = Enum.TextXAlignment.Left
	aaLbl.Font = Enum.Font.Gotham
	aaLbl.Parent = aaBtn

	local aaStatus = Instance.new("TextLabel")
	aaStatus.Size = UDim2.new(0, 50, 1, 0)
	aaStatus.Position = UDim2.new(1, -55, 0, 0)
	aaStatus.BackgroundTransparency = 1
	aaStatus.Text = "OFF"
	aaStatus.TextColor3 = Color3.fromRGB(140, 60, 60)
	aaStatus.TextSize = 12
	aaStatus.Font = Enum.Font.GothamBold
	aaStatus.Parent = aaBtn

	local aaRange = Instance.new("TextLabel")
	aaRange.Size = UDim2.new(0, 40, 1, 0)
	aaRange.Position = UDim2.new(1, -100, 0, 0)
	aaRange.BackgroundTransparency = 1
	aaRange.Text = "30"
	aaRange.TextColor3 = Color3.fromRGB(160, 200, 160)
	aaRange.TextSize = 12
	aaRange.Font = Enum.Font.GothamBold
	aaRange.Parent = aaBtn

	aaBtn.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
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
					for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
						if p ~= player then
							local c = p.Character
							if c then
								local r = c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso")
								local h = c:FindFirstChildOfClass("Humanoid")
								if r and h and h.Health > 0 then
									local dist = (r.Position - pos).Magnitude
									if dist < 30 then
										h:TakeDamage(5)
									end
								end
							end
						end
					end
				end)
			else
				aaStatus.Text = "OFF"
				aaStatus.TextColor3 = Color3.fromRGB(140, 60, 60)
				if aaHeartbeat then aaHeartbeat:Disconnect(); aaHeartbeat = nil end
			end
		end
	end)
end)

if not ok then
	warn("N1V1LON error: " .. tostring(err))
end
