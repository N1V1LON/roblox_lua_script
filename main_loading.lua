local SCRIPTS = {
	Main = "https://raw.githubusercontent.com/N1V1LON/roblox_lua_script/main/src/main.server.lua",
}

for name, url in pairs(SCRIPTS) do
	local success = pcall(function()
		loadstring(game:HttpGet(url, true))()
	end)

	if not success then
		warn("Failed to load: " .. name)
	end
end
