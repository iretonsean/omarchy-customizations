import QtQuick
import QtQuick.Effects
import Qt.labs.folderlistmodel
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.Commons

// Graphite dock (docs/theme-direction.md).
//
// A panel at the bottom edge that shows when the pointer reaches the edge.
// Pins come from ~/.cache/nwg-dock-pinned, which projects-apply builds from
// ~/.config/nwg-dock-hyprland/pinned. Two special pins: "spacer" is a gap and
// "trash" is the trash. Running apps that are not pinned come after the pins.
// Right-click an item to add or remove a gap, pin or unpin. The dock-pins
// script makes those changes.
Item {
  id: root

  property var shell
  property var manifest
  property string omarchyPath

  readonly property string home: Quickshell.env("HOME")
  readonly property string pinsCache: home + "/.cache/nwg-dock-pinned"
  readonly property string pinsBase: home + "/.config/nwg-dock-hyprland/pinned"
  readonly property string launcherCommand: "omarchy-menu toggle apps"

  // ------------------------------------------------------------ tokens

  function parseColor(raw, fallback) {
    var s = String(raw || "").trim()
    var rgba = s.match(/^rgba?\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*(?:,\s*([\d.]+))?\s*\)$/)
    if (rgba) return Qt.rgba(rgba[1] / 255, rgba[2] / 255, rgba[3] / 255, rgba[4] === undefined ? 1 : Number(rgba[4]))
    var hex = s.match(/^#([0-9a-fA-F]{6})([0-9a-fA-F]{2})?$/)
    if (hex) {
      var h = hex[1]
      return Qt.rgba(parseInt(h.substr(0, 2), 16) / 255, parseInt(h.substr(2, 2), 16) / 255,
                     parseInt(h.substr(4, 2), 16) / 255, hex[2] ? parseInt(hex[2], 16) / 255 : 1)
    }
    return fallback
  }

  function token(name, fallback) {
    return parseColor(Color.shellValues["graphite." + name], fallback)
  }

  readonly property color surface1: token("surface-1", "#18181a")
  readonly property color lift: token("lift", "#303033")
  readonly property color text1: token("text-1", "#f5f5f7")
  readonly property color text2: token("text-2", "#e5e5e7")
  readonly property color text3: token("text-3", "#98989d")
  readonly property color accent: token("accent", "#0a84ff")
  readonly property color errorColor: token("error", "#ff8078")
  readonly property color highlight: token("highlight", Qt.rgba(1, 1, 1, 0.06))

  readonly property string labelFont: "SF Pro Text"

  readonly property int iconSize: 40
  readonly property int tileSize: 48
  readonly property int tileGap: 2
  readonly property int spacerWidth: 16
  readonly property int panelPadding: 6
  readonly property int panelRadius: 16
  readonly property int tileRadius: 8
  readonly property int edgeGap: 6
  readonly property int shadowRoom: 56
  readonly property int popupRoom: 170

  // ------------------------------------------------------------ pins

  property var pins: []

  function parsePins(text) {
    var lines = String(text || "").split("\n")
    var next = []
    for (var i = 0; i < lines.length; i++) {
      var line = lines[i].trim()
      if (line.length > 0) next.push(line)
    }
    pins = next
  }

  FileView {
    path: root.pinsCache
    watchChanges: true
    printErrors: false
    onFileChanged: reload()
    onLoaded: root.parsePins(text())
    onLoadFailed: baseFile.reload()
  }

  FileView {
    id: baseFile
    path: root.pinsBase
    printErrors: false
    onLoaded: if (root.pins.length === 0) root.parsePins(text())
  }

  // ------------------------------------------------------------ windows

  function appIdOf(toplevel) {
    if (toplevel.wayland && toplevel.wayland.appId) return toplevel.wayland.appId
    var ipc = toplevel.lastIpcObject || {}
    return String(ipc["class"] || "")
  }

  function visibleWindows(all) {
    var out = []
    for (var i = 0; i < all.length; i++) {
      var t = all[i]
      if (t.workspace && String(t.workspace.name).indexOf("special") === 0) continue
      if (!t.wayland) continue
      out.push(t)
    }
    return out
  }

  // Some pinned ids are hidden helper entries without an icon (for example a
  // link handler). Then use the app whose window class matches the id.
  function entryFor(id) {
    var entry = DesktopEntries.byId(id)
    if (entry && entry.icon) return entry
    var apps = DesktopEntries.applications.values
    var lower = id.toLowerCase()
    var last = lower.split(".").pop()
    for (var i = 0; i < apps.length; i++) {
      var a = apps[i]
      if (!a.icon) continue
      var cls = (a.startupClass || "").toLowerCase()
      if (cls === lower || cls === last || a.id.toLowerCase() === last) return a
    }
    var guess = DesktopEntries.heuristicLookup(id)
    return (guess && guess.icon) ? guess : (entry || guess)
  }

  function matches(entry, id, appId) {
    var a = appId.toLowerCase()
    if (a === id.toLowerCase()) return true
    if (entry && entry.startupClass && entry.startupClass.toLowerCase() === a) return true
    return false
  }

  // One list of what the dock shows. Arguments are listed so the binding
  // updates when the pins, the windows or the installed apps change.
  function buildItems(pinList, windowList, apps) {
    var windows = visibleWindows(windowList)
    var used = []
    var items = []
    var spacerCount = 0

    for (var i = 0; i < pinList.length; i++) {
      var id = pinList[i]
      if (id === "spacer") {
        spacerCount += 1
        items.push({ kind: "spacer", id: "spacer", spacerIndex: spacerCount })
        continue
      }
      if (id === "trash") {
        items.push({ kind: "trash", id: "trash", name: "Trash", windows: [] })
        continue
      }
      var entry = entryFor(id)
      var mine = []
      for (var w = 0; w < windows.length; w++) {
        if (matches(entry, id, appIdOf(windows[w]))) { mine.push(windows[w]); used.push(windows[w]) }
      }
      items.push({ kind: "app", id: id, pinned: true, entry: entry,
                   name: entry ? entry.name : id, icon: entry ? entry.icon : id, windows: mine })
    }

    var extra = []
    var extraIds = {}
    for (var r = 0; r < windows.length; r++) {
      if (used.indexOf(windows[r]) !== -1) continue
      var appId = appIdOf(windows[r])
      if (!appId) continue
      if (extraIds[appId]) { extraIds[appId].windows.push(windows[r]); continue }
      var e = DesktopEntries.heuristicLookup(appId)
      var item = { kind: "app", id: e ? e.id : appId, pinned: false, entry: e,
                   name: e ? e.name : appId, icon: e ? e.icon : appId, windows: [windows[r]] }
      extraIds[appId] = item
      extra.push(item)
    }

    // Running apps that are not pinned go before the trash and its gap.
    if (extra.length > 0) {
      var cut = items.length
      for (var t = 0; t < items.length; t++) if (items[t].kind === "trash") cut = t
      while (cut > 0 && items[cut - 1].kind === "spacer") cut -= 1
      var tail = items.splice(cut)
      items.push({ kind: "spacer", id: "running-gap", spacerIndex: 0 })
      items = items.concat(extra).concat(tail)
    }

    items.push({ kind: "launcher", id: "launcher", name: "Apps", windows: [] })
    return items
  }

  readonly property var items: buildItems(pins, Hyprland.toplevels.values, DesktopEntries.applications.values)

  // ------------------------------------------------------------ trash

  FolderListModel {
    id: trashFiles
    folder: "file://" + root.home + "/.local/share/Trash/files"
    showHidden: true
    showDirs: true
  }

  readonly property bool trashFull: trashFiles.count > 0

  // ------------------------------------------------------------ actions

  function iconSource(icon) {
    var value = String(icon || "")
    if (value.charAt(0) === "/") return "file://" + value
    var themed = Quickshell.iconPath(value, true)
    return themed.length > 0 ? themed : Quickshell.iconPath("application-x-executable", true)
  }

  function run(command) {
    Quickshell.execDetached(["bash", "-lc", command])
  }

  function activate(item) {
    if (item.kind === "launcher") { run(launcherCommand); return }
    if (item.kind === "trash") { run("uwsm-app -- nautilus --new-window trash:///"); return }
    if (item.kind !== "app") return
    if (item.windows.length === 0) {
      run("uwsm-app -- gtk-launch " + JSON.stringify(item.id + ".desktop"))
      return
    }
    // Focus the app. When it already has focus, go to its next window.
    var next = 0
    for (var i = 0; i < item.windows.length; i++) {
      if (item.windows[i].activated) { next = (i + 1) % item.windows.length; break }
    }
    item.windows[next].wayland.activate()
  }

  function pinsCommand(args) {
    Quickshell.execDetached([home + "/.local/bin/dock-pins"].concat(args))
  }

  // ------------------------------------------------------------ show from outside

  // Write 1 to $XDG_RUNTIME_DIR/graphite-dock-show to show the dock, 0 to
  // let it hide again. For screenshots and key bindings.
  property bool forceShown: false

  FileView {
    path: Quickshell.env("XDG_RUNTIME_DIR") + "/graphite-dock-show"
    watchChanges: true
    printErrors: false
    onFileChanged: reload()
    onLoaded: root.forceShown = text().trim() === "1"
    onLoadFailed: root.forceShown = false
  }

  // ------------------------------------------------------------ one dock per screen

  Variants {
    model: Quickshell.screens

    Scope {
      id: perScreen
      required property var modelData

      property bool hotspotHit: false
      property bool panelHovered: false
      property var menuItem: null
      property Item menuAnchor: null
      property Item hoverTile: null
      property var hoverItem: null
      readonly property bool shown: root.forceShown || hotspotHit || panelHovered || menuItem !== null

      onShownChanged: if (shown) Hyprland.refreshToplevels()

      Timer {
        id: showDelay
        interval: 150
        onTriggered: perScreen.hotspotHit = true
      }

      Timer {
        id: hideDelay
        interval: 350
        onTriggered: {
          if (!perScreen.panelHovered && perScreen.menuItem === null) perScreen.hotspotHit = false
        }
      }

      // A thin strip at the bottom edge. Resting the pointer there shows the dock.
      PanelWindow {
        screen: perScreen.modelData
        anchors { bottom: true; left: true; right: true }
        implicitHeight: 2
        exclusionMode: ExclusionMode.Ignore
        color: "transparent"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "graphite-dock-hotspot"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

        HoverHandler {
          onHoveredChanged: {
            if (hovered) { hideDelay.stop(); showDelay.restart() }
            else { showDelay.stop(); if (!perScreen.panelHovered) hideDelay.restart() }
          }
        }
      }

      PanelWindow {
        id: dockWindow
        screen: perScreen.modelData
        visible: perScreen.shown
        anchors { bottom: true }
        implicitWidth: panel.width + root.shadowRoom * 2
        implicitHeight: panel.height + root.edgeGap + root.popupRoom
        exclusionMode: ExclusionMode.Ignore
        color: "transparent"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "graphite-dock"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

        readonly property real dpr: perScreen.modelData ? perScreen.modelData.devicePixelRatio : 1

        // Only the panel, the name label and the menu take the pointer.
        mask: Region {
          item: panel
          Region { item: nameLabel.visible ? nameLabel : null }
          Region { item: menu.visible ? menu : null }
        }

        HyprlandFocusGrab {
          active: perScreen.menuItem !== null
          windows: [dockWindow]
          onCleared: perScreen.menuItem = null
        }

        RectangularShadow {
          anchors.fill: panel
          radius: root.panelRadius
          offset.y: 20
          blur: 48
          spread: 0
          color: Qt.rgba(0, 0, 0, 0.55)
        }

        Rectangle {
          id: panel
          anchors.horizontalCenter: parent.horizontalCenter
          anchors.bottom: parent.bottom
          anchors.bottomMargin: root.edgeGap
          width: row.implicitWidth + root.panelPadding * 2
          height: root.tileSize + root.panelPadding * 2
          radius: root.panelRadius
          color: root.surface1

          // 1px top highlight.
          Rectangle {
            anchors { top: parent.top; left: parent.left; right: parent.right; leftMargin: root.panelRadius; rightMargin: root.panelRadius }
            height: 1
            color: root.highlight
          }

          HoverHandler {
            onHoveredChanged: {
              perScreen.panelHovered = hovered
              if (hovered) hideDelay.stop()
              else hideDelay.restart()
            }
          }

          Row {
            id: row
            anchors.centerIn: parent
            spacing: root.tileGap

            Repeater {
              model: root.items

              Item {
                id: tile
                required property var modelData
                readonly property bool isSpacer: modelData.kind === "spacer"
                readonly property bool running: (modelData.windows || []).length > 0
                readonly property bool focused: {
                  var ws = modelData.windows || []
                  for (var i = 0; i < ws.length; i++) if (ws[i].activated) return true
                  return false
                }
                readonly property bool hot: mouse.containsMouse || perScreen.menuItem === modelData

                width: isSpacer ? root.spacerWidth : root.tileSize
                height: root.tileSize

                // Lift: where the pointer is.
                Rectangle {
                  visible: !tile.isSpacer && tile.hot
                  anchors.fill: parent
                  radius: root.tileRadius
                  color: root.lift
                  Rectangle {
                    anchors { top: parent.top; left: parent.left; right: parent.right; leftMargin: root.tileRadius; rightMargin: root.tileRadius }
                    height: 1
                    color: root.highlight
                  }
                }

                Image {
                  visible: tile.modelData.kind === "app" || tile.modelData.kind === "trash"
                  anchors.centerIn: parent
                  width: root.iconSize
                  height: root.iconSize
                  sourceSize.width: root.iconSize * dockWindow.dpr
                  sourceSize.height: root.iconSize * dockWindow.dpr
                  fillMode: Image.PreserveAspectFit
                  smooth: true
                  mipmap: true
                  asynchronous: true
                  source: tile.modelData.kind === "trash"
                    ? root.iconSource(root.trashFull ? "user-trash-full" : "user-trash")
                    : (tile.modelData.kind === "app" ? root.iconSource(tile.modelData.icon) : "")
                }

                // Apps button: a line icon of four squares, like the menu.
                Grid {
                  visible: tile.modelData.kind === "launcher"
                  anchors.centerIn: parent
                  columns: 2
                  spacing: 4
                  Repeater {
                    model: 4
                    Rectangle {
                      width: 9; height: 9; radius: 2.5
                      color: "transparent"
                      border.width: 1.6
                      border.color: tile.hot ? root.accent : root.text3
                    }
                  }
                }

                // Running: a small dot. Brighter for the app with focus.
                Rectangle {
                  visible: tile.running
                  anchors.horizontalCenter: parent.horizontalCenter
                  anchors.bottom: parent.bottom
                  anchors.bottomMargin: 1
                  width: 4; height: 4; radius: 2
                  color: tile.focused ? root.text1 : root.text3
                }

                MouseArea {
                  id: mouse
                  anchors.fill: parent
                  hoverEnabled: true
                  acceptedButtons: Qt.LeftButton | Qt.RightButton
                  cursorShape: tile.isSpacer ? Qt.ArrowCursor : Qt.PointingHandCursor
                  onContainsMouseChanged: {
                    if (containsMouse && !tile.isSpacer) { perScreen.hoverTile = tile; perScreen.hoverItem = tile.modelData }
                    else if (perScreen.hoverTile === tile) { perScreen.hoverTile = null; perScreen.hoverItem = null }
                  }
                  onClicked: function(event) {
                    if (event.button === Qt.RightButton) {
                      if (tile.modelData.kind === "launcher") return
                      if (tile.modelData.kind === "spacer" && tile.modelData.spacerIndex === 0) return
                      perScreen.menuAnchor = tile
                      perScreen.menuItem = tile.modelData
                      return
                    }
                    if (tile.isSpacer) return
                    root.activate(tile.modelData)
                    perScreen.hotspotHit = false
                    root.forceShown = false
                  }
                }
              }
            }
          }
        }

        // Name of the item under the pointer.
        Rectangle {
          id: nameLabel
          visible: perScreen.hoverTile !== null && perScreen.menuItem === null
          readonly property point at: perScreen.hoverTile
            ? perScreen.hoverTile.mapToItem(dockWindow.contentItem, perScreen.hoverTile.width / 2, 0)
            : Qt.point(0, 0)
          x: Math.max(4, Math.min(dockWindow.width - width - 4, at.x - width / 2))
          y: panel.y - height - 8
          width: nameText.implicitWidth + 16
          height: 24
          radius: 6
          color: root.surface1
          Text {
            id: nameText
            anchors.centerIn: parent
            text: perScreen.hoverItem ? (perScreen.hoverItem.name || "") : ""
            font.family: root.labelFont
            font.pixelSize: 12
            color: root.text2
          }
        }

        // Right-click menu: a small panel with data rows.
        Rectangle {
          id: menu
          visible: perScreen.menuItem !== null
          readonly property var item: perScreen.menuItem
          readonly property point at: perScreen.menuAnchor
            ? perScreen.menuAnchor.mapToItem(dockWindow.contentItem, perScreen.menuAnchor.width / 2, 0)
            : Qt.point(0, 0)
          readonly property var actions: {
            var it = perScreen.menuItem
            if (!it) return []
            if (it.kind === "spacer") return [{ label: "Remove gap", run: function() { root.pinsCommand(["remove-spacer", String(it.spacerIndex)]) } }]
            var list = []
            if (it.kind === "trash") {
              list.push({ label: "Open trash", run: function() { root.activate(it) } })
              list.push({ label: "Empty trash", danger: true, run: function() { root.run("gio trash --empty") } })
            }
            if (it.kind === "app" && it.windows.length === 0) list.push({ label: "Open", run: function() { root.activate(it) } })
            if (it.kind === "app" && it.windows.length > 0) list.push({ label: "Close window", run: function() { it.windows[0].wayland.close() } })
            if (it.kind === "app" && it.pinned) list.push({ label: "Unpin", run: function() { root.pinsCommand(["unpin", it.id]) } })
            if (it.kind === "app" && !it.pinned) list.push({ label: "Pin", run: function() { root.pinsCommand(["pin", it.id]) } })
            if (it.pinned || it.kind === "trash") list.push({ label: "Add gap after", run: function() { root.pinsCommand(["add-spacer-after", it.id]) } })
            return list
          }
          width: 180
          height: menuColumn.implicitHeight + 8
          x: Math.max(4, Math.min(dockWindow.width - width - 4, at.x - width / 2))
          y: panel.y - height - 8
          radius: 8
          color: root.surface1

          Column {
            id: menuColumn
            anchors.fill: parent
            anchors.margins: 4
            spacing: 2

            Repeater {
              model: menu.actions
              Rectangle {
                required property var modelData
                width: menuColumn.width
                height: 30
                radius: 6
                color: rowMouse.containsMouse ? root.lift : "transparent"
                Text {
                  anchors.verticalCenter: parent.verticalCenter
                  anchors.left: parent.left
                  anchors.leftMargin: 8
                  text: parent.modelData.label
                  font.family: root.labelFont
                  font.pixelSize: 13
                  color: parent.modelData.danger ? root.errorColor : (rowMouse.containsMouse ? root.text1 : root.text2)
                }
                MouseArea {
                  id: rowMouse
                  anchors.fill: parent
                  hoverEnabled: true
                  onClicked: {
                    parent.modelData.run()
                    perScreen.menuItem = null
                    hideDelay.restart()
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
