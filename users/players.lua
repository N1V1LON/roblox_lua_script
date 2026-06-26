-- N1V1LON player database
-- Keys = player UserId (number, without quotes)
-- blocked = true  -> script will NOT run for this player (GUI not created)
-- If player not in table or fetch fails -> ALLOWED by default
--
-- Example:
--   [123456] = { name = "PlayerName", blocked = false },
--   [789012] = { name = "BlockedUser", blocked = true },
--
-- To block a player: add their UserId with blocked = true, commit, push.
-- Wait ~5 seconds — periodic check will kill their GUI.

return {
  -- format:
  -- [UserId] = { name = "Username", blocked = true/false },
}
