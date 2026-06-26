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
	menu.Size = UDim2.new(0, 300, 0, 250)
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
	version.Text = "v26.0.1.1D"
	version.TextColor3 = Color3.fromRGB(120, 120, 160)
	version.TextSize = 10
	version.TextXAlignment = Enum.TextXAlignment.Left
	version.Font = Enum.Font.Gotham
	version.Parent = titleBar

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(0, 140, 1, 0)
	title.Position = UDim2.new(0, 110, 0, 0)
	title.BackgroundTransparency = 1
	title.Text = "N1V1LON v26.0.1.1D"
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

	local function createButton(text, callback)
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, 0, 0, 32)
		btn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
		btn.BorderSizePixel = 0
		btn.Text = "  " .. text
		btn.TextColor3 = Color3.fromRGB(200, 200, 220)
		btn.TextSize = 13
		btn.TextXAlignment = Enum.TextXAlignment.Left
		btn.Font = Enum.Font.Gotham
		btn.Parent = container
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

		local status = Instance.new("TextLabel")
		status.Size = UDim2.new(0, 50, 1, 0)
		status.Position = UDim2.new(1, -55, 0, 0)
		status.BackgroundTransparency = 1
		status.Text = "OFF"
		status.TextColor3 = Color3.fromRGB(140, 60, 60)
		status.TextSize = 12
		status.Font = Enum.Font.GothamBold
		status.Parent = btn

		btn.MouseButton1Click:Connect(function()
			callback(status)
		end)
	end

	local infJumpOn = false
	local infJumpConn = nil
	local jumpReqConn = nil
	local uis = game:GetService("UserInputService")
	local rs = game:GetService("RunService")

	createButton("Infinite Jump", function(status)
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
			jumpReqConn = uis.JumpRequest:Connect(function()
				if infJumpOn then
					local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
					if hum then
						hum:ChangeState(Enum.HumanoidStateType.Jumping)
					end
				end
			end)
			status.Text = "ON"
			status.TextColor3 = Color3.fromRGB(60, 200, 120)
		else
			if infJumpConn then
				infJumpConn:Disconnect()
				infJumpConn = nil
			end
			if jumpReqConn then
				jumpReqConn:Disconnect()
				jumpReqConn = nil
			end
			status.Text = "OFF"
			status.TextColor3 = Color3.fromRGB(140, 60, 60)
		end
	end)

	local speedOn = false
	local speedVal = 32
	local speedHeartbeat = nil
	local spdDragging = false

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

	local spdDragging = false

	local function setSpeedFromMouse()
		local pos = spdBg.AbsolutePosition
		local size = spdBg.AbsoluteSize.X
		if size > 0 then
			local mx, my = uis:GetMouseLocation()
			local frac = math.clamp((mx - pos.X) / size, 0, 1)
			speedVal = math.floor(frac * 100 + 16)
			spdVal.Text = tostring(speedVal)
			spdFill.Size = UDim2.new(frac, 0, 1, 0)
			if speedOn then
				local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
				if hum then hum.WalkSpeed = speedVal end
			end
		end
	end

	spdBg.MouseButton1Down:Connect(function()
		spdDragging = true
		setSpeedFromMouse()
	end)

	spdBg.MouseButton1Up:Connect(function()
		spdDragging = false
	end)

	uis.InputChanged:Connect(function(input)
		if spdDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			setSpeedFromMouse()
		end
	end)

	uis.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			spdDragging = false
		end
	end)

	local function applySpeed()
		if not speedOn then return end
		local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		if hum and hum.WalkSpeed ~= speedVal then
			hum.WalkSpeed = speedVal
		end
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

	local checkpoints = {}

	local cpFrame = Instance.new("Frame")
	cpFrame.Size = UDim2.new(1, 0, 0, 200)
	cpFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
	cpFrame.BorderSizePixel = 0
	cpFrame.Parent = container
	Instance.new("UICorner", cpFrame).CornerRadius = UDim.new(0, 6)

	local cpHeader = Instance.new("Frame")
	cpHeader.Size = UDim2.new(1, 0, 0, 24)
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
	cpAddBtn.Size = UDim2.new(0, 24, 0, 24)
	cpAddBtn.Position = UDim2.new(1, -32, 0, 0)
	cpAddBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
	cpAddBtn.BorderSizePixel = 0
	cpAddBtn.Text = "+"
	cpAddBtn.TextColor3 = Color3.fromRGB(160, 200, 160)
	cpAddBtn.TextSize = 16
	cpAddBtn.Font = Enum.Font.GothamBold
	cpAddBtn.Parent = cpHeader
	Instance.new("UICorner", cpAddBtn).CornerRadius = UDim.new(0, 4)

	local cpList = Instance.new("ScrollingFrame")
	cpList.Size = UDim2.new(1, -8, 1, -32)
	cpList.Position = UDim2.new(0, 4, 0, 28)
	cpList.BackgroundTransparency = 1
	cpList.BorderSizePixel = 0
	cpList.ScrollBarThickness = 4
	cpList.CanvasSize = UDim2.new(0, 0, 0, 0)
	cpList.Parent = cpFrame
	local cpLayout = Instance.new("UIListLayout")
	cpLayout.FillDirection = Enum.FillDirection.Vertical
	cpLayout.Padding = UDim.new(0, 3)
	cpLayout.Parent = cpList

	local function addCP()
		local char = player.Character
		if not char then return end
		local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
		if not root then return end

		local pos = root.Position
		local id = #checkpoints + 1

		local row = Instance.new("TextButton")
		row.Size = UDim2.new(1, -6, 0, 28)
		row.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
		row.BorderSizePixel = 0
		row.Text = "  CP" .. tostring(id) .. "  (" .. math.floor(pos.X) .. ", " .. math.floor(pos.Y) .. ", " .. math.floor(pos.Z) .. ")"
		row.TextColor3 = Color3.fromRGB(200, 200, 220)
		row.TextSize = 12
		row.Font = Enum.Font.Gotham
		row.TextXAlignment = Enum.TextXAlignment.Left
		row.Parent = cpList
		Instance.new("UICorner", row).CornerRadius = UDim.new(0, 4)

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
						if e == entry then
							table.remove(checkpoints, i)
							break
						end
					end
				end)
			end)
		end)

		row.MouseButton1Up:Connect(function()
			if holdTask then
				task.cancel(holdTask)
				holdTask = nil
			end
			if not held then
				local c = player.Character
				if c then
					local r = c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso")
					if r then
						r.Position = entry.pos
					end
				end
			end
		end)
	end

	cpAddBtn.MouseButton1Click:Connect(addCP)
end)

if not ok then
	warn("N1V1LON error: " .. tostring(err))
end
