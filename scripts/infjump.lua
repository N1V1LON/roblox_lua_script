local N1V1LON = getgenv().N1V1LON
local player = N1V1LON.Player

local enabled = false
local conn = nil

N1V1LON.CreateButton("Infinite Jump", function(status)
	enabled = not enabled
	if enabled then
		local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.JumpPower = 100
			hum.JumpHeight = 50
		end
		conn = player.CharacterAdded:Connect(function(c)
			local h = c:WaitForChild("Humanoid")
			h.JumpPower = 100
			h.JumpHeight = 50
		end)
		status.Text = "ON"
		status.TextColor3 = Color3.fromRGB(60, 200, 120)
	else
		local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.JumpPower = 50
			hum.JumpHeight = 7.2
		end
		if conn then
			conn:Disconnect()
			conn = nil
		end
		status.Text = "OFF"
		status.TextColor3 = Color3.fromRGB(140, 60, 60)
	end
end)
