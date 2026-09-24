// Graphite keybindings view: parse the lines from omarchy-menu-keybindings
// ("SUPER SHIFT + F    → File manager"), put each binding in a group,
// collapse numbered and arrow series into one row, and match searches
// against names and keys.

// Sections are the jump-to chips. Each has one or more groups; a group is a
// box of rows with a name. The first rule that matches a binding name wins.
var sections = [
  { chip: "Apps", groups: ["Apps", "Tools"] },
  { chip: "Web apps", groups: ["Web apps"] },
  { chip: "Menus", groups: ["Menus"] },
  { chip: "Design", groups: ["Design and capture"] },
  { chip: "Windows", groups: ["Focus windows", "Move and swap windows", "Resize windows", "Window groups", "Window layout"] },
  { chip: "Workspaces", groups: ["Switch workspace", "Move to workspace", "Monitors"] },
  { chip: "Clipboard", groups: ["Clipboard and text"] },
  { chip: "Notifications", groups: ["Notifications"] },
  { chip: "Media", groups: ["Sound and media", "Brightness and devices"] },
  { chip: "Shell", groups: ["Shell"] },
  { chip: "System", groups: ["System"] }
]

var rules = [
  ["Notifications", /notification/],
  ["Window groups", /group/],
  ["Move to workspace", /^move window (silently )?to workspace/],
  ["Switch workspace", /workspace (\d+|forward|backward)$|^(former|previous|next) workspace$/],
  ["Monitors", /monitor|laptop display|mirroring/],
  ["Window layout", /full screen|full width|floating|split|pop window|pseudo|gaps|transparency|square aspect|close (all )?window|zoom|workspace layout|scratchpad/],
  ["Focus windows", /^focus on .*window|reveal active window/],
  ["Move and swap windows", /^swap window|^move window$/],
  ["Resize windows", /^resize window|^expand window|^shrink window|window width/],
  ["Menus", /menu|^keybindings$|keybindings$|^projects$|^background switcher$/],
  ["Design and capture", /figma|^paper$|claude design|color picker|screenshot|screenrecording|ocr|^share$|webcam/],
  ["Web apps", /^claude$|whatsapp|google messages|signal|^x( post)?$|youtube|grok|google maps|google photos|web app/],
  ["Clipboard and text", /copy|paste|cut|clipboard|emojis|dictation/],
  ["Shell", /bar panel|top bar|weather|show time|reminder|battery|^audio$|^bluetooth$|^network$|^power$|^display$/],
  ["Sound and media", /volume|track|mute|pause|^play$|media source|audio output|microphone/],
  ["Brightness and devices", /brightness|backlight|touchpad|eject/],
  ["System", /lock|nightlight|monitor scaling/],
  ["Tools", /tmux|herdr|agent|t3 code|docker|activity|calculator|passwords|transcode/],
  ["Apps", /./]
]

// Series of bindings that differ only in one key collapse into one row
// while no search is active. [pattern for the name, name of the row]
var series = [
  [/^Switch to workspace \d+$/, "Switch to workspace"],
  [/^Move window to workspace \d+$/, "Move window to workspace"],
  [/^Move window silently to workspace \d+$/, "Move window silently to workspace"],
  [/^Switch to group window \d+$/, "Switch to group window"],
  [/^Bar panel \d+$/, "Bar panel"],
  [/^Focus on (left|right|above|below) window$/, "Focus window in direction"],
  [/^Swap window (to the left|to the right|up|down)$/, "Swap window in direction"],
  [/^Move window to group on (left|right|top|bottom)$/, "Move window to group in direction"],
  [/^Move workspace to (left|right|up|down) monitor$/, "Move workspace to monitor"]
]

