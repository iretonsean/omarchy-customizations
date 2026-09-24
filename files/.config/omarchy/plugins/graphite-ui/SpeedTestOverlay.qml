import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell
import Quickshell.Wayland
import qs.Commons

// Graphite speed test overlay (docs/theme-direction.md). Same properties and
// signals as Omarchy's Ui/SpeedTestOverlay.qml, so the network and disk speed
// tests only change the type name.
//
// A panel sits on the dimmed screen. It holds one group per gauge. Each
// gauge is a plain arc: a surface-3 track with an accent fill, no ticks and
// no needle. The reading is SF Mono in the middle, with the unit under it
// and the full scale at the foot of the arc. Esc or a click outside the
// panel closes it; Return runs the test again.
PanelWindow {
  id: root

  required property string fontFamily
  required property bool running
  required property string leftLabel
  required property string rightLabel
  property string unit: "Mbps"
  property string title: ""
  // Graphite: the panel title. The Omarchy `title` (connection or disk
  // name) shows as the meta on the right.
  property string heading: "Speed test"
  property string layerNamespace: "omarchy-speed-test"
  property string runAgainTooltip: "Measure again"
  property real leftValue: 0
  property real rightValue: 0
  property bool leftLive: false
  property bool rightLive: false
  property string error: ""
  property bool open: false
  // Full-scale latch points for the gauges, smallest first.
  property var scaleStops: [100, 250, 500, 1000, 2500, 5000, 10000]
  property real fullScale: scaleStops[0]

  signal closeRequested()
  signal runAgainRequested()

  readonly property bool failed: error !== ""

  function resetScale() {
    fullScale = scaleStops[0]
  }

  // Either reading moves both gauges to the next scale, so they always
  // share one scale.
  function expandScale(value) {
    for (var i = 0; i < scaleStops.length; i++) {
      if (value <= scaleStops[i] * 0.92) {
        if (scaleStops[i] > fullScale) fullScale = scaleStops[i]
        return
      }
    }
    fullScale = scaleStops[scaleStops.length - 1]
  }

  function formatNumber(value) {
    return value < 10
      ? value.toLocaleString(Qt.locale(), 'f', 1)
      : Math.round(value).toLocaleString(Qt.locale(), 'f', 0)
  }

  onRunningChanged: if (running) resetScale()
  onScaleStopsChanged: resetScale()
  onLeftValueChanged: expandScale(leftValue)
  onRightValueChanged: expandScale(rightValue)

  visible: open
  onOpenChanged: {
    if (open) Qt.callLater(function() {
      if (root.open) keyCatcher.forceActiveFocus()
    })
  }
  anchors { top: true; bottom: true; left: true; right: true }
  color: "transparent"
  exclusionMode: ExclusionMode.Ignore
  WlrLayershell.namespace: root.layerNamespace
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

  // Dimmed screen behind the panel. A click here closes the overlay.
  Rectangle {
    anchors.fill: parent
    color: Qt.rgba(0, 0, 0, 0.5)

    MouseArea {
      anchors.fill: parent
      onClicked: root.closeRequested()
    }
  }

  Item {
    id: keyCatcher
    anchors.fill: parent
    focus: true

    Keys.onEscapePressed: root.closeRequested()
    Keys.onReturnPressed: if (!root.running) root.runAgainRequested()
    Keys.onEnterPressed: if (!root.running) root.runAgainRequested()

    RectangularShadow {
      anchors.fill: panel
      radius: Tokens.radiusPanel
      offset.y: 20
      blur: 48
      color: Qt.rgba(0, 0, 0, 0.55)
      scale: panel.scale
    }

    // Panel: surface-1, 16px radius, 16px padding, 1px top highlight.
    Rectangle {
      id: panel
      anchors.centerIn: parent
      width: content.implicitWidth + Tokens.padPanel * 2
      height: content.implicitHeight + Tokens.padPanel * 2
      radius: Tokens.radiusPanel
      color: Tokens.surface1
      // Small or scaled screens: shrink the panel instead of cutting it off.
      scale: Math.min(1, (keyCatcher.width - 32) / Math.max(1, width), (keyCatcher.height - 32) / Math.max(1, height))

      Rectangle {
        anchors { top: parent.top; left: parent.left; right: parent.right; leftMargin: Tokens.radiusPanel; rightMargin: Tokens.radiusPanel }
        height: 1
        color: Tokens.highlight
      }

      // Clicks on the panel do not close it.
      MouseArea { anchors.fill: parent; onClicked: {} }

      ColumnLayout {
        id: content
        x: Tokens.padPanel
        y: Tokens.padPanel
        spacing: 12

        // Title row: title left, meta (the connection or disk) right.
        RowLayout {
          Layout.fillWidth: true
          Layout.leftMargin: 4
          Layout.rightMargin: 4
          spacing: 12
          PanelTitle { text: root.heading }
          Item { Layout.fillWidth: true }
          PanelMeta { text: root.title }
        }

        Row {
          spacing: Tokens.gapGroup
          Layout.alignment: Qt.AlignHCenter

          GaugeGroup { label: root.leftLabel; value: root.leftValue; live: root.leftLive }
          GaugeGroup { label: root.rightLabel; value: root.rightValue; live: root.rightLive }
        }

        StatusText {
          visible: root.failed
          status: "error"
          text: root.error
          wrapMode: Text.Wrap
          horizontalAlignment: Text.AlignHCenter
          Layout.fillWidth: true
          Layout.maximumWidth: 440
          Layout.alignment: Qt.AlignHCenter
        }

        // Stays in the layout while a run is in progress, so the panel does
        // not change size.
        Button {
          text: "Run again"
          tooltipText: root.runAgainTooltip
          bordered: true
          enabled: !root.running
          opacity: root.running ? 0 : 1
          horizontalPadding: 14
          Layout.alignment: Qt.AlignHCenter
          onClicked: root.runAgainRequested()
          Behavior on opacity { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
        }
      }
    }
  }

  // One gauge in its group: group name and state on the first line, the arc
  // with the reading and unit below.
  component GaugeGroup: Rectangle {
    id: group

    required property string label
    required property real value
    required property bool live

    // A gauge that is not measuring yet stays quiet until it has a figure.
    readonly property bool engaged: live || value > 0
    property real shown: 0
    readonly property real fraction: root.fullScale > 0 ? Math.max(0, Math.min(1, shown / root.fullScale)) : 0

    Behavior on shown { NumberAnimation { duration: 600; easing.type: Easing.OutCubic } }
    onValueChanged: shown = value
    Component.onCompleted: shown = value

    width: 232
    height: column.implicitHeight + Tokens.padGroup * 2
    radius: Tokens.radiusGroup
    color: Tokens.surface2

    Column {
      id: column
      x: Tokens.padGroup
      y: Tokens.padGroup
      width: group.width - Tokens.padGroup * 2

      Item {
        width: parent.width
        height: Tokens.rowGroupName
        Text {
          anchors.left: parent.left
          anchors.leftMargin: 8
          anchors.verticalCenter: parent.verticalCenter
          text: group.label.charAt(0).toUpperCase() + group.label.slice(1).toLowerCase()
          font.family: Tokens.labelFont
          font.pixelSize: Tokens.sizeGroupName
          font.weight: Font.DemiBold
          color: Tokens.labelTint
        }
        Text {
          anchors.right: parent.right
          anchors.rightMargin: 8
          anchors.verticalCenter: parent.verticalCenter
          // State of this gauge: measuring, waiting or done.
          text: group.live ? "measuring" : (group.engaged ? "done" : "waiting")
          font.family: Tokens.valueFont
          font.pixelSize: Tokens.sizeMeta
          color: group.live ? Tokens.accentSoft : Tokens.text3
        }
      }

      Item {
        id: dial
        width: parent.width
        height: 200

        readonly property real size: 176
        readonly property real stroke: 10
        readonly property real radius: size / 2 - stroke / 2
        readonly property real cx: width / 2
        readonly property real cy: 100
        // 0° = 3 o'clock, clockwise. A 240° arc, open at the bottom.
        readonly property real startAngle: 150
        readonly property real sweep: 240

        Shape {
          anchors.fill: parent
          preferredRendererType: Shape.CurveRenderer

          ShapePath {
            strokeWidth: dial.stroke
            strokeColor: Tokens.surface3
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            PathAngleArc {
              centerX: dial.cx; centerY: dial.cy
              radiusX: dial.radius; radiusY: dial.radius
              startAngle: dial.startAngle
              sweepAngle: dial.sweep
            }
          }

          ShapePath {
            strokeWidth: dial.stroke
            // Transparent at zero, or the round cap leaves a dot.
            strokeColor: group.fraction > 0.004 ? Tokens.accent : "transparent"
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            PathAngleArc {
              centerX: dial.cx; centerY: dial.cy
              radiusX: dial.radius; radiusY: dial.radius
              startAngle: dial.startAngle
              sweepAngle: dial.sweep * group.fraction
            }
          }
        }

        // Reading and unit in the middle of the arc.
        Column {
          anchors.horizontalCenter: parent.horizontalCenter
          y: dial.cy - height / 2
          spacing: 2
          Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.formatNumber(group.shown)
            font.family: Tokens.valueFont
            font.pixelSize: 34
            color: group.engaged ? Tokens.text1 : Tokens.text4
          }
          Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.unit
            font.family: Tokens.valueFont
            font.pixelSize: Tokens.sizeValue
            color: group.engaged ? Tokens.text3 : Tokens.text4
          }
        }

        // Scale at the foot of the arc: 0 on the left, full scale on the right.
        Text {
          x: dial.cx - dial.radius * 0.87 - width / 2
          y: dial.cy + dial.radius * 0.5 + 10
          text: "0"
          font.family: Tokens.valueFont
          font.pixelSize: Tokens.sizeMeta
          color: Tokens.text3
        }
        Text {
          x: dial.cx + dial.radius * 0.87 - width / 2
          y: dial.cy + dial.radius * 0.5 + 10
          text: root.formatNumber(root.fullScale)
          font.family: Tokens.valueFont
          font.pixelSize: Tokens.sizeMeta
          color: Tokens.text3
        }
      }
    }
  }
}
