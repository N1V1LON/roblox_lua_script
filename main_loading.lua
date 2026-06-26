local SCRIPTS = {
	GUI = "https://raw.githubusercontent.com/N1V1LON/roblox_lua_script/main/src/gui.client.lua",
}

local loaded = 0
local total = 0

for name, url in pairs(SCRIPTS) do
	total = total + 1
end

for name, url in pairs(SCRIPTS) do
	local success = pcall(function()
		local content = game:HttpGet(url, true)
		local fn = loadstring(content)
		if fn then
			fn()
		end
	end)

	if success then
		loaded = loaded + 1
	end
end