var keyWords = {
  "SUPER": "super", "SHIFT": "⇧", "CTRL": "ctrl", "CONTROL": "ctrl", "ALT": "alt",
  "RETURN": "↵", "ENTER": "↵", "ESCAPE": "esc", "SPACE": "space", "TAB": "tab",
  "BACKSPACE": "⌫", "DELETE": "del", "LEFT": "←", "RIGHT": "→", "UP": "↑", "DOWN": "↓",
  "PRINT": "print", "HOME": "home", "END": "end", "COMMA": ",", "PERIOD": ".",
  "SLASH": "/", "MINUS": "-", "EQUAL": "=", "GRAVE": "`", "BACKSLASH": "\\",
  "BRACKETLEFT": "[", "BRACKETRIGHT": "]", "SEMICOLON": ";", "APOSTROPHE": "'"
}

// Short keycap text for the XF86 media and hardware keys.
var mediaKeys = {
  "AudioLowerVolume": "vol −", "AudioRaiseVolume": "vol +", "AudioMute": "mute",
  "AudioMicMute": "mic mute", "AudioPlay": "play", "AudioPause": "pause", "AudioNext": "next",
  "AudioPrev": "prev", "MonBrightnessDown": "bright −", "MonBrightnessUp": "bright +",
  "KbdBrightnessDown": "kbd −", "KbdBrightnessUp": "kbd +", "KbdLightOnOff": "kbd light",
  "TouchpadToggle": "touchpad", "TouchpadOn": "touchpad on", "TouchpadOff": "touchpad off",
  "Calculator": "calc", "Eject": "eject", "PowerOff": "power"
}

// Words a search can use for a key, in addition to its keycap text.
var keyAliases = {
  "⇧": ["shift"], "↵": ["return", "enter"], "esc": ["escape"], "⌫": ["backspace"],
  "del": ["delete"], "←": ["left", "arrows"], "→": ["right", "arrows"], "↑": ["up", "arrows"],
  "↓": ["down", "arrows"], ",": ["comma"], ".": ["period"], "/": ["slash"], "-": ["minus"],
  "=": ["equal"], "[": ["bracketleft"], "]": ["bracketright"]
}

function parts(label) {
  var at = label.lastIndexOf(" → ")
  if (at < 0) return { combo: "", keys: [], name: label.trim() }
  var combo = label.slice(0, at).trim()
  return { combo: combo, keys: keyNames(combo), name: label.slice(at + 3).trim() }
}

// "SUPER SHIFT + RETURN" -> ["super", "⇧", "↵"]
function keyNames(combo) {
  var halves = combo.split(" + ")
  var mods = halves.length > 1 ? halves[0].split(/\s+/) : []
  var key = halves.length > 1 ? halves.slice(1).join(" + ") : halves[0]
  var out = []
  for (var i = 0; i < mods.length; i++) if (mods[i]) out.push(keyWords[mods[i].toUpperCase()] || mods[i].toLowerCase())
  var k = key.trim()
  var upper = k.toUpperCase()
  if (keyWords[upper]) out.push(keyWords[upper])
  else if (/^XF86/i.test(k)) {
    var media = k.replace(/^XF86/i, "")
    out.push(mediaKeys[media] || media.replace(/([a-z])([A-Z])/g, "$1 $2").toLowerCase())
  }
  else if (/^mouse_(up|down)$/i.test(k)) out.push(k.toLowerCase() === "mouse_up" ? "scroll ↑" : "scroll ↓")
  else if (/ MOUSE BUTTON$/i.test(k)) out.push(k.replace(/ MOUSE BUTTON$/i, "").toLowerCase() + " click")
  else out.push(k.toLowerCase())
  return out
}

// Two bindings are named "Calendar": the web app and the bar calendar.
function group(name, combo) {
  var n = name.toLowerCase()
  if (n === "calendar") return /ALT/.test(combo || "") ? "Shell" : "Web apps"
  for (var i = 0; i < rules.length; i++) if (rules[i][1].test(n)) return rules[i][0]
  return "Apps"
}

function groupOrder() {
  var out = []
  for (var s = 0; s < sections.length; s++) out = out.concat(sections[s].groups)
  return out
}

