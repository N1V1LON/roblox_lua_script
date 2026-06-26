local SCRIPTS = {
	GUI = "https://raw.githubusercontent.com/N1V1LON/roblox_lua_script/main/src/gui.client.lua",
}

local loaded = {}

for name, url in pairs(SCRIPTS) do
	local success, result = pcall(function()
		local content = game:HttpGet(url, true)
		local fn, err = loadstring(content)
		if not fn then
			return nil, err
		end
		fn()
		return true
	end)

	if success and result == true then
		loaded[name] = true
		loaded[#loaded + 1] = name
	else
		warn("[N1V1LON] Failed to load: " .. name .. (result and " - " .. tostring(result) or ""))
	end
end

if #loaded > 0 then
	pcall(function()
		if game:GetService("CoreGui"):FindFirstChild("N1V1LON") then
			local hub = game:GetService("CoreGui").N1V1LON
			local status = hub:FindFirstChild("Status")
			if status and status:IsA("TextLabel") then
				status.Text = "Loaded: " .. table.concat(loaded, ", ")
			end
		end
	end)
end
