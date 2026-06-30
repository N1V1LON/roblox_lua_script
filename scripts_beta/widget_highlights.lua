return function(container, player, uis, rs)
	warn("[N1V1LON DEBUG] Highlights widget loaded")
	local npcOn = false
	local itemsOn = false
	local npcHighlights = {}
	local itemHighlights = {}

	local npcCache = {}
	local itemCache = {}
	local lastScan = 0
	local SCAN_COOLDOWN = 5 -- Scan every 5 seconds

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, 68)
	frame.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
	frame.BorderSizePixel = 0
	frame.Parent = container
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(0, 120, 0, 20)
	title.Position = UDim2.new(0, 8, 0, 4)
	title.BackgroundTransparency = 1
	title.Text = "  Highlights"
	title.TextColor3 = Color3.fromRGB(200, 200, 220)
	title.TextSize = 13
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Font = Enum.Font.Gotham
	title.Parent = frame

	local npcBtn = Instance.new("TextButton")
	npcBtn.Size = UDim2.new(0.5, -6, 0, 24)
	npcBtn.Position = UDim2.new(0, 8, 0, 26)
	npcBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
	npcBtn.BorderSizePixel = 0
	npcBtn.Text = ""
	npcBtn.AutoButtonColor = false
	npcBtn.Parent = frame
	Instance.new("UICorner", npcBtn).CornerRadius = UDim.new(0, 4)

	local npcLabel = Instance.new("TextLabel")
	npcLabel.Size = UDim2.new(0.7, -4, 1, 0)
	npcLabel.Position = UDim2.new(0, 6, 0, 0)
	npcLabel.BackgroundTransparency = 1
	npcLabel.Text = "NPC"
	npcLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
	npcLabel.TextSize = 12
	npcLabel.TextXAlignment = Enum.TextXAlignment.Left
	npcLabel.Font = Enum.Font.Gotham
	npcLabel.Parent = npcBtn

	local npcStatus = Instance.new("TextLabel")
	npcStatus.Size = UDim2.new(0.3, -2, 1, 0)
	npcStatus.Position = UDim2.new(0.7, 2, 0, 0)
	npcStatus.BackgroundTransparency = 1
	npcStatus.Text = "OFF"
	npcStatus.TextColor3 = Color3.fromRGB(140, 60, 60)
	npcStatus.TextSize = 11
	npcStatus.TextXAlignment = Enum.TextXAlignment.Center
	npcStatus.Font = Enum.Font.GothamBold
	npcStatus.Parent = npcBtn

	local itemBtn = Instance.new("TextButton")
	itemBtn.Size = UDim2.new(0.5, -6, 0, 24)
	itemBtn.Position = UDim2.new(0.5, 2, 0, 26)
	itemBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
	itemBtn.BorderSizePixel = 0
	itemBtn.Text = ""
	itemBtn.AutoButtonColor = false
	itemBtn.Parent = frame
	Instance.new("UICorner", itemBtn).CornerRadius = UDim.new(0, 4)

	local itemLabel = Instance.new("TextLabel")
	itemLabel.Size = UDim2.new(0.7, -4, 1, 0)
	itemLabel.Position = UDim2.new(0, 6, 0, 0)
	itemLabel.BackgroundTransparency = 1
	itemLabel.Text = "Items"
	itemLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
	itemLabel.TextSize = 12
	itemLabel.TextXAlignment = Enum.TextXAlignment.Left
	itemLabel.Font = Enum.Font.Gotham
	itemLabel.Parent = itemBtn

	local itemStatus = Instance.new("TextLabel")
	itemStatus.Size = UDim2.new(0.3, -2, 1, 0)
	itemStatus.Position = UDim2.new(0.7, 2, 0, 0)
	itemStatus.BackgroundTransparency = 1
	itemStatus.Text = "OFF"
	itemStatus.TextColor3 = Color3.fromRGB(140, 60, 60)
	itemStatus.TextSize = 11
	itemStatus.TextXAlignment = Enum.TextXAlignment.Center
	itemStatus.Font = Enum.Font.GothamBold
	itemStatus.Parent = itemBtn

	local info = Instance.new("TextLabel")
	info.Size = UDim2.new(1, -16, 0, 14)
	info.Position = UDim2.new(0, 8, 0, 52)
	info.BackgroundTransparency = 1
	info.Text = ""
	info.TextColor3 = Color3.fromRGB(120, 120, 160)
	info.TextSize = 10
	info.TextXAlignment = Enum.TextXAlignment.Left
	info.Font = Enum.Font.Gotham
	info.Parent = frame

	local npcNames = {
		"Alpha Wolf", "Wolf", "Crossbow Cultist", "Cultist",
		"Bunny", "Bear", "Polar Bear",
	}

	local itemNames = {
		"Apple", "Berry", "Bolt", "Broken Fan", "Broken Microwave",
		"Bunny Foot", "Cake", "Carrot", "Chest", "Chilli", "Coal",
		"Coin Stack", "Cultist Gem", "Deer", "Fuel Canister",
		"Good Sack", "Good Axe", "Iron Body", "Item Chest",
		"Item Chest2", "Item Chest3", "Item Chest4", "Item Chest6",
		"Leather Body", "Log", "Medkit", "Meat? Sandwich", "Morsel",
		"Old Car Engine", "Old Flashlight", "Old Radio", "Oil Barrel",
		"Revolver", "Revolver Ammo", "Rifle", "Rifle Ammo",
		"Riot Shield", "Sapling", "Seed Box", "Sheet Metal", "Spear",
		"Steak", "Stronghold Diamond Chest", "Tyre", "Washing Machine",
		"Wolf Corpse", "Wolf Pelt", "Alpha Wolf Pelt", "Bandage",
		"Anvil Base", "Lost Child", "Lost Child2", "Lost Child3",
		"Lost Child4",
	}

	local function inList(name, list)
		for _, v in ipairs(list) do
			if v == name then return true end
		end
		return false
	end

	local function clearHighlights(tbl)
		for obj, hl in pairs(tbl) do
			pcall(function() hl:Destroy() end)
		end
		return {}
	end

	local function countTable(t)
		local c = 0
		for _ in pairs(t) do c = c + 1 end
		return c
	end

	local function scanWorkspace()
		if tick() - lastScan < SCAN_COOLDOWN then return end
		lastScan = tick()

		local newNpcCache = {}
		local newItemCache = {}

		for _, obj in ipairs(workspace:GetDescendants()) do
			if obj:IsA("Model") and inList(obj.Name, npcNames) then
				if obj:FindFirstChildOfClass("Humanoid") then
					table.insert(newNpcCache, obj)
				end
			elseif inList(obj.Name, itemNames) then
				table.insert(newItemCache, obj)
			end
		end
		npcCache = newNpcCache
		itemCache = newItemCache
	end

	local function updateNPC()
		npcHighlights = clearHighlights(npcHighlights)
		if not npcOn then return end

		scanWorkspace()
		local count = 0
		for _, obj in ipairs(npcCache) do
			if obj.Parent then
				local hl = Instance.new("Highlight")
				hl.Name = "N1V1LON_NPC"
				hl.FillColor = Color3.fromRGB(255, 50, 50)
				hl.FillTransparency = 0.5
				hl.OutlineColor = Color3.fromRGB(255, 200, 50)
				hl.OutlineTransparency = 0.3
				hl.Parent = obj
				hl.Adornee = obj
				npcHighlights[obj] = hl
				count = count + 1
			end
		end
		info.Text = "NPC: " .. count
	end

	local function updateItems()
		itemHighlights = clearHighlights(itemHighlights)
		if not itemsOn then return end

		scanWorkspace()
		local count = 0
		for _, obj in ipairs(itemCache) do
			if obj.Parent then
				local hl = Instance.new("Highlight")
				hl.Name = "N1V1LON_Item"
				hl.FillColor = Color3.fromRGB(50, 150, 255)
				hl.FillTransparency = 0.4
				hl.OutlineColor = Color3.fromRGB(255, 255, 100)
				hl.OutlineTransparency = 0.2
				hl.Parent = obj
				hl.Adornee = obj
				itemHighlights[obj] = hl
				count = count + 1
			end
		end
		info.Text = (npcOn and "NPC: " .. countTable(npcHighlights) .. " | " or "") .. "Items: " .. count
	end

	npcBtn.MouseButton1Click:Connect(function()
		npcOn = not npcOn
		npcStatus.Text = npcOn and "ON" or "OFF"
		npcStatus.TextColor3 = npcOn and Color3.fromRGB(60, 200, 120) or Color3.fromRGB(140, 60, 60)
		if npcOn then
			updateNPC()
			if _G.N1V1LON.showMsg then _G.N1V1LON.showMsg("NPC highlight ON") end
		else
			npcHighlights = clearHighlights(npcHighlights)
			info.Text = itemsOn and info.Text:gsub("NPC: %d+ | ", "") or ""
			if _G.N1V1LON.showMsg then _G.N1V1LON.showMsg("NPC highlight OFF") end
		end
	end)

	itemBtn.MouseButton1Click:Connect(function()
		itemsOn = not itemsOn
		itemStatus.Text = itemsOn and "ON" or "OFF"
		itemStatus.TextColor3 = itemsOn and Color3.fromRGB(60, 200, 120) or Color3.fromRGB(140, 60, 60)
		if itemsOn then
			updateItems()
			if _G.N1V1LON.showMsg then _G.N1V1LON.showMsg("Items highlight ON") end
		else
			itemHighlights = clearHighlights(itemHighlights)
			info.Text = npcOn and "NPC: " .. countTable(npcHighlights) or ""
			if _G.N1V1LON.showMsg then _G.N1V1LON.showMsg("Items highlight OFF") end
		end
	end)

	-- Periodic update to catch new objects
	task.spawn(function()
		while frame and frame.Parent do
			task.wait(SCAN_COOLDOWN)
			if npcOn or itemsOn then
				scanWorkspace()
				if npcOn then updateNPC() end
				if itemsOn then updateItems() end
			end
		end
	end)

	table.insert(_G.N1V1LON.cleanup, function()
		clearHighlights(npcHighlights)
		clearHighlights(itemHighlights)
	end)
end
