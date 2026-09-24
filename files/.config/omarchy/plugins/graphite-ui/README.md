# graphite-ui

Graphite versions of Omarchy's shell parts (docs/theme-direction.md), shared by
the graphite.* panel clones. This folder has no manifest.json, so the plugin
scanner skips it.

Clones keep `import qs.Ui` and add `import "../graphite-ui" as G`, then use
`G.<Part>` where the Graphite look applies. The parts keep the properties and
signals of the Omarchy parts with the same names, so a clone only changes the
type name. Tokens come from the [graphite] section of shell.toml (made by
~/.config/omarchy/themed/shell.graphite.toml.tpl).

KeyboardPanel.qml is a copy of Omarchy's Ui/KeyboardPanel.qml with the card
changed: 16px radius, no border. Compare it with the Omarchy file after an
Omarchy update.
