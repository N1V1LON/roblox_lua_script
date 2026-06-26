return function(container, player, uis, rs)
	local aaOn = false
	local aaHeartbeat = nil
	local aaRange = 30
	local zonePart = nil

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
	end)

	local function updateZone()
		if zonePart then zonePart:Destroy() end
		if not aaOn then return end
		local char = player.Character
		if not char then return end
		local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
		if not root then return end
		zonePart = Instance.new("Part")
		zonePart.Size = Vector3.new(aaRange * 2, 0.5, aaRange * 2)
		zonePart.Shape = Enum.PartType.Cylinder
		zonePart.Position = root.Position - Vector3.new(0, root.Size.Y / 2, 0)
		zonePart.Anchored = true
		zonePart.CanCollide = false
		zonePart.Transparency = 0.7
		zonePart.Color = Color3.fromRGB(255, 50, 50)
		zonePart.Material = Enum.Material.Neon
		zonePart.Parent = workspace
	end

	btn.MouseButton1Click:Connect(function()
		aaOn = not aaOn
		if aaOn then
			status.Text = "ON"
			status.TextColor3 = Color3.fromRGB(60, 200, 120)
			if aaHeartbeat then aaHeartbeat:Disconnect() end
			aaHeartbeat = rs.Heartbeat:Connect(function()
				if not aaOn then return end
				local char = player.Character
				if not char then return end
				local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
				if not root then return end
				local pos = root.Position

				updateZone()

				for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
					if p ~= player then
						local c = p.Character
						if c then
							local r = c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso")
							local h = c:FindFirstChildOfClass("Humanoid")
							if r and h and h.Health > 0 then
								if (r.Position - pos).Magnitude < aaRange then
									local success, err = pcall(function()
										h:TakeDamage(5)
									end)
									if not success then
										pcall(function()
											h.Health = h.Health - 5
										end)
									end
								end
							end
						end
					end
				end
			end)
		else
			status.Text = "OFF"
			status.TextColor3 = Color3.fromRGB(140, 60, 60)
			if aaHeartbeat then aaHeartbeat:Disconnect(); aaHeartbeat = nil end
			if zonePart then zonePart:Destroy(); zonePart = nil end
		end
	end)
end
