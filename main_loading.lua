--!strict

local HttpGet = game.HttpGet

local Scripts: {string} = loadstring(
	HttpGet(game, "https://raw.githubusercontent.com/N1V1LON/roblox_lua_script/main/ScriptsList.lua")
)() :: any

for _, url in ipairs(Scripts) do
	loadstring(HttpGet(game, url))()
end
