return function(container, player, uis, rs)
	local aaOn = false
	local aaRange = 30

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

	btn.MouseButton1Click:Connect(function()
		aaOn = not aaOn
		if aaOn then
			status.Text = "ON"
			status.TextColor3 = Color3.fromRGB(60, 200, 120)
			task.spawn(function()
				while aaOn do
					local char = player.Character
					if char then
						local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
						if root then
							local pos = root.Position
							for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
								if p ~= player then
									local c = p.Character
									if c then
										local r = c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso")
										local h = c:FindFirstChildOfClass("Humanoid")
										if r and h and h.Health > 0 then
											if (r.Position - pos).Magnitude < aaRange then
												pcall(function() h:TakeDamage(5) end)
											end
										end
									end
								end
							end
						end
					end
					task.wait(0.1)
				end
			end)
		else
			status.Text = "OFF"
			status.TextColor3 = Color3.fromRGB(140, 60, 60)
		end
	end)
end
