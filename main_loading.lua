local HttpService = game:GetService("HttpService")

local SCRIPTS = {
	Main = "https://raw.githubusercontent.com/N1V1LON/roblox_lua_script/main/src/main.server.lua",
}

for name, url in pairs(SCRIPTS) do
	local success, result = pcall(function()
		local content = HttpService:GetAsync(url)
		local loadFunction, err = loadstring(content)
		if not loadFunction then
			warn(("Failed to load %s: %s"):format(name, err))
			return
		end
		loadFunction()
	end)

	if not success then
		warn(("Error loading script %s: %s"):format(name, result))
	end
end
