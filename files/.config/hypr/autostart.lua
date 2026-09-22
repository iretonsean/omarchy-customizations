-- Extra autostart processes.
-- o.launch_on_start("my-service")

-- Dock at the bottom. The command is in ~/.local/bin/dock-start.
o.launch_on_start(os.getenv("HOME") .. "/.local/bin/dock-start")
