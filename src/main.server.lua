local Players = game:GetService("Players")

Players.PlayerAdded:Connect(function(player)
	print(("Player %s joined the game"):format(player.Name))
end)
