local N1V1LON = getgenv().N1V1LON
local player = N1V1LON.Player

local enabled = false
local conn = nil

N1V1LON.CreateButton("Speed x2", function(status)
	enabled = not enabled
	if enabled then
		local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.WalkSpeed = 32
		end
		conn = player.CharacterAdded:Connect(function(c)
			local h = c:WaitForChild("Humanoid")
			h.WalkSpeed = 32
		end)
		status.Text = "ON"
		status.TextColor3 = Color3.fromRGB(60, 200, 120)
	else
		local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.WalkSpeed = 16
		end
		if conn then
			conn:Disconnect()
			conn = nil
		end
		status.Text = "OFF"
		status.TextColor3 = Color3.fromRGB(140, 60, 60)
	end
end)
