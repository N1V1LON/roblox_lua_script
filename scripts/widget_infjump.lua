return function(container, player, uis, rs)
	local infJumpOn = false
	local infJumpConn = nil
	local jumpReqConn = nil

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 32)
	btn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
	btn.BorderSizePixel = 0
	btn.Text = "  Infinite Jump"
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
		infJumpOn = not infJumpOn
		if infJumpOn then
			local function apply(char)
				local hum = char:FindFirstChildOfClass("Humanoid")
				if hum then hum.UseJumpPower = false end
			end
			local char = player.Character
			if char then apply(char) end
			infJumpConn = player.CharacterAdded:Connect(apply)
			jumpReqConn = uis.JumpRequest:Connect(function()
				if infJumpOn then
					local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
					if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
				end
			end)
			if _G.N1V1LON and _G.N1V1LON.cleanup then
				table.insert(_G.N1V1LON.cleanup, function()
					if jumpReqConn then jumpReqConn:Disconnect() end
					if infJumpConn then infJumpConn:Disconnect() end
				end)
			end
			status.Text = "ON"
			status.TextColor3 = Color3.fromRGB(60, 200, 120)
		else
			if infJumpConn then infJumpConn:Disconnect(); infJumpConn = nil end
			if jumpReqConn then jumpReqConn:Disconnect(); jumpReqConn = nil end
			status.Text = "OFF"
			status.TextColor3 = Color3.fromRGB(140, 60, 60)
		end
	end)
end
