## 2025-05-14 - [Deprecation of Instance.Draggable]
**Learning:** The `Instance.Draggable` property is deprecated in Roblox and can lead to inconsistent behavior, especially on mobile/touch devices. Using `UserInputService` with custom dragging logic provides better control and cross-platform compatibility.
**Action:** Always implement custom dragging logic using `InputBegan`, `InputChanged`, and `InputEnded` events for UI elements that need to be repositionable. Ensure global service connections are only active during the drag operation to avoid memory leaks.
