print("[DEBUG]: Main Loading -> Start")

local BASE = "https://raw.githubusercontent.com/N1V1LON/roblox_lua_script/main/"
local Player = game:GetService("Players").LocalPlayer

print("[DEBUG]: Player -> " .. Player.Name)

local N1V1LON = {
	Player = Player,
	Menu = nil,
	Container = nil,
	Icon = nil,
	CreateButton = nil,
}

getgenv().N1V1LON = N1V1LON

print("[DEBUG]: Loading gui.lua...")

local ok1, err1 = pcall(function()
	local guiCode = game:HttpGet(BASE .. "gui.lua", true)
	if guiCode then
		print("[DEBUG]: gui.lua fetched, executing...")
		loadstring(guiCode)()
		print("[DEBUG]: gui.lua executed")
	else
		error("gui.lua is nil")
	end
end)

if not ok1 then
	print("[DEBUG]: gui.lua ERROR -> " .. tostring(err1))
else
	print("[DEBUG]: gui.lua OK")
end

local Scripts = {
	"scripts/infjump.lua",
	"scripts/speed.lua",
}

print("[DEBUG]: Loading scripts...")

for _, name in ipairs(Scripts) do
	print("[DEBUG]: Loading " .. name .. "...")
	pcall(function()
		local code = game:HttpGet(BASE .. name, true)
		if code then
			loadstring(code)()
			print("[DEBUG]: " .. name .. " OK")
		else
			print("[DEBUG]: " .. name .. " is nil")
		end
	end)
end

print("[DEBUG]: Main Loading -> Done")
