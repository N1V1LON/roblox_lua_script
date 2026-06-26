return function(container, player, uis, rs)
	warn("[N1V1LON DEBUG] Auto Attack widget loaded")
	local aaOn = false
	local aaRange = 30
	local aaZoneParts = {}
	local aaAttackConn = nil
	local aaUpdateConn = nil

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 32)
	btn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
	btn.BorderSizePixel = 0
	btn.Text = "  Auto Attack"
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

	local rangeLbl = Instance.new("TextButton")
	rangeLbl.Size = UDim2.new(0, 40, 1, 0)
	rangeLbl.Position = UDim2.new(1, -100, 0, 0)
	rangeLbl.BackgroundTransparency = 1
	rangeLbl.Text = tostring(aaRange)
	rangeLbl.TextColor3 = Color3.fromRGB(160, 200, 160)
	rangeLbl.TextSize = 12
	rangeLbl.Font = Enum.Font.GothamBold
	rangeLbl.Parent = btn

	rangeLbl.MouseButton1Click:Connect(function()
		aaRange = aaRange + 5
		if aaRange > 100 then aaRange = 10 end
		rangeLbl.Text = tostring(aaRange)
		warn("[N1V1LON DEBUG] AA range set to " .. aaRange)
		updateZone()
	end)

	local function clearZone()
		for _, p in ipairs(aaZoneParts) do
			pcall(function() p:Destroy() end)
		end
		aaZoneParts = {}
	end

	local function createZone()
		clearZone()
		for i = 1, 24 do
			local angle = (i / 24) * math.pi * 2
			local p = Instance.new("Part")
			p.Size = Vector3.new(0.3, 0.1, 0.3)
			p.Shape = Enum.PartType.Ball
			p.Anchored = true
			p.CanCollide = false
			p.Transparency = 0.3
			p.Color = Color3.fromRGB(255, 50, 50)
			p.Material = Enum.Material.Neon
			p.Parent = workspace
			table.insert(aaZoneParts, p)
		end
	end

	local function updateZone()
		if not aaOn or #aaZoneParts == 0 then return end
		local char = player.Character
		if not char then return end
		local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
		if not root then return end
		local posY = root.Position.Y - (root.Size.Y / 2) - 0.5
		for i, p in ipairs(aaZoneParts) do
			local angle = (i / 24) * math.pi * 2
			p.Position = Vector3.new(math.cos(angle) * aaRange, posY, math.sin(angle) * aaRange)
		end
	end

	local function aaAttack()
		local char = player.Character
		if not char then return end
		local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
		if not root then return end
		local pos = root.Position

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
					if r and h and h.Health > 0 and (r.Position - pos).Magnitude < aaRange then
						local ok = pcall(function() h:TakeDamage(5) end)
						if not ok then pcall(function() h:BreakJoints() end) end
					end
				end
			end
		end

		for _, part in ipairs(workspace:GetDescendants()) do
			if part == char then continue end
			local h = part:FindFirstChildOfClass("Humanoid")
			if h and h.Health > 0 then
				local r = part:FindFirstChild("HumanoidRootPart") or part:FindFirstChild("Torso")
				if r and not playerChars[part] and (r.Position - pos).Magnitude < aaRange then
					local ok = pcall(function() h:TakeDamage(5) end)
					if not ok then pcall(function() h:BreakJoints() end) end
				end
			end
		end
	end

	btn.MouseButton1Click:Connect(function()
		aaOn = not aaOn
		warn("[N1V1LON DEBUG] Auto Attack toggled: " .. tostring(aaOn))
		if aaOn then
			status.Text = "ON"
			status.TextColor3 = Color3.fromRGB(60, 200, 120)
			createZone()
			updateZone()
			if aaUpdateConn then aaUpdateConn:Disconnect() end
			aaUpdateConn = rs.RenderStepped:Connect(updateZone)
			if aaAttackConn then aaAttackConn:Disconnect() end
			aaAttackConn = uis.InputBegan:Connect(function(input, processed)
				if processed then return end
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					warn("[N1V1LON DEBUG] AA triggered on attack")
					aaAttack()
				end
			end)
			warn("[N1V1LON DEBUG] AA armed, zone created")
		else
			status.Text = "OFF"
			status.TextColor3 = Color3.fromRGB(140, 60, 60)
			if aaAttackConn then aaAttackConn:Disconnect(); aaAttackConn = nil end
			if aaUpdateConn then aaUpdateConn:Disconnect(); aaUpdateConn = nil end
			clearZone()
			warn("[N1V1LON DEBUG] AA disarmed")
		end
	end)
end
