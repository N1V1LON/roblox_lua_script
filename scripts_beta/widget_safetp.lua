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

	-- UI for demo
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 32)
	btn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
	btn.Text = "Safe TP to 0, 100, 0"
	btn.TextColor3 = Color3.fromRGB(200, 200, 220)
	btn.Font = Enum.Font.GothamBold
	btn.Parent = container
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

	btn.MouseButton1Click:Connect(function()
		safeTeleport(CFrame.new(0, 100, 0))
	end)

	-- Update widget_checkpoints to use this logic if needed
end
