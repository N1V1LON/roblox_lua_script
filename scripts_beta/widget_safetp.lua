return function(container, player, uis, rs)
	warn("[N1V1LON] Safe TP module loading...")

	local state = {
		isTeleporting = false,
		speed = 20 -- studs per step
	}

	local function safeTeleport(targetCFrame)
		if state.isTeleporting then return end
		local char = player.Character
		local root = char and char:FindFirstChild("HumanoidRootPart")
		if not root then return end

		state.isTeleporting = true

		-- Step-by-step logic to avoid anti-cheat "jump" detection
		task.spawn(function()
			while (root.Position - targetCFrame.Position).Magnitude > state.speed do
				if not state.isTeleporting then break end
				local direction = (targetCFrame.Position - root.Position).Unit
				root.CFrame = root.CFrame + (direction * state.speed)
				rs.Heartbeat:Wait()
			end
			if state.isTeleporting then
				root.CFrame = targetCFrame
			end
			state.isTeleporting = false
			if _G.N1V1LON.showMsg then _G.N1V1LON.showMsg("Safe TP: Arrived") end
		end)
	end

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, 40)
	frame.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
	frame.BorderSizePixel = 0
	frame.Parent = container
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(0, 140, 1, 0)
	title.Position = UDim2.new(0, 8, 0, 0)
	title.BackgroundTransparency = 1
	title.Text = "  Safe Teleport"
	title.TextColor3 = Color3.fromRGB(200, 200, 220)
	title.TextSize = 13
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Font = Enum.Font.Gotham
	title.Parent = frame

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 90, 0, 24)
	btn.Position = UDim2.new(1, -98, 0.5, -12)
	btn.BackgroundColor3 = Color3.fromRGB(50, 50, 75)
	btn.BorderSizePixel = 0
	btn.Text = "Safe TP (Spawn)"
	btn.TextColor3 = Color3.fromRGB(100, 200, 255)
	btn.TextSize = 11
	btn.Font = Enum.Font.GothamBold
	btn.Parent = frame
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

	btn.MouseButton1Click:Connect(function()
		local spawnLocation = workspace:FindFirstChildOfClass("SpawnLocation")
		local targetCF = spawnLocation and spawnLocation.CFrame + Vector3.new(0, 3, 0) or CFrame.new(0, 50, 0)
		safeTeleport(targetCF)
	end)

	table.insert(_G.N1V1LON.cleanup, function()
		state.isTeleporting = false
	end)
end
