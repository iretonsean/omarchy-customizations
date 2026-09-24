# Graphite component tokens for shell plugins (docs/theme-direction.md).
# omarchy-theme-set merges this file into shell.toml as the [graphite]
# section. Plugins read Color.shellValues["graphite.<token>"].
[graphite]
accent = "{{ accent }}"
surface-0 = "{{ shell_gradient surface_0 darker_background }}"
surface-1 = "{{ shell_gradient surface_1 background }}"
surface-2 = "{{ shell_gradient surface_2 lighter_background }}"
surface-3 = "{{ shell_gradient surface_3 muted }}"
lift = "{{ shell_gradient lift muted }}"
text-1 = "{{ shell_gradient text_1 bright_foreground }}"
text-2 = "{{ shell_gradient text_2 foreground }}"
text-3 = "{{ shell_gradient text_3 light_foreground }}"
text-4 = "{{ shell_gradient text_4 dark_foreground }}"
accent-soft = "{{ shell_gradient accent_soft bright_blue }}"
on-accent = "{{ shell_gradient on_accent darker_background }}"
label-tint = "{{ shell_gradient label_tint light_foreground }}"
ok = "{{ shell_gradient ok green }}"
warn = "{{ shell_gradient warn yellow }}"
error = "{{ shell_gradient error red }}"
keycap-edge = "{{ shell_gradient keycap_edge rgba(255,255,255,0.14) }}"
highlight = "{{ shell_gradient highlight rgba(255,255,255,0.06) }}"
