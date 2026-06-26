local BASE = "https://raw.githubusercontent.com/N1V1LON/roblox_lua_script/main/"

local HttpGet = game:HttpGet
local Player = game:GetService("Players").LocalPlayer

local N1V1LON = {
	Player = Player,
	Menu = nil,
	Container = nil,
	Icon = nil,
	CreateButton = nil,
}

getgenv().N1V1LON = N1V1LON

local guiCode = HttpGet(BASE .. "gui.lua", true)
if guiCode then
	loadstring(guiCode)()
end

local Scripts = {
	"scripts/infjump.lua",
	"scripts/speed.lua",
}

for _, name in ipairs(Scripts) do
	pcall(function()
		local code = HttpGet(BASE .. name, true)
		if code then
			loadstring(code)()
		end
	end)
end
