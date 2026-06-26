local BASE = "https://raw.githubusercontent.com/N1V1LON/roblox_lua_script/main/"
local Player = game:GetService("Players").LocalPlayer

local N1V1LON = {
	Player = Player,
	Menu = nil,
	Container = nil,
	Icon = nil,
	CreateButton = nil,
}

getgenv().N1V1LON = N1V1LON

local ok1, err1 = pcall(function()
	local guiCode = game:HttpGet(BASE .. "gui.lua", true)
	if guiCode then
		loadstring(guiCode)()
	end
end)

if not ok1 then
	warn("[N1V1LON] gui.lua error: " .. tostring(err1))
end

local Scripts = {
	"scripts/infjump.lua",
	"scripts/speed.lua",
}

for _, name in ipairs(Scripts) do
	pcall(function()
		local code = game:HttpGet(BASE .. name, true)
		if code then
			loadstring(code)()
		end
	end)
end
