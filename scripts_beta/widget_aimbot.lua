return function(container, player, uis, rs)
	warn("[N1V1LON DEBUG] Aimbot widget loaded")
	local aimOn = false
	local zoneRadius = 30
	local hitCount = 5
	local aimConn = nil

	local btn = Instance.new("Frame")
	btn.Size = UDim2.new(1, 0, 0, 80)
	btn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
	btn.BorderSizePixel = 0
	btn.Parent = container
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0, 120, 0, 20)
	label.Position = UDim2.new(0, 8, 0, 4)
	label.BackgroundTransparency = 1
	label.Text = "  Aimbot"
	label.TextColor3 = Color3.fromRGB(200, 200, 220)
	label.TextSize = 13
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Font = Enum.Font.Gotham
	label.Parent = btn

	local status = Instance.new("TextButton")
	status.Size = UDim2.new(0, 50, 0, 20)
	status.Position = UDim2.new(1, -55, 0, 4)
	status.BackgroundTransparency = 1
	status.Text = "OFF"
	status.TextColor3 = Color3.fromRGB(140, 60, 60)
	status.TextSize = 12
	status.Font = Enum.Font.GothamBold
	status.Parent = btn

	local zoneLabel = Instance.new("TextLabel")
	zoneLabel.Size = UDim2.new(0, 130, 0, 14)
	zoneLabel.Position = UDim2.new(0, 8, 0, 26)
	zoneLabel.BackgroundTransparency = 1
	zoneLabel.Text = "Zone radius: " .. zoneRadius
	zoneLabel.TextColor3 = Color3.fromRGB(160, 200, 160)
	zoneLabel.TextSize = 11
	zoneLabel.TextXAlignment = Enum.TextXAlignment.Left
	zoneLabel.Font = Enum.Font.Gotham
	zoneLabel.Parent = btn

	local zoneBar = Instance.new("TextButton")
	zoneBar.Size = UDim2.new(1, -20, 0, 8)
	zoneBar.Position = UDim2.new(0, 10, 0, 42)
	zoneBar.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
	zoneBar.BorderSizePixel = 0
	zoneBar.Text = ""
	zoneBar.AutoButtonColor = false
	zoneBar.Parent = btn
	Instance.new("UICorner", zoneBar).CornerRadius = UDim.new(0, 3)

	local zoneFill = Instance.new("Frame")
	zoneFill.Size = UDim2.new(zoneRadius / 200, 0, 1, 0)
	zoneFill.BackgroundColor3 = Color3.fromRGB(60, 200, 120)
	zoneFill.BorderSizePixel = 0
	zoneFill.Parent = zoneBar
	Instance.new("UICorner", zoneFill).CornerRadius = UDim.new(0, 3)

	zoneBar.MouseButton1Click:Connect(function()
		local mx = uis:GetMouseLocation().X
		local posX = zoneBar.AbsolutePosition.X
		local sizeX = zoneBar.AbsoluteSize.X
		if sizeX > 0 then
			local frac = math.clamp((mx - posX) / sizeX, 0, 1)
			zoneRadius = math.max(5, math.floor(frac * 200))
			zoneLabel.Text = "Zone radius: " .. zoneRadius
			zoneFill.Size = UDim2.new(frac, 0, 1, 0)
		end
	end)

	local hitLabel = Instance.new("TextLabel")
	hitLabel.Size = UDim2.new(0, 130, 0, 14)
	hitLabel.Position = UDim2.new(0, 8, 0, 54)
	hitLabel.BackgroundTransparency = 1
	hitLabel.Text = "Hit count: " .. hitCount
	hitLabel.TextColor3 = Color3.fromRGB(200, 200, 100)
	hitLabel.TextSize = 11
	hitLabel.TextXAlignment = Enum.TextXAlignment.Left
	hitLabel.Font = Enum.Font.Gotham
	hitLabel.Parent = btn

	local hitBar = Instance.new("TextButton")
	hitBar.Size = UDim2.new(1, -20, 0, 8)
	hitBar.Position = UDim2.new(0, 10, 0, 70)
	hitBar.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
	hitBar.BorderSizePixel = 0
	hitBar.Text = ""
	hitBar.AutoButtonColor = false
	hitBar.Parent = btn
	Instance.new("UICorner", hitBar).CornerRadius = UDim.new(0, 3)

	local hitFill = Instance.new("Frame")
	hitFill.Size = UDim2.new(hitCount / 50, 0, 1, 0)
	hitFill.BackgroundColor3 = Color3.fromRGB(200, 200, 100)
	hitFill.BorderSizePixel = 0
	hitFill.Parent = hitBar
	Instance.new("UICorner", hitFill).CornerRadius = UDim.new(0, 3)

	hitBar.MouseButton1Click:Connect(function()
		local mx = uis:GetMouseLocation().X
		local posX = hitBar.AbsolutePosition.X
		local sizeX = hitBar.AbsoluteSize.X
		if sizeX > 0 then
			local frac = math.clamp((mx - posX) / sizeX, 0, 1)
			hitCount = math.max(1, math.floor(frac * 50))
			hitLabel.Text = "Hit count: " .. hitCount
			hitFill.Size = UDim2.new(frac, 0, 1, 0)
		end
	end)

	local function getNPCTargets()
		local char = player.Character
		if not char then return {} end
		local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
		if not root then return {} end
		local pos = root.Position

		local playerModels = {}
		for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
			if p.Character then playerModels[p.Character] = true end
		end

		local targets = {}
		for _, obj in ipairs(workspace:GetDescendants()) do
			if not obj:IsA("Humanoid") then continue end
			if obj.Health <= 0 then continue end
			local parent = obj.Parent
			if parent == char then continue end
			if playerModels[parent] then continue end
			local r = parent:FindFirstChild("HumanoidRootPart") or parent:FindFirstChild("Torso") or (parent:IsA("BasePart") and parent) or parent.PrimaryPart
			if r and (r.Position - pos).Magnitude <= zoneRadius then
				table.insert(targets, obj)
			end
		end
		return targets
	end

	local function doAimbot()
		local targets = getNPCTargets()
		if #targets == 0 then return end
		for h = 1, hitCount do
			for _, nhum in ipairs(targets) do
				if nhum.Health > 0 then
					pcall(function() nhum:TakeDamage(15) end)
				end
			end
		end
	end

	status.MouseButton1Click:Connect(function()
		aimOn = not aimOn
		warn("[N1V1LON DEBUG] Aimbot toggled: " .. tostring(aimOn))
		if aimOn then
			status.Text = "ON"
			status.TextColor3 = Color3.fromRGB(60, 200, 120)
			if aimConn then aimConn:Disconnect() end
			aimConn = uis.InputBegan:Connect(function(input, processed)
				if processed then return end
				if aimOn and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
					warn("[N1V1LON DEBUG] Aimbot triggered")
					doAimbot()
				end
			end)
		else
			status.Text = "OFF"
			status.TextColor3 = Color3.fromRGB(140, 60, 60)
			if aimConn then aimConn:Disconnect(); aimConn = nil end
		end
	end)
end
