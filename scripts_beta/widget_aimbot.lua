return function(container, player, uis, rs)
	warn("[N1V1LON] Aimbot (Senior Edition) loading...")

	-- Dependencies & Constants
	local Camera = workspace.CurrentCamera
	local CollectionService = game:GetService("CollectionService")

	-- State
	local state = {
		enabled = false,
		radius = 150,
		smoothness = 0.15,
		visibleCheck = true,
		target = nil
	}

	local npcCache = {}
	local lastScan = 0
	local SCAN_INTERVAL = 2

	-- UI Construction
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, 140)
	frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
	frame.BorderSizePixel = 0
	frame.Parent = container
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -16, 0, 24)
	title.Position = UDim2.new(0, 8, 0, 4)
	title.BackgroundTransparency = 1
	title.Text = "Aimbot & Combat"
	title.TextColor3 = Color3.fromRGB(220, 220, 255)
	title.TextSize = 14
	title.Font = Enum.Font.GothamBold
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = frame

	local status = Instance.new("TextButton")
	status.Size = UDim2.new(0, 60, 0, 20)
	status.Position = UDim2.new(1, -68, 0, 6)
	status.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
	status.Text = "OFF"
	status.TextColor3 = Color3.fromRGB(200, 80, 80)
	status.Font = Enum.Font.GothamBold
	status.TextSize = 12
	status.Parent = frame
	Instance.new("UICorner", status).CornerRadius = UDim.new(0, 4)

	local function makeSlider(yPos, label, initial, min, max, callback)
		local val = initial
		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(1, -20, 0, 16)
		lbl.Position = UDim2.new(0, 10, 0, yPos)
		lbl.BackgroundTransparency = 1
		lbl.Text = label .. ": " .. string.format("%.2f", val)
		lbl.TextColor3 = Color3.fromRGB(180, 180, 200)
		lbl.TextSize = 11
		lbl.Font = Enum.Font.Gotham
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Parent = frame

		local bg = Instance.new("Frame")
		bg.Size = UDim2.new(1, -20, 0, 6)
		bg.Position = UDim2.new(0, 10, 0, yPos + 18)
		bg.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
		bg.BorderSizePixel = 0
		bg.Parent = frame
		Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 3)

		local fill = Instance.new("Frame")
		fill.Size = UDim2.new((val - min) / (max - min), 0, 1, 0)
		fill.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
		fill.BorderSizePixel = 0
		fill.Parent = bg
		Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 3)

		local function update(input)
			local pos = math.clamp((input.Position.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
			val = min + (pos * (max - min))
			fill.Size = UDim2.new(pos, 0, 1, 0)
			lbl.Text = label .. ": " .. string.format("%.2f", val)
			callback(val)
		end

		bg.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				local moveConn, endConn

				moveConn = uis.InputChanged:Connect(function(move)
					if move.UserInputType == Enum.UserInputType.MouseMovement or move.UserInputType == Enum.UserInputType.Touch then
						update(move)
					end
				end)

				endConn = uis.InputEnded:Connect(function(endInput)
					if endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType == Enum.UserInputType.Touch then
						if moveConn then moveConn:Disconnect() end
						if endConn then endConn:Disconnect() end
					end
				end)

				update(input)
			end
		end)
	end

	makeSlider(35, "FOV Radius", state.radius, 10, 500, function(v) state.radius = v end)
	makeSlider(70, "Smoothness", state.smoothness, 0.01, 1, function(v) state.smoothness = v end)

	-- Logic Functions
	local function isVisible(part)
		if not state.visibleCheck then return true end
		local char = player.Character
		if not char then return false end

		local origin = Camera.CFrame.Position
		local dest = part.Position
		local direction = dest - origin

		local params = RaycastParams.new()
		params.FilterDescendantsInstances = {char, part.Parent}
		params.FilterType = Enum.RaycastFilterType.Exclude

		local result = workspace:Raycast(origin, direction, params)
		return result == nil
	end

	local function getNPCPart(model)
		return model:FindFirstChild("Head") or model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
	end

	local function scanNPCs()
		if tick() - lastScan < SCAN_INTERVAL then return end
		lastScan = tick()

		local found = {}
		-- Optimization: Scanning only Players to avoid workspace:GetDescendants()
		for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
			if p ~= player and p.Character then
				local hum = p.Character:FindFirstChildOfClass("Humanoid")
				local root = getNPCPart(p.Character)
				if hum and hum.Health > 0 and root then
					table.insert(found, {h = hum, p = root})
				end
			end
		end

		-- Optional: Scan workspace folder "NPCs" if it exists
		local npcFolder = workspace:FindFirstChild("NPCs")
		if npcFolder then
			for _, v in ipairs(npcFolder:GetChildren()) do
				local hum = v:FindFirstChildOfClass("Humanoid")
				local root = getNPCPart(v)
				if hum and hum.Health > 0 and root then
					table.insert(found, {h = hum, p = root})
				end
			end
		end

		npcCache = found
	end

	local function getClosestTarget()
		local char = player.Character
		local root = char and char:FindFirstChild("HumanoidRootPart")
		if not root then return nil end

		scanNPCs()

		local closest = nil
		local minDist = state.radius

		for _, data in ipairs(npcCache) do
			if data.h.Parent and data.h.Health > 0 then
				local pos, onScreen = Camera:WorldToViewportPoint(data.p.Position)
				if onScreen then
					local mousePos = uis:GetMouseLocation()
					local dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
					if dist < minDist and isVisible(data.p) then
						closest = data.p
						minDist = dist
					end
				end
			end
		end
		return closest
	end

	-- Runtime Loop
	local aimLoop = rs.RenderStepped:Connect(function()
		if not state.enabled then return end

		state.target = getClosestTarget()
		if state.target then
			local currentCF = Camera.CFrame
			local targetCF = CFrame.new(currentCF.Position, state.target.Position)
			Camera.CFrame = currentCF:Lerp(targetCF, state.smoothness)
		end
	end)

	status.MouseButton1Click:Connect(function()
		state.enabled = not state.enabled
		status.Text = state.enabled and "ON" or "OFF"
		status.TextColor3 = state.enabled and Color3.fromRGB(100, 220, 120) or Color3.fromRGB(200, 80, 80)
		if _G.N1V1LON.showMsg then _G.N1V1LON.showMsg("Aimbot: " .. (state.enabled and "Enabled" or "Disabled")) end
	end)

	table.insert(_G.N1V1LON.cleanup, function()
		aimLoop:Disconnect()
	end)
end
