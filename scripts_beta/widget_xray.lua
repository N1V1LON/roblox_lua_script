return function(container, player, uis, rs)
	warn("[N1V1LON DEBUG] Xray widget loaded")
	local xrayOn = false
	local npcHighlights = {}

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 32)
	btn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
	btn.BorderSizePixel = 0
	btn.Text = "  Xray"
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

	local function enableXray()
		local playerModels = {}
		for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
			if p.Character then playerModels[p.Character] = true end
		end

		for _, obj in ipairs(workspace:GetDescendants()) do
			if obj:IsA("Humanoid") and obj.Health > 0 then
				local parent = obj.Parent
				if parent == player.Character then continue end
				if playerModels[parent] then continue end
				local hl = Instance.new("Highlight")
				hl.Name = "N1V1LON_Xray"
				hl.FillColor = Color3.fromRGB(255, 50, 50)
				hl.FillTransparency = 0.5
				hl.OutlineColor = Color3.fromRGB(255, 200, 50)
				hl.OutlineTransparency = 0.3
				hl.Parent = parent
				hl.Adornee = parent
				table.insert(npcHighlights, hl)
			end
		end
		warn("[N1V1LON DEBUG] Xray ON — NPC: " .. #npcHighlights)
	end

	local function disableXray()
		for _, hl in ipairs(npcHighlights) do
			pcall(function() hl:Destroy() end)
		end
		npcHighlights = {}
	end

	btn.MouseButton1Click:Connect(function()
		xrayOn = not xrayOn
		warn("[N1V1LON DEBUG] Xray toggled: " .. tostring(xrayOn))
		if xrayOn then
			status.Text = "ON"
			status.TextColor3 = Color3.fromRGB(60, 200, 120)
			enableXray()
		else
			status.Text = "OFF"
			status.TextColor3 = Color3.fromRGB(140, 60, 60)
			disableXray()
		end
	end)
end
