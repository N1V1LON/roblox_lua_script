return function(container, player, uis, rs)
	warn("[N1V1LON DEBUG] Highlights widget loaded")
	local npcOn = false
	local itemsOn = false
	local npcHighlights = {}
	local itemHighlights = {}

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

	-- NPC toggle
	local npcBtnGroup = Instance.new("Frame")
	npcBtnGroup.Size = UDim2.new(0.5, -6, 0, 18)
	npcBtnGroup.Position = UDim2.new(0, 8, 0, 26)
	npcBtnGroup.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
	npcBtnGroup.BorderSizePixel = 0
	npcBtnGroup.Parent = frame
	Instance.new("UICorner", npcBtnGroup).CornerRadius = UDim.new(0, 4)

	local npcLabel = Instance.new("TextLabel")
	npcLabel.Size = UDim2.new(0.7, -4, 1, 0)
	npcLabel.Position = UDim2.new(0, 6, 0, 0)
	npcLabel.BackgroundTransparency = 1
	npcLabel.Text = "NPC"
	npcLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
	npcLabel.TextSize = 12
	npcLabel.TextXAlignment = Enum.TextXAlignment.Left
	npcLabel.Font = Enum.Font.Gotham
	npcLabel.Parent = npcBtnGroup

	local npcStatus = Instance.new("TextLabel")
	npcStatus.Size = UDim2.new(0.3, -2, 1, 0)
	npcStatus.Position = UDim2.new(0.7, 2, 0, 0)
	npcStatus.BackgroundTransparency = 1
	npcStatus.Text = "OFF"
	npcStatus.TextColor3 = Color3.fromRGB(140, 60, 60)
	npcStatus.TextSize = 11
	npcStatus.TextXAlignment = Enum.TextXAlignment.Center
	npcStatus.Font = Enum.Font.GothamBold
	npcStatus.Parent = npcBtnGroup

	-- Items toggle
	local itemBtnGroup = Instance.new("Frame")
	itemBtnGroup.Size = UDim2.new(0.5, -6, 0, 18)
	itemBtnGroup.Position = UDim2.new(0.5, 2, 0, 26)
	itemBtnGroup.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
	itemBtnGroup.BorderSizePixel = 0
	itemBtnGroup.Parent = frame
	Instance.new("UICorner", itemBtnGroup).CornerRadius = UDim.new(0, 4)

	local itemLabel = Instance.new("TextLabel")
	itemLabel.Size = UDim2.new(0.7, -4, 1, 0)
	itemLabel.Position = UDim2.new(0, 6, 0, 0)
	itemLabel.BackgroundTransparency = 1
	itemLabel.Text = "Items"
	itemLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
	itemLabel.TextSize = 12
	itemLabel.TextXAlignment = Enum.TextXAlignment.Left
	itemLabel.Font = Enum.Font.Gotham
	itemLabel.Parent = itemBtnGroup

	local itemStatus = Instance.new("TextLabel")
	itemStatus.Size = UDim2.new(0.3, -2, 1, 0)
	itemStatus.Position = UDim2.new(0.7, 2, 0, 0)
	itemStatus.BackgroundTransparency = 1
	itemStatus.Text = "OFF"
	itemStatus.TextColor3 = Color3.fromRGB(140, 60, 60)
	itemStatus.TextSize = 11
	itemStatus.TextXAlignment = Enum.TextXAlignment.Center
	itemStatus.Font = Enum.Font.GothamBold
	itemStatus.Parent = itemBtnGroup

	-- Info label
	local info = Instance.new("TextLabel")
	info.Size = UDim2.new(1, -16, 0, 14)
	info.Position = UDim2.new(0, 8, 0, 48)
	info.BackgroundTransparency = 1
	info.Text = ""
	info.TextColor3 = Color3.fromRGB(120, 120, 160)
	info.TextSize = 10
	info.TextXAlignment = Enum.TextXAlignment.Left
	info.Font = Enum.Font.Gotham
	info.Parent = frame

	local function toggleNPC()
		if npcOn then
			for _, hl in ipairs(npcHighlights) do
				pcall(function() hl:Destroy() end)
			end
			npcHighlights = {}
			npcOn = false
			npcStatus.Text = "OFF"
			npcStatus.TextColor3 = Color3.fromRGB(140, 60, 60)
			info.Text = ""
			if _G.N1V1LON.showMsg then _G.N1V1LON.showMsg("NPC highlight OFF") end
		else
			local playerModels = {}
			for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
				if p.Character then playerModels[p.Character] = true end
			end
			local count = 0
			for _, obj in ipairs(workspace:GetDescendants()) do
				if obj:IsA("Humanoid") and obj.Health > 0 then
					local parent = obj.Parent
					if parent == player.Character then continue end
					if playerModels[parent] then continue end
					local hl = Instance.new("Highlight")
					hl.Name = "N1V1LON_NPC"
					hl.FillColor = Color3.fromRGB(255, 50, 50)
					hl.FillTransparency = 0.5
					hl.OutlineColor = Color3.fromRGB(255, 200, 50)
					hl.OutlineTransparency = 0.3
					hl.Parent = parent
					hl.Adornee = parent
					table.insert(npcHighlights, hl)
					count = count + 1
				end
			end
			npcOn = true
			npcStatus.Text = "ON"
			npcStatus.TextColor3 = Color3.fromRGB(60, 200, 120)
			info.Text = "NPC: " .. count
			if _G.N1V1LON.showMsg then _G.N1V1LON.showMsg("NPC highlight ON — " .. count .. " найдено") end
		end
	end

	local keywords = {
		"ore", "iron", "gold", "diamond", "ruby", "emerald", "coal",
		"crystal", "gem", "mineral", "node", "vein", "amethyst",
		"sapphire", "topaz", "platinum", "silver", "copper",
		"mithril", "adamant", "runite",
	}

	local function isCollectible(name)
		local lower = name:lower()
		if lower == "rock" or lower == "stone" or lower == "dirt" then return false end
		for _, kw in ipairs(keywords) do
			if lower:find(kw, 1, true) then
				return true
			end
		end
		return false
	end

	local function toggleItems()
		if itemsOn then
			for _, hl in ipairs(itemHighlights) do
				pcall(function() hl:Destroy() end)
			end
			itemHighlights = {}
			itemsOn = false
			itemStatus.Text = "OFF"
			itemStatus.TextColor3 = Color3.fromRGB(140, 60, 60)
			info.Text = ""
			if _G.N1V1LON.showMsg then _G.N1V1LON.showMsg("Items highlight OFF") end
		else
			local count = 0
			local samples = {}
			for _, obj in ipairs(workspace:GetDescendants()) do
				if not obj:IsA("BasePart") or obj:IsA("Terrain") then continue end
				if obj.Size.X > 15 or obj.Size.Y > 15 or obj.Size.Z > 15 then continue end
				if not isCollectible(obj.Name) then continue end
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
				if #samples < 5 then table.insert(samples, obj.Name) end
			end
			itemsOn = true
			itemStatus.Text = "ON"
			itemStatus.TextColor3 = Color3.fromRGB(60, 200, 120)
			if #samples > 0 then
				info.Text = "Items: " .. count .. " (" .. table.concat(samples, ", ") .. ")"
				if _G.N1V1LON.showMsg then _G.N1V1LON.showMsg("Items ON — " .. count .. " (" .. table.concat(samples, ", ") .. ")") end
			else
				info.Text = "Items: " .. count
				if _G.N1V1LON.showMsg then _G.N1V1LON.showMsg("Items ON — " .. count) end
			end
		end
	end

	npcBtnGroup.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			toggleNPC()
		end
	end)

	itemBtnGroup.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			toggleItems()
		end
	end)
end
