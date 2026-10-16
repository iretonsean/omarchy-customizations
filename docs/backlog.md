# Backlog

Ideas that are not built yet. Each idea has a goal, the expected behavior, and notes for the first step.

## Ideas

### One pointer and keyboard for two or more computers

**Goal:** Use the desktops of two or more Omarchy computers on the same desk as one workspace, with one mouse and one keyboard.

**Expected behavior:**

- When you move the pointer past the edge of one screen, it goes onto the screen of the other computer.
- The keyboard types into the computer that has the pointer.
- Keybindings go to the computer that has the pointer, so each Hyprland session gets its own shortcuts.
- Text that you copy on one computer pastes on the other.
- You set the position of each computer (left, right, above, below) one time. The computers find each other on the local network.
- A key combination always returns the pointer and keyboard to the local computer, even if the other computer stops responding.

**Notes for the first step:**

- Test [lan-mouse](https://github.com/feschber/lan-mouse) first. It is written for Wayland and supports Hyprland: it captures input at the screen edge and sends it to the other computer as a virtual pointer and keyboard.
- Compare it with [Deskflow](https://github.com/deskflow/deskflow) and [Input Leap](https://github.com/input-leap/input-leap). On Wayland, these tools need the InputCapture portal. Hyprland may not supply that portal.
- Check how each tool encrypts the connection. Without encryption, every key you type goes over the network as plain text.
- Clipboard sharing may need a separate tool if the input tool does not do it.
- If it works, add a package and config to `install.sh`, a Learn menu row, and a section in the workspace guide.
