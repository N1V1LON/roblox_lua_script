return function(container, player, uis, rs)
	local espOn = false
	local espData = {}
	local espConn = nil

	local drawingOk = pcall(function() return Drawing.new("Square") end)

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 32)
	btn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
	btn.BorderSizePixel = 0
	btn.Text = "  ESP"
	btn.TextColor3 = Color3.fromRGB(200, 200, 220)
	btn.TextSize = 13
	btn.TextXAlignment = Enum.TextXAlignment.Left
	btn.Font = Enum.Font.Gotham
	btn.Parent = container
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

	local espStatus = Instance.new("TextLabel")
	espStatus.Size = UDim2.new(0, 50, 1, 0)
	espStatus.Position = UDim2.new(1, -55, 0, 0)
	espStatus.BackgroundTransparency = 1
	espStatus.Text = "OFF"
	espStatus.TextColor3 = Color3.fromRGB(140, 60, 60)
	espStatus.TextSize = 12
	espStatus.Font = Enum.Font.GothamBold
	espStatus.Parent = btn

	local function clearESP()
		for _, d in pairs(espData) do
			if d.box then pcall(function() d.box:Remove() end) end
			if d.line then pcall(function() d.line:Remove() end) end
			if d.name then pcall(function() d.name:Remove() end) end
			if d.hp then pcall(function() d.hp:Remove() end) end
			if d.dist then pcall(function() d.dist:Remove() end) end
		end
		espData = {}
	end

	local function ensureDrawing(p)
		if espData[p] then return end
		if not drawingOk then return end
		espData[p] = {
			box = Drawing.new("Square"),
			line = Drawing.new("Line"),
			name = Drawing.new("Text"),
			hp = Drawing.new("Text"),
			dist = Drawing.new("Text"),
		}
		local d = espData[p]
		d.box.Visible = false; d.box.Thickness = 1; d.box.Color = Color3.fromRGB(255, 100, 100)
		d.line.Visible = false; d.line.Thickness = 1; d.line.Color = Color3.fromRGB(255, 100, 100)
		d.name.Visible = false; d.name.Size = 13; d.name.Center = true; d.name.Outline = true; d.name.Color = Color3.fromRGB(255, 255, 255)
		d.hp.Visible = false; d.hp.Size = 11; d.hp.Center = true; d.hp.Outline = true; d.hp.Color = Color3.fromRGB(100, 255, 100)
		d.dist.Visible = false; d.dist.Size = 10; d.dist.Center = true; d.dist.Outline = true; d.dist.Color = Color3.fromRGB(200, 200, 200)
	end

	local function updateESP()
		if not drawingOk then return end
		local cam = workspace.CurrentCamera
		local myChar = player.Character
		local myRoot = myChar and (myChar:FindFirstChild("HumanoidRootPart") or myChar:FindFirstChild("Torso"))
		local vSize = cam.ViewportSize

		for p, d in pairs(espData) do
			if not p.Parent then
				for _, dd in pairs(d) do if dd then pcall(function() dd:Remove() end) end end
				espData[p] = nil
			end
		end

		for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
			if p == player then continue end
			local c = p.Character
			if not c then
				if espData[p] then
					for _, dd in pairs(espData[p]) do if dd then pcall(function() dd:Remove() end) end end
					espData[p] = nil
				end
				continue
			end

			local root = c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso")
			local hum = c:FindFirstChildOfClass("Humanoid")
			if not root or not hum then continue end

			local head = c:FindFirstChild("Head")
			local sp, vis = cam:WorldToViewportPoint(root.Position)
			if not vis then
				if espData[p] then for _, dd in pairs(espData[p]) do if dd then dd.Visible = false end end end
				continue
			end

			ensureDrawing(p)
			local d = espData[p]
			local screenPos = Vector2.new(sp.X, sp.Y)
			local headPos = head and cam:WorldToViewportPoint(head.Position) or sp
			local headScreen = Vector2.new(headPos.X, headPos.Y)
			local footSp = cam:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))

			local boxHeight = math.abs(headScreen.Y - footSp.Y)
			local boxWidth = boxHeight * 0.6
			local boxPos = Vector2.new(screenPos.X - boxWidth / 2, headScreen.Y)

			d.box.Visible = true
			d.box.Position = boxPos
			d.box.Size = Vector2.new(boxWidth, boxHeight)
			d.box.Color = hum.Health > 20 and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(255, 255, 100)

			d.line.Visible = true
			d.line.From = Vector2.new(vSize.X / 2, vSize.Y)
			d.line.To = Vector2.new(screenPos.X, screenPos.Y + boxHeight / 2)

			d.name.Visible = true
			d.name.Position = Vector2.new(screenPos.X, headScreen.Y - 16)
			d.name.Text = p.Name

			d.hp.Visible = true
			d.hp.Position = Vector2.new(screenPos.X, headScreen.Y - 2)
			d.hp.Text = tostring(math.floor(hum.Health))
			d.hp.Color = hum.Health > 50 and Color3.fromRGB(100, 255, 100) or hum.Health > 20 and Color3.fromRGB(255, 255, 100) or Color3.fromRGB(255, 100, 100)

			if myRoot then
				local dist = (root.Position - myRoot.Position).Magnitude
				d.dist.Visible = true
				d.dist.Position = Vector2.new(screenPos.X, footSp.Y + 2)
				d.dist.Text = tostring(math.floor(dist)) .. " studs"
			end
		end
	end

	btn.MouseButton1Click:Connect(function()
		espOn = not espOn
		if espOn then
			espStatus.Text = "ON"
			espStatus.TextColor3 = Color3.fromRGB(60, 200, 120)
			if espConn then espConn:Disconnect() end
			espConn = rs.RenderStepped:Connect(updateESP)
		else
			espStatus.Text = "OFF"
			espStatus.TextColor3 = Color3.fromRGB(140, 60, 60)
			if espConn then espConn:Disconnect(); espConn = nil end
			clearESP()
		end
	end)
end
