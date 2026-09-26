import QtQuick
import Quickshell

// Row background. The keyboard cursor and hover lift the row (lift fill, top
// highlight, small shadow). "Current" (for example the connected network) is
// not a fill in Graphite; the row shows it with status text instead.
// Keeps the properties of Omarchy's CursorSurface.
//
// Motion: the lift is a GlideLift in the row's container, so moving the
// cursor between rows of one container glides one highlight instead of
// fading one out and the next in (docs/theme-direction.md, Motion).
Item {
  id: root

  property bool hasCursor: false
  property bool current: false
  property bool outline: false
  property bool bordered: false

  property color foreground: Tokens.text2
  property color accent: Tokens.accent
  property color fill: Tokens.lift
  property color currentFill: "transparent"
  property int radius: Tokens.radiusRow
  // Glide channel: lifts only carry over to lifts of the same channel.
  // "lift" (hover and cursor), "chosen" (the chosen choice's fill) or
  // "base" (a pill's resting fill, drawn in the same layer so a gliding
  // fill is not hidden behind the next pill). depth orders them: base
  // below chosen below lift.
  property string channel: "lift"
  property real depth: 0
  property bool shadowed: true

  // BorderSurface compatibility for callers that read these.
  property var borderSpec: null
  property color color: "transparent"
  readonly property real borderTop: 0
  readonly property real borderRight: 0
  readonly property real borderBottom: 0
  readonly property real borderLeft: 0

  readonly property real liftOpacity: _lift ? _lift.fade : 0

  Rectangle {
    anchors.fill: parent
    visible: root.current && !root.hasCursor && root.currentFill.a > 0
    radius: root.radius
    color: root.currentFill
  }

  // --- glide ----------------------------------------------------------------

  // The container the lift lives in: the nearest ancestor that does not
  // position its children (a Column would lay the lift out as a row). A
  // surface that only fills its parent (a Chip's background) belongs to
  // the parent's container, so its lift can glide to the next chip.
  function _isPositioner(item) {
    return /^(QQuick)?(Column|Row|Grid|Flow)(Layout)?(_QML|\()/.test(String(item))
  }
  function _findScope() {
    var p = root.parent
    if (p && root.anchors.fill === p && p.parent) p = p.parent
    while (p && root._isPositioner(p)) p = p.parent
    return p
  }

  property Item _scope: null
  property GlideLift _lift: null

  TransformWatcher {
    id: watcher
    a: root._scope
    b: root
  }
  readonly property rect _rectInScope: {
    watcher.transform
    root.width; root.height
    if (!root._scope) return Qt.rect(0, 0, 0, 0)
    var p = root.mapToItem(root._scope, 0, 0)
    return Qt.rect(p.x, p.y, root.width, root.height)
  }

  Binding { when: !!root._lift; target: root._lift; property: "targetX"; value: root._rectInScope.x }
  Binding { when: !!root._lift; target: root._lift; property: "targetY"; value: root._rectInScope.y }
  Binding { when: !!root._lift; target: root._lift; property: "targetW"; value: root._rectInScope.width }
  Binding { when: !!root._lift; target: root._lift; property: "targetH"; value: root._rectInScope.height }
  Binding { when: !!root._lift; target: root._lift; property: "radius"; value: root.radius }
  Binding { when: !!root._lift; target: root._lift; property: "fill"; value: root.fill }
  Binding { when: !!root._lift; target: root._lift; property: "shadowed"; value: root.shadowed }
  readonly property real _outerOpacity: {
    var o = 1
    for (var p = root; p && p !== root._scope; p = p.parent) o *= p.opacity
    return o
  }
  Binding { when: !!root._lift; target: root._lift; property: "outerOpacity"; value: root._outerOpacity }

  function _setShown(on) {
    if (!root._lift) return
    if (!on) {
      root._lift.shown = false
      return
    }
    // Decide at the end of this turn of the event loop: a cursor move
    // unlights the old row and lights the new one in either order.
    Qt.callLater(function() {
      if (!root._lift || !root._lit || root._lift.shown) return
      // The lift of this container that just lost the cursor (still on
      // screen, fading): carry it here instead of fading in a new one.
      var from = MotionState.lifts[root.channel]
      if (from && from !== root._lift && from.parent === root._lift.parent && !from.shown && from.fade > 0.05) {
        var r = from.currentRect
        from.drop()
        root._lift.shown = true
        root._lift.launchFrom(r)
      } else {
        root._lift.shown = true
      }
      MotionState.lifts[root.channel] = root._lift
    })
  }

  readonly property bool _lit: root.hasCursor && root.visible
  on_LitChanged: root._setShown(root._lit)

  Component {
    id: liftComponent
    GlideLift {}
  }

  Component.onCompleted: {
    root._scope = root._findScope()
    if (!root._scope) return
    root._lift = liftComponent.createObject(root._scope, {
      targetX: root._rectInScope.x, targetY: root._rectInScope.y,
      targetW: root._rectInScope.width, targetH: root._rectInScope.height,
      radius: root.radius, fill: root.fill
    })
    // Below the rows: raise the container's child that holds this row
    // above the lift (z 0.5), so rows draw on top of it and the
    // container's own fill stays below it.
    var c = root
    while (c.parent && c.parent !== root._scope) c = c.parent
    if (c !== root._lift && c.z < 1) c.z = 1
    root._lift.z = 0.5 + root.depth * 0.05
    if (root._lit) {
      root._lift.shown = true
      root._lift.appear()
      MotionState.lifts[root.channel] = root._lift
    }
  }
  Component.onDestruction: {
    if (root._lift) {
      if (MotionState.lifts[root.channel] === root._lift) delete MotionState.lifts[root.channel]
      root._lift.destroy()
    }
  }
}
