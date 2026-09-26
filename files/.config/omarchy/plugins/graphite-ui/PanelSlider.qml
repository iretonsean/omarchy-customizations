import QtQuick

// Graphite slider (docs/theme-direction.md): a 4px surface-3 track with an
// accent fill. A small knob shows only under the pointer or while dragging.
// Keeps the properties and signals of Omarchy's PanelSlider; the Graphite
// colors win over a caller's colors.
Item {
  id: root

  property QtObject bar: null
  property real value: 0
  property real minimum: 0
  property real maximum: 1
  property real step: 0.05
  property bool integer: false
  property color trackColor: Tokens.surface3
  property color fillColor: Tokens.accent
  property color knobColor: "#ffffff"
  property bool dragging: false
  property real trackHeight: 4
  property real knobSize: 12
  property real liveValue: value
  property int tickCount: 0
  property color tickColor: Tokens.surface1

  onValueChanged: if (!dragging) liveValue = value

  signal moved(real value)
  signal released(real value)
  signal rightClicked()

  implicitWidth: 200
  implicitHeight: 22

  readonly property real range: Math.max(0.0001, maximum - minimum)
  readonly property real progress: Math.max(0, Math.min(1, (liveValue - minimum) / range))
  readonly property bool _hot: mouseArea.containsMouse || root.dragging

  // Motion. While dragging, the fill follows the pointer directly; a click
  // or a value from outside springs there. Dragged past either end, the
  // track stretches (up to 6px, with resistance) and springs back on release.
  property real _overshoot: 0
  readonly property real _stretchMax: 6
  function _rubber(px) {
    var d = Math.abs(px)
    return (px < 0 ? -1 : 1) * root._stretchMax * (1 - Math.exp(-d / 40))
  }
  Spring {
    id: shown
    target: root.progress
    instant: root.dragging
  }
  Spring {
    id: stretch
    target: root._rubber(root._overshoot)
    instant: root.dragging
  }
  readonly property real _shownProgress: Math.max(0, Math.min(1, shown.value))
  readonly property real _stretchLeft: Math.max(0, -stretch.value)
  readonly property real _stretchRight: Math.max(0, stretch.value)

  // The resting track. Its geometry does not stretch, so values and ticks
  // keep their places; the visible bar below does.
  Item {
    id: track
    anchors.verticalCenter: parent.verticalCenter
    anchors.left: parent.left
    anchors.right: parent.right
    height: 4
  }

  Rectangle {
    id: trackBar
    anchors.verticalCenter: track.verticalCenter
    x: -root._stretchLeft
    width: track.width + root._stretchLeft + root._stretchRight
    // Thins a little as it stretches.
    height: 4 - (root._stretchLeft + root._stretchRight) / root._stretchMax
    radius: height / 2
    color: Tokens.surface3
  }

  Rectangle {
    anchors.verticalCenter: track.verticalCenter
    x: trackBar.x
    height: trackBar.height
    radius: trackBar.radius
    color: Tokens.accent
    width: root._shownProgress >= 1 ? trackBar.width : root._shownProgress <= 0 ? 0 : track.width * root._shownProgress + root._stretchLeft
  }

  Repeater {
    model: root.tickCount > 1 ? root.tickCount : 0
    Rectangle {
      required property int index
      width: 2
      height: 8
      radius: 1
      color: Tokens.surface1
      anchors.verticalCenter: track.verticalCenter
      x: Math.max(0, Math.min(track.width - width, track.width * (index / (root.tickCount - 1)) - width / 2))
    }
  }

  Rectangle {
    width: root.knobSize
    height: root.knobSize
    radius: root.knobSize / 2
    color: "#ffffff"
    opacity: root._hot ? 1 : 0
    anchors.verticalCenter: track.verticalCenter
    x: Math.max(-root._stretchLeft, Math.min(track.width - width + root._stretchRight, track.width * root._shownProgress - width / 2 + root._stretchRight - root._stretchLeft))
    Behavior on opacity { NumberAnimation { duration: 80 * Tokens.motion } }
  }

  MouseArea {
    id: mouseArea
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    acceptedButtons: Qt.LeftButton | Qt.RightButton

    function valueFromX(x) {
      var clamped = Math.max(0, Math.min(track.width, x))
      var raw = root.minimum + (clamped / track.width) * root.range
      if (root.integer) raw = Math.round(raw)
      return Math.max(root.minimum, Math.min(root.maximum, raw))
    }

    onPressed: function(mouse) {
      if (mouse.button !== Qt.LeftButton) return
      root.dragging = true
      var next = valueFromX(mouse.x)
      root.liveValue = next
      root.moved(next)
    }
    onClicked: function(mouse) {
      if (mouse.button === Qt.RightButton) root.rightClicked()
    }
    onPositionChanged: function(mouse) {
      if (!root.dragging) return
      root._overshoot = mouse.x < 0 ? mouse.x : Math.max(0, mouse.x - track.width)
      var next = valueFromX(mouse.x)
      root.liveValue = next
      root.moved(next)
    }
    onReleased: function(mouse) {
      if (mouse.button !== Qt.LeftButton) return
      root.dragging = false
      root._overshoot = 0
      root.released(root.liveValue)
      root.liveValue = root.value
    }
    onWheel: function(wheel) {
      var delta = wheel.angleDelta.y > 0 ? root.step : -root.step
      var next = Math.max(root.minimum, Math.min(root.maximum, root.liveValue + delta))
      if (root.integer) next = Math.round(next)
      root.liveValue = next
      root.moved(next)
      root.released(next)
    }
  }
}
