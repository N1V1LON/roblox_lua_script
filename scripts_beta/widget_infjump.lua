return function(container, player, uis, rs)
	warn("[N1V1LON DEBUG] Infinite Jump widget loaded")
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

	local function disconnect()
		if infJumpConn then infJumpConn:Disconnect(); infJumpConn = nil end
		if jumpReqConn then jumpReqConn:Disconnect(); jumpReqConn = nil end
	end

	btn.MouseButton1Click:Connect(function()
		infJumpOn = not infJumpOn
		if infJumpOn then
			local function apply(char)
				if not char then return end
				local hum = char:FindFirstChildOfClass("Humanoid")
				if hum then
					hum.UseJumpPower = false
				end
			end
			local char = player.Character
			if char then apply(char) end
			disconnect()
			infJumpConn = player.CharacterAdded:Connect(apply)
			jumpReqConn = uis.JumpRequest:Connect(function()
				if infJumpOn then
					local char = player.Character
					local hum = char and char:FindFirstChildOfClass("Humanoid")
					if hum then
						hum:ChangeState(Enum.HumanoidStateType.Jumping)
					end
				end
			end)
			status.Text = "ON"
			status.TextColor3 = Color3.fromRGB(60, 200, 120)
			if _G.N1V1LON.showMsg then _G.N1V1LON.showMsg("InfJump ON") end
		else
			disconnect()
			status.Text = "OFF"
			status.TextColor3 = Color3.fromRGB(140, 60, 60)
			if _G.N1V1LON.showMsg then _G.N1V1LON.showMsg("InfJump OFF") end
		end
	end)

	table.insert(_G.N1V1LON.cleanup, function()
		disconnect()
	end)
end
