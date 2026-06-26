return function(container, player, uis, rs)
	warn("[N1V1LON DEBUG] Checkpoints widget loaded")
	local checkpoints = {}

	local cpFrame = Instance.new("Frame")
	cpFrame.Size = UDim2.new(1, 0, 0, 120)
	cpFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
	cpFrame.BorderSizePixel = 0
	cpFrame.Parent = container
	Instance.new("UICorner", cpFrame).CornerRadius = UDim.new(0, 6)

	local cpHeader = Instance.new("Frame")
	cpHeader.Size = UDim2.new(1, 0, 0, 20)
	cpHeader.BackgroundTransparency = 1
	cpHeader.Parent = cpFrame

	local cpLabel = Instance.new("TextLabel")
	cpLabel.Size = UDim2.new(0, 140, 1, 0)
	cpLabel.Position = UDim2.new(0, 8, 0, 0)
	cpLabel.BackgroundTransparency = 1
	cpLabel.Text = "  Checkpoints"
	cpLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
	cpLabel.TextSize = 13
	cpLabel.TextXAlignment = Enum.TextXAlignment.Left
	cpLabel.Font = Enum.Font.Gotham
	cpLabel.Parent = cpHeader

	local cpAddBtn = Instance.new("TextButton")
	cpAddBtn.Size = UDim2.new(0, 20, 0, 20)
	cpAddBtn.Position = UDim2.new(1, -26, 0, 0)
	cpAddBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
	cpAddBtn.BorderSizePixel = 0
	cpAddBtn.Text = "+"
	cpAddBtn.TextColor3 = Color3.fromRGB(160, 200, 160)
	cpAddBtn.TextSize = 14
	cpAddBtn.Font = Enum.Font.GothamBold
	cpAddBtn.Parent = cpHeader
	Instance.new("UICorner", cpAddBtn).CornerRadius = UDim.new(0, 3)

	local cpList = Instance.new("ScrollingFrame")
	cpList.Size = UDim2.new(1, -8, 1, -24)
	cpList.Position = UDim2.new(0, 4, 0, 22)
	cpList.BackgroundTransparency = 1
	cpList.BorderSizePixel = 0
	cpList.ScrollBarThickness = 3
	cpList.CanvasSize = UDim2.new(0, 0, 0, 0)
	cpList.Parent = cpFrame
	local cpLayout = Instance.new("UIListLayout")
	cpLayout.FillDirection = Enum.FillDirection.Vertical
	cpLayout.Padding = UDim.new(0, 2)
	cpLayout.Parent = cpList

	local function addCP()
		local char = player.Character
		if not char then
			warn("[N1V1LON DEBUG] CP: no character")
			return
		end
		local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
		if not root then
			warn("[N1V1LON DEBUG] CP: no root part")
			return
		end
		local pos = root.Position
		local id = #checkpoints + 1
		warn("[N1V1LON DEBUG] CP saved #" .. id .. " at " .. tostring(pos))

		local row = Instance.new("TextButton")
		row.Size = UDim2.new(1, -6, 0, 22)
		row.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
		row.BorderSizePixel = 0
		row.Text = "  CP" .. tostring(id) .. "  (" .. math.floor(pos.X) .. ", " .. math.floor(pos.Y) .. ", " .. math.floor(pos.Z) .. ")"
		row.TextColor3 = Color3.fromRGB(200, 200, 220)
		row.TextSize = 11
		row.Font = Enum.Font.Gotham
		row.TextXAlignment = Enum.TextXAlignment.Left
		row.Parent = cpList
		Instance.new("UICorner", row).CornerRadius = UDim.new(0, 3)

		local entry = { pos = pos, row = row }
		checkpoints[id] = entry

		local held = false
		local holdTask = nil

		row.MouseButton1Down:Connect(function()
			held = false
			holdTask = task.delay(0.5, function()
				held = true
				warn("[N1V1LON DEBUG] CP #" .. id .. " hold detected, deleting...")
				row.BackgroundColor3 = Color3.fromRGB(80, 40, 40)
				task.delay(0.6, function()
					row:Destroy()
					for i, e in ipairs(checkpoints) do
						if e == entry then table.remove(checkpoints, i); break end
					end
				end)
			end)
		end)

		row.MouseButton1Up:Connect(function()
			if holdTask then task.cancel(holdTask); holdTask = nil end
			if not held then
				warn("[N1V1LON DEBUG] TP to CP #" .. id)
				local c = player.Character
				if c then
					local r = c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso")
					if r then r.Position = entry.pos end
				end
			end
		end)
	end

	cpAddBtn.MouseButton1Click:Connect(function()
		warn("[N1V1LON DEBUG] CP + clicked")
		addCP()
	end)
end