function sectionOf(groupName) {
  for (var s = 0; s < sections.length; s++) if (sections[s].groups.indexOf(groupName) >= 0) return s
  return -1
}

// Series rows: the keys of the members, joined into one keycap for the
// key that changes ("1–0", "← → ↑ ↓").
function seriesName(name) {
  for (var i = 0; i < series.length; i++) if (series[i][0].test(name)) return series[i][1]
  return ""
}

// A series row gets a label in the same form ("SUPER + 1–0 → Switch to
// workspace") and `series: true`.
function collapse(rows) {
  var out = []
  var byKey = {}
  for (var i = 0; i < rows.length; i++) {
    var p = parts(rows[i].label)
    var name = seriesName(p.name)
    if (!name) { out.push(rows[i]); continue }
    var halves = p.combo.split(" + ")
    var mods = halves.length > 1 ? halves[0] : ""
    var id = name + "|" + mods
    if (!byKey[id]) {
      byKey[id] = { row: rows[i], name: name, mods: mods, last: [] }
      out.push(rows[i])
    }
    byKey[id].last.push(p.keys[p.keys.length - 1])
  }
  for (var k in byKey) {
    var entry = byKey[k]
    if (entry.last.length < 2) continue
    var copy = {}
    for (var f in entry.row) copy[f] = entry.row[f]
    copy.label = (entry.mods ? entry.mods + " + " : "") + seriesKeys(entry.last) + " → " + entry.name
    copy.series = true
    out[out.indexOf(entry.row)] = copy
  }
  return out
}

// The key 0 means 10 and comes first in the source list. Move each "... 10"
// row after the last row of its series.
function numberOrder(rows) {
  var out = rows.slice()
  for (var i = out.length - 1; i >= 0; i--) {
    var m = parts(out[i].label).name.match(/^(.*) 10$/)
    if (!m) continue
    var last = i
    for (var j = i + 1; j < out.length; j++) if (parts(out[j].label).name.indexOf(m[1] + " ") === 0) last = j
    if (last > i) out.splice(last, 0, out.splice(i, 1)[0])
  }
  return out
}

function seriesKeys(keys) {
  var digits = keys.filter(function(k) { return /^\d$/.test(k) })
  if (digits.length === keys.length) {
    digits.sort(function(a, b) { return (a === "0" ? 10 : +a) - (b === "0" ? 10 : +b) })
    return digits[0] + "–" + digits[digits.length - 1]
  }
  var arrows = ["←", "→", "↑", "↓"]
  return arrows.filter(function(a) { return keys.indexOf(a) >= 0 }).join(" ")
}

// Every search word must match: a one-letter word matches only a key; a
// longer word matches the start of a key name or any part of the name.
function matches(label, query) {
  var terms = String(query || "").toLowerCase().trim().split(/\s+/)
  if (!terms[0]) return true
  var p = parts(label)
  var name = p.name.toLowerCase()
  var tokens = []
  for (var i = 0; i < p.keys.length; i++) {
    tokens.push(p.keys[i])
    tokens = tokens.concat(keyAliases[p.keys[i]] || [])
  }
  var words = p.combo.toLowerCase().split(/[\s+]+/)
  for (var w = 0; w < words.length; w++) if (words[w]) tokens.push(words[w])
  for (var t = 0; t < terms.length; t++) {
    var term = terms[t]
    var hit = false
    for (var j = 0; j < tokens.length && !hit; j++) {
      hit = term.length === 1 ? tokens[j] === term : tokens[j].indexOf(term) === 0
    }
    if (!hit && term.length > 1) hit = name.indexOf(term) >= 0
    if (!hit) return false
  }
  return true
}

if (typeof module !== "undefined") module.exports = {
  sections: sections, parts: parts, keyNames: keyNames, group: group, groupOrder: groupOrder,
  sectionOf: sectionOf, collapse: collapse, numberOrder: numberOrder, matches: matches
}
