import QtQuick
import QtQuick.Effects

// The lift of one CursorSurface, drawn in the container that holds its row
// (stacked below every row, so a stretched lift never covers a neighbour's
// text). When the cursor moves to another row in the same container, the
// new lift starts from the old one's place and its four edges spring into
// position: the leading edge on lead, the trailing edge on trail, so it
// stretches in the direction of travel. Created by CursorSurface.
Item {
  id: root

  property real targetX: 0
  property real targetY: 0
  property real targetW: 0
  property real targetH: 0
  property int radius: Tokens.radiusRow
  property color fill: Tokens.lift
  property bool shown: false
  property bool shadowed: true
  // Opacity of the items between the surface and this container: the lift
  // lives outside them, so it applies theirs itself.
  property real outerOpacity: 1

  // Shown at once (lit when the row was created).
  function appear() { fadeSpring.jump(1) }

  // Hidden at once (another lift took over from here).
  function drop() { fadeSpring.jump(0) }

  // Take over from another lift: start at its place, spring to ours.
  function launchFrom(r) {
    fadeSpring.jump(1)
    left.launchFrom(r.x)
    right.launchFrom(r.x + r.width)
    top.launchFrom(r.y)
    bottom.launchFrom(r.y + r.height)
  }

  readonly property rect currentRect: Qt.rect(left.value, top.value, right.value - left.value, bottom.value - top.value)
  readonly property real fade: fadeSpring.value

  Spring {
    id: fadeSpring
    target: root.shown ? 1 : 0
    response: Tokens.snapResponse
    damping: Tokens.snapDamping
  }
  readonly property bool _snap: fadeSpring.value < 0.05
  Spring {
    id: left
    target: root.targetX
    instant: root._snap
    damping: Tokens.edgeDamping
    riseResponse: Tokens.trailResponse
    fallResponse: Tokens.leadResponse
  }
  Spring {
    id: right
    target: root.targetX + root.targetW
    instant: root._snap
    damping: Tokens.edgeDamping
    riseResponse: Tokens.leadResponse
    fallResponse: Tokens.trailResponse
  }
  Spring {
    id: top
    target: root.targetY
    instant: root._snap
    damping: Tokens.edgeDamping
    riseResponse: Tokens.trailResponse
    fallResponse: Tokens.leadResponse
  }
  Spring {
    id: bottom
    target: root.targetY + root.targetH
    instant: root._snap
    damping: Tokens.edgeDamping
    riseResponse: Tokens.leadResponse
    fallResponse: Tokens.trailResponse
  }

  visible: fadeSpring.value > 0
  x: left.value
  y: top.value
  width: Math.max(0, right.value - left.value)
  height: Math.max(0, bottom.value - top.value)
  opacity: Math.min(1, fadeSpring.value) * root.outerOpacity

  RectangularShadow {
    visible: root.shadowed
    anchors.fill: parent
    radius: root.radius
    offset.y: 2
    blur: 8
    color: Qt.rgba(0, 0, 0, 0.4)
  }

  Rectangle {
    anchors.fill: parent
    radius: root.radius
    color: root.fill
    Rectangle {
      visible: root.shadowed
      anchors { top: parent.top; left: parent.left; right: parent.right; leftMargin: root.radius; rightMargin: root.radius }
      height: 1
      color: Tokens.highlight
    }
  }
}
