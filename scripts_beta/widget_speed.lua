return function(container, player, uis, rs)
	warn("[N1V1LON DEBUG] Speed widget loaded")
	local speedOn = false
	local speedVal = 32
	local speedHeartbeat = nil

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

	local spdValLabel = Instance.new("TextLabel")
	spdValLabel.Size = UDim2.new(0, 50, 0, 20)
	spdValLabel.Position = UDim2.new(1, -105, 0, 4)
	spdValLabel.BackgroundTransparency = 1
	spdValLabel.Text = tostring(speedVal)
	spdValLabel.TextColor3 = Color3.fromRGB(160, 200, 160)
	spdValLabel.TextSize = 12
	spdValLabel.Font = Enum.Font.GothamBold
	spdValLabel.Parent = spdBtn

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
	spdFill.Size = UDim2.new(math.clamp((speedVal - 16) / 100, 0, 1), 0, 1, 0)
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
			spdValLabel.Text = tostring(speedVal)
			spdFill.Size = UDim2.new(frac, 0, 1, 0)
		end
	end)

	local function applySpeed()
		if not speedOn then return end
		local char = player.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum then
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
			if _G.N1V1LON.showMsg then _G.N1V1LON.showMsg("Speed ON — " .. speedVal) end
		else
			if speedHeartbeat then
				speedHeartbeat:Disconnect()
				speedHeartbeat = nil
			end
			local char = player.Character
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			if hum then hum.WalkSpeed = 16 end
			spdStatus.Text = "OFF"
			spdStatus.TextColor3 = Color3.fromRGB(140, 60, 60)
			if _G.N1V1LON.showMsg then _G.N1V1LON.showMsg("Speed OFF") end
		end
	end)

	table.insert(_G.N1V1LON.cleanup, function()
		if speedHeartbeat then speedHeartbeat:Disconnect(); speedHeartbeat = nil end
	end)
end
