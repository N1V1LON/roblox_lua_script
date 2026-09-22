return function(container, player, uis, rs)
	warn("[N1V1LON] Resource Farming module loading...")

	local CollectionService = game:GetService("CollectionService")

	local state = {
		enabled = false,
		distance = 100,
		targetResource = "Ore"
	}

	local resourceNames = {
		"Apple", "Berry", "Carrot", "Cake", "Chili",
		"Old Axe", "Good Axe", "Strong Axe", "Chainsaw", "Spear"
	}

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, 36)
	frame.BackgroundColor3 = Color3.fromRGB(30, 35, 30)
	frame.BorderSizePixel = 0
	frame.Parent = container
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -16, 0, 24)
	title.Position = UDim2.new(0, 8, 0, 4)
	title.BackgroundTransparency = 1
	title.Text = "Auto-Farmer"
	title.TextColor3 = Color3.fromRGB(200, 255, 200)
	title.TextSize = 14
	title.Font = Enum.Font.GothamBold
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = frame

	local status = Instance.new("TextButton")
	status.Size = UDim2.new(0, 60, 0, 20)
	status.Position = UDim2.new(1, -68, 0, 6)
	status.BackgroundColor3 = Color3.fromRGB(45, 60, 45)
	status.Text = "OFF"
	status.TextColor3 = Color3.fromRGB(200, 80, 80)
	status.Font = Enum.Font.GothamBold
	status.TextSize = 12
	status.Parent = frame
	Instance.new("UICorner", status).CornerRadius = UDim.new(0, 4)

	-- Optimization: Using a throttled loop for scanning
	local active = true
	task.spawn(function()
		while active do
			task.wait(1)
			if not active then break end
			if not state.enabled then continue end

			local char = player.Character
			local root = char and char:FindFirstChild("HumanoidRootPart")
			if not root then continue end

			-- Optimization: Scan only specific folders to avoid GetDescendants()
			local targets = {}
			local resourceFolder = workspace:FindFirstChild("Resources") or workspace:FindFirstChild("Drops")
			if resourceFolder then
				targets = resourceFolder:GetChildren()
			else
				-- Fallback to a limited search if no dedicated folder exists
				targets = workspace:GetChildren()
			end

			for _, obj in ipairs(targets) do
				if not state.enabled then break end

				local isTarget = false
				for _, name in ipairs(resourceNames) do
					if obj.Name:find(name) then
						isTarget = true
						break
					end
				end

				if isTarget and obj:IsA("BasePart") then
					local dist = (obj.Position - root.Position).Magnitude
					if dist < state.distance then
						warn("[N1V1LON] Auto-Farming: Found " .. obj.Name)
					end
				end
			end
		end
	end)

	status.MouseButton1Click:Connect(function()
		state.enabled = not state.enabled
		status.Text = state.enabled and "ON" or "OFF"
		status.TextColor3 = state.enabled and Color3.fromRGB(100, 220, 120) or Color3.fromRGB(200, 80, 80)
		if _G.N1V1LON.showMsg then _G.N1V1LON.showMsg("Auto-Farm " .. (state.enabled and "ON" or "OFF")) end
	end)

	table.insert(_G.N1V1LON.cleanup, function()
		active = false
		state.enabled = false
	end)
end
