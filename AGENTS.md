# N1V1LON — Roblox Lua script (exploit/game utility)

## Build channels

Репозиторий поддерживает два канала сборки:

- **Realse (релиз)** — `main_loading.lua` (single-file, все виджеты встроены inline).
- **Beta (тест)** — `test_loading.lua` (модульный загрузчик, подтягивает виджеты из `scripts_beta/` через `loadstring(game:HttpGet(...))`).

Разница между `scripts_realse/` и `scripts_beta/`: beta-виджеты содержат `warn("[N1V1LON DEBUG] ...")` в начале для отладки.

## Entrypoints

- Релиз: `loadstring(game:HttpGet("https://raw.githubusercontent.com/N1V1LON/roblox_lua_script/main/main_loading.lua", true))()`
- Бета: `loadstring(game:HttpGet("https://raw.githubusercontent.com/N1V1LON/roblox_lua_script/main/test_loading.lua", true))()`

`default.project.json` (Rojo) мапит `ServerScriptService.Main` → `main_loading.lua`.

## Структура директорий

- `main_loading.lua` — релизная сборка (single-file, все виджеты вшиты)
- `main_loading_backup.lua` — бэкап предыдущей релизной версии (v26.1.3.5)
- `test_loading.lua` — бета-загрузчик
- `scripts_realse/` — виджеты для релиза (возвращают функцию)
- `scripts_beta/` — виджеты для беты (с отладочными warn)
- `GuiBlockUser.lua` — админ-панель управления блокировками пользователей
- `users/players.lua` — база заблокированных пользователей (fetch с GitHub)
- `logsave/` — директория для сохранения логов на диск (через `writefile`)

## Паттерн виджетов

Каждый виджет в `scripts_*/*.lua` возвращает функцию:

```lua
return function(container, player, uis, rs)
  -- container = ScrollingFrame для вставки UI
  -- player = game:GetService("Players").LocalPlayer
  -- uis = UserInputService
  -- rs = RunService
end
```

## Система блокировок

При старте и каждые ~5 секунд скрипт fetch-ит `users/players.lua` с GitHub. Если `players[player.UserId].blocked == true`, GUI уничтожается.

## Логирование

Кнопка "^" собирает дамп (игра, игрок, инвентарь, nearby parts, лог рантайма) и пытается сохранить через `writefile` в порядке приоритета:
1. `logsave/N1V1LON_log.txt`
2. `N1V1LON_log_save.txt`
3. `log_save.txt`
4. `logsave/log_save.txt`

## Версионирование

Формат: `v<major>.<minor>.<patch>.<build> Realse` (пример: `v26.2.1.0 Realse`).

## Особенности разработки

- Тестов, линтеров, форматтеров, typechecker-ов нет.
- Сборка релиза — ручное копирование/инлайнинг кода виджетов в `main_loading.lua`.
- `main_loading_backup.lua` — предыдущая стабильная версия, не удалять.
- UI: Roblox native Instance (не Roact, не Fusion), кастомные цвета (темная тема: `Color3.fromRGB(20, 20, 30)` фон).
