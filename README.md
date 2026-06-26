# N1V1LON

Delta Executor:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/N1V1LON/roblox_lua_script/main/main_loading.lua", true))()
```

## Features

- **Draggable icon** (48x48) with N text
- **Speed** — click slider to set value (16–116), ON/OFF toggle, Heartbeat loop to prevent game resets
- **Infinite Jump** — uses JumpRequest + ChangeState, sits next to Speed
- **Checkpoints** — `+` saves position with a colored in-game marker, click to TP, hold 0.5s to delete
- **Auto Attack** — damages all nearby players (range 30) every frame

## Version

`v26.1.3.6 Beta`

## Notes

- Single file — nested loadstring doesn't work in Delta
- Re-running the script destroys old GUI and cleanups old connections
- Speed May Not Work In All Games
