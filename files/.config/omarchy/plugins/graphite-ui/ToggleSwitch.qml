import QtQuick
import QtQuick.Effects

// Graphite toggle (docs/theme-direction.md): a 36 x 18 rounded rectangle.
// Off: surface-3 track, #c7c7cc knob on the left. On: accent track, white
// knob on the right. Keeps the properties and signals of Omarchy's
// ToggleSwitch. The keyboard cursor lifts the area behind the switch.
Item {
  id: root

  property bool checked: false
  property bool busy: false
  property bool interactive: true
  property bool hasCursor: false
  property bool cursorRing: interactive
  property int cursorPad: 4
  property bool rounded: true
  property color foreground: Tokens.text2
  property color accent: Tokens.accent

  signal toggled()
  signal hovered(bool isHovered)

  readonly property alias containsMouse: mouse.containsMouse
  readonly property bool hot: hasCursor || mouse.containsMouse

  // Accepted for compatibility; the Graphite size is fixed.
  property int trackHeight: 18
  property int trackWidth: 36
  property int knobSize: 14
  property int knobInset: 2

  readonly property int _pad: cursorRing ? cursorPad : 0

  implicitWidth: 36 + _pad * 2
  implicitHeight: 18 + _pad * 2

  Rectangle {
    anchors.fill: parent
    visible: root.cursorRing && root.hasCursor
    radius: Tokens.radiusRow
    color: Tokens.lift
  }

  Rectangle {
    id: track
    width: 36
    height: 18
    anchors.centerIn: parent
    radius: 5
    color: root.checked ? Tokens.accent : Tokens.surface3
    clip: true
    Behavior on color { ColorAnimation { duration: 120 * Tokens.motion } }

    // Off: inner shadow along the top. On: 1px top highlight.
    Rectangle {
      anchors { left: parent.left; right: parent.right; top: parent.top }
      height: root.checked ? 1 : 3
      gradient: Gradient {
        GradientStop { position: 0; color: root.checked ? Qt.rgba(1, 1, 1, 0.18) : Qt.rgba(0, 0, 0, 0.45) }
        GradientStop { position: 1; color: root.checked ? Qt.rgba(1, 1, 1, 0.18) : Qt.rgba(0, 0, 0, 0) }
      }
    }

    RectangularShadow {
      anchors.fill: knob
      radius: 3
      offset.y: 1
      blur: 2
      color: Qt.rgba(0, 0, 0, 0.4)
    }

    // The knob's two edges ride different springs: the edge in front
    // leads, so the knob stretches on the way across and settles 16 wide.
    Spring {
      id: knobLeft
      target: root.checked ? track.width - 18 : 2
      damping: Tokens.edgeDamping
      riseResponse: Tokens.trailResponse
      fallResponse: Tokens.leadResponse
    }
    Spring {
      id: knobRight
      target: root.checked ? track.width - 2 : 18
      damping: Tokens.edgeDamping
      riseResponse: Tokens.leadResponse
      fallResponse: Tokens.trailResponse
    }

    Rectangle {
      id: knob
      height: 14
      radius: 3
      y: 2
      x: knobLeft.value
      width: Math.max(14, knobRight.value - knobLeft.value)
      color: root.checked ? "#ffffff" : "#c7c7cc"
    }
  }

  MouseArea {
    id: mouse
    anchors.fill: parent
    enabled: root.interactive
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onContainsMouseChanged: root.hovered(containsMouse)
    onClicked: if (!root.busy) root.toggled()
  }
}
