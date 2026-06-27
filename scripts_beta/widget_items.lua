return function(container, player, uis, rs)
	warn("[N1V1LON DEBUG] Items widget loaded")
	local itemsOn = false
	local itemHighlights = {}

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 32)
	btn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
	btn.BorderSizePixel = 0
	btn.Text = "  Items"
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

	local keywords = {
		"ore", "iron", "gold", "diamond", "ruby", "emerald", "coal",
		"crystal", "gem", "mineral", "stone", "rock", "chest", "coin",
		"token", "loot", "box", "resource", "node", "vein", "crate",
		"amethyst", "sapphire", "topaz", "platinum", "silver", "bronze",
		"copper", "steel", "mithril", "adamant", "runite", "dragon",
	}

	local function isCollectible(name)
		local lower = name:lower()
		for _, kw in ipairs(keywords) do
			if lower:find(kw, 1, true) then
				return true
			end
		end
		return false
	end

	local function enableItems()
		local count = 0
		for _, obj in ipairs(workspace:GetDescendants()) do
			if obj:IsA("BasePart") and isCollectible(obj.Name) then
				local hl = Instance.new("Highlight")
				hl.Name = "N1V1LON_Item"
				hl.FillColor = Color3.fromRGB(50, 150, 255)
				hl.FillTransparency = 0.4
				hl.OutlineColor = Color3.fromRGB(255, 255, 100)
				hl.OutlineTransparency = 0.2
				hl.Parent = obj
				hl.Adornee = obj
				table.insert(itemHighlights, hl)
				count = count + 1
			end
		end
		warn("[N1V1LON DEBUG] Items ON — найдено: " .. count)
	end

	local function disableItems()
		for _, hl in ipairs(itemHighlights) do
			pcall(function() hl:Destroy() end)
		end
		itemHighlights = {}
	end

	btn.MouseButton1Click:Connect(function()
		itemsOn = not itemsOn
		warn("[N1V1LON DEBUG] Items toggled: " .. tostring(itemsOn))
		if itemsOn then
			status.Text = "ON"
			status.TextColor3 = Color3.fromRGB(60, 200, 120)
			enableItems()
		else
			status.Text = "OFF"
			status.TextColor3 = Color3.fromRGB(140, 60, 60)
			disableItems()
		end
	end)
end
