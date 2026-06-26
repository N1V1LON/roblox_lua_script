print("[N1V1LON] Starting...")

local HttpGet = game.HttpGet

local Scripts = loadstring(
	HttpGet(game, "https://raw.githubusercontent.com/N1V1LON/roblox_lua_script/main/ScriptsList.lua")
)()

if not Scripts then
	print("[N1V1LON] Failed to load ScriptsList")
	return
end

print("[N1V1LON] Loading " .. #Scripts .. " script(s)")

for i, url in ipairs(Scripts) do
	local success, err = pcall(function()
		local content = HttpGet(game, url)
		local fn = loadstring(content)
		if fn then
			fn()
		else
			error("loadstring returned nil")
		end
	end)

	if success then
		print("[N1V1LON] Loaded: " .. url)
	else
		warn("[N1V1LON] Failed: " .. url .. " - " .. tostring(err))
	end
end

print("[N1V1LON] Done")
