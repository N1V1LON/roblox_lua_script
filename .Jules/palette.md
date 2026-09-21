## 2025-05-14 - [Deprecation of Instance.Draggable]
**Learning:** The `Instance.Draggable` property is deprecated in Roblox and can lead to inconsistent behavior, especially on mobile/touch devices. Using `UserInputService` with custom dragging logic provides better control and cross-platform compatibility.
**Action:** Always implement custom dragging logic using `InputBegan`, `InputChanged`, and `InputEnded` events for UI elements that need to be repositionable. Ensure global service connections are only active during the drag operation to avoid memory leaks.

## 2025-05-15 - [Touch Slider Usability and Mobile Interaction]
**Learning:** Single-click slider event handlers (`MouseButton1Click`) fail when users attempt to drag slider knobs on mobile touch screens or high DPI displays. Implementing `InputBegan` listeners connected dynamically to `UserInputService.InputChanged` ensures seamless continuous touch and mouse dragging.
**Action:** Always implement drag listeners using `InputBegan` and disconnect `InputChanged` and `Changed` connections when `UserInputState.End` is triggered to maintain high accessibility on mobile devices without introducing memory leaks.
