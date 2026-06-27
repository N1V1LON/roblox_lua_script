return function(container, player, uis, rs)
	local aimOn = false
	local trigOn = false
	local fovRadius = 150
	local fovCircle = nil
	local aimConn = nil
	local trigConn = nil

	local drawingOk = pcall(function() return Drawing.new("Circle") end)

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 32)
	btn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
	btn.BorderSizePixel = 0
	btn.Text = "  Aimbot + FOV"
	btn.TextColor3 = Color3.fromRGB(200, 200, 220)
	btn.TextSize = 13
	btn.TextXAlignment = Enum.TextXAlignment.Left
	btn.Font = Enum.Font.Gotham
	btn.Parent = container
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

	local aimStatus = Instance.new("TextLabel")
	aimStatus.Size = UDim2.new(0, 50, 1, 0)
	aimStatus.Position = UDim2.new(1, -55, 0, 0)
	aimStatus.BackgroundTransparency = 1
	aimStatus.Text = "OFF"
	aimStatus.TextColor3 = Color3.fromRGB(140, 60, 60)
	aimStatus.TextSize = 12
	aimStatus.Font = Enum.Font.GothamBold
	aimStatus.Parent = btn

	local function getClosestTarget(fovPixels)
		local mouse = player:GetMouse()
		local mPos = Vector2.new(mouse.X, mouse.Y)
		local best = nil
		local bestDist = fovPixels or 9999
		local cam = workspace.CurrentCamera

		for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
			if p == player then continue end
			local c = p.Character
			if not c then continue end
			local root = c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso")
			local hum = c:FindFirstChildOfClass("Humanoid")
			if not root or not hum or hum.Health <= 0 then continue end
			local sp, vis = cam:WorldToViewportPoint(root.Position)
			if vis then
				local dist = (Vector2.new(sp.X, sp.Y) - mPos).Magnitude
				if dist < bestDist then
					bestDist = dist
					best = {char = c, root = root, hum = hum}
				end
			end
		end
		return best
	end

	local function createFOV()
		if not drawingOk then return end
		if fovCircle then pcall(function() fovCircle:Remove() end) end
		fovCircle = Drawing.new("Circle")
		fovCircle.Visible = false
		fovCircle.Radius = fovRadius
		fovCircle.Thickness = 1
		fovCircle.NumSides = 64
		fovCircle.Color = Color3.fromRGB(255, 255, 255)
		fovCircle.Transparency = 0.7
		fovCircle.Position = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y / 2)
	end

	local function updateFOV()
		if not fovCircle then return end
		local cam = workspace.CurrentCamera
		fovCircle.Position = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
		fovCircle.Radius = fovRadius
	end

	local function aimAtTarget(target)
		if not target then return end
		local mouse = player:GetMouse()
		local head = target.char:FindFirstChild("Head")
		if head then
			pcall(function() mouse.TargetFilter = target.char end)
			pcall(function() mouse.Hit = head.CFrame end)
			pcall(function() mouse.Target = head end)
		else
			pcall(function() mouse.Hit = target.root.CFrame + Vector3.new(0, 2, 0) end)
		end
	end

	local function enableAimbot()
		if aimConn then aimConn:Disconnect() end
		aimConn = rs.RenderStepped:Connect(function()
			if not aimOn then return end
			local target = getClosestTarget(fovRadius)
			if target then
				aimAtTarget(target)
			end
			if fovCircle then
				fovCircle.Visible = aimOn
				updateFOV()
			end
		end)
	end

	btn.MouseButton1Click:Connect(function()
		aimOn = not aimOn
		if aimOn then
			aimStatus.Text = "ON"
			aimStatus.TextColor3 = Color3.fromRGB(60, 200, 120)
			createFOV()
			enableAimbot()
		else
			aimStatus.Text = "OFF"
			aimStatus.TextColor3 = Color3.fromRGB(140, 60, 60)
			if aimConn then aimConn:Disconnect(); aimConn = nil end
			if fovCircle then pcall(function() fovCircle:Remove() end); fovCircle = nil end
		end
	end)
end
