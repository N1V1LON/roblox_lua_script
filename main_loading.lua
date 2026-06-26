--!strict

local HttpGet = game.HttpGet

local Scripts: {string} = loadstring(
	HttpGet(game, "https://raw.githubusercontent.com/N1V1LON/roblox_lua_script/main/ScriptsList.lua")
)() :: any

for _, url in Scripts do
	local success = pcall(function()
		loadstring(HttpGet(game, url))()
	end)

	if not success then
		warn("Failed to load: " .. url)
	end
end
