return function(container, player, uis, rs)
	warn("[N1V1LON DEBUG] Aimbot widget loaded")
	local aimOn = false
	local zoneRadius = 50
	local hitCount = 5
	local damagePower = 15
	local aimConn = nil
	local spherePart = nil
	local sphereConn = nil

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, 106)
	frame.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
	frame.BorderSizePixel = 0
	frame.Parent = container
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(0, 120, 0, 20)
	title.Position = UDim2.new(0, 8, 0, 4)
	title.BackgroundTransparency = 1
	title.Text = "  Aimbot"
	title.TextColor3 = Color3.fromRGB(200, 200, 220)
	title.TextSize = 13
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Font = Enum.Font.Gotham
	title.Parent = frame

	local status = Instance.new("TextButton")
	status.Size = UDim2.new(0, 50, 0, 20)
	status.Position = UDim2.new(1, -55, 0, 4)
	status.BackgroundTransparency = 1
	status.Text = "OFF"
	status.TextColor3 = Color3.fromRGB(140, 60, 60)
	status.TextSize = 12
	status.Font = Enum.Font.GothamBold
	status.Parent = frame

	local function makeSlider(yPos, label, getter, setter, maxVal, barColor, labelColor)
		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(0, 130, 0, 14)
		lbl.Position = UDim2.new(0, 8, 0, yPos)
		lbl.BackgroundTransparency = 1
		lbl.Text = label .. getter()
		lbl.TextColor3 = labelColor
		lbl.TextSize = 11
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Font = Enum.Font.Gotham
		lbl.Parent = frame

		local bar = Instance.new("TextButton")
		bar.Size = UDim2.new(1, -20, 0, 8)
		bar.Position = UDim2.new(0, 10, 0, yPos + 16)
		bar.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
		bar.BorderSizePixel = 0
		bar.Text = ""
		bar.AutoButtonColor = false
		bar.Parent = frame
		Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 3)

		local fill = Instance.new("Frame")
		fill.Size = UDim2.new(getter() / maxVal, 0, 1, 0)
		fill.BackgroundColor3 = barColor
		fill.BorderSizePixel = 0
		fill.Parent = bar
		Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 3)

		bar.MouseButton1Click:Connect(function()
			local mx = uis:GetMouseLocation().X
			local px = bar.AbsolutePosition.X
			local sx = bar.AbsoluteSize.X
			if sx > 0 then
				local frac = math.clamp((mx - px) / sx, 0, 1)
				local val = math.max(1, math.floor(frac * maxVal))
				if maxVal == 500 then val = math.max(5, val) end
				setter(val)
				lbl.Text = label .. getter()
				fill.Size = UDim2.new(frac, 0, 1, 0)
			end
		end)

		return lbl, bar, fill
	end

	makeSlider(24, "Zone: ", function() return zoneRadius end, function(v) zoneRadius = v end, 500, Color3.fromRGB(60, 200, 120), Color3.fromRGB(160, 200, 160))
	makeSlider(50, "Hits: ", function() return hitCount end, function(v) hitCount = v end, 50, Color3.fromRGB(200, 200, 100), Color3.fromRGB(200, 200, 100))
	makeSlider(76, "Damage: ", function() return damagePower end, function(v) damagePower = v end, 100, Color3.fromRGB(200, 100, 100), Color3.fromRGB(200, 120, 120))

	local function createSphere()
		if spherePart then pcall(function() spherePart:Destroy() end) end
		spherePart = Instance.new("Part")
		spherePart.Name = "N1V1LON_Sphere"
		spherePart.Shape = Enum.PartType.Ball
		spherePart.Size = Vector3.new(zoneRadius * 2, zoneRadius * 2, zoneRadius * 2)
		spherePart.Anchored = true
		spherePart.CanCollide = false
		spherePart.Transparency = 0.85
		spherePart.Color = Color3.fromRGB(100, 200, 255)
		spherePart.Material = Enum.Material.Neon
		spherePart.Parent = workspace

		if sphereConn then sphereConn:Disconnect() end
		sphereConn = rs.RenderStepped:Connect(function()
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
			if child:IsA("BasePart") then
				return child.Position
			end
		end
		return nil
	end

	local function doAimbot()
		local char = player.Character
		if not char then return end
		local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
		if not root then return end
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
			local npcPos = getNPCPos(parent)
			if npcPos and (npcPos - pos).Magnitude <= zoneRadius then
				table.insert(targets, obj)
			end
		end

		warn("[N1V1LON DEBUG] Aimbot: " .. #targets .. " NPC, damage " .. damagePower .. " x " .. hitCount)
		for h = 1, hitCount do
			for _, nhum in ipairs(targets) do
				if nhum.Health > 0 then
					nhum.Health = nhum.Health - damagePower
					if nhum.Health <= 0 then
						pcall(function() nhum:BreakJoints() end)
					end
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
			createSphere()
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
			destroySphere()
			if aimConn then aimConn:Disconnect(); aimConn = nil end
		end
	end)
end
