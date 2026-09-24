import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import qs.Ui

// Graphite button. Keeps the properties and signals of Omarchy's Button.
//   bordered (a pill or choice)  surface-2 fill, no outline
//   hover or keyboard cursor     lift: lift fill, top highlight, small shadow
//   selected or active           accent-soft fill with on-accent text (chosen)
// Labels are SF Pro 13px unless the caller sets fontFamily (for example mono
// for values such as "1.25x").
Item {
  id: root

  property string text: ""
  property string iconText: ""
  property string tooltipText: ""

  property bool selected: false
  property bool active: false
  property bool hasCursor: false
  property bool focusable: false
  property bool bordered: false

  property color foreground: Tokens.text2
  property color background: "transparent"
  property color accent: Tokens.accent

  property string fontFamily: Tokens.labelFont
  property real fontSize: Tokens.sizeDataRow
  property real iconSize: 15
  property real iconRotation: 0
  property bool iconSpinning: false
  property real horizontalPadding: 10
  property real verticalPadding: 5
  property bool leftAlign: false
  property int radius: Tokens.radiusRow

  // Accepted for compatibility.
  property color tooltipBackground: Tokens.surface1
  property color tooltipForeground: Tokens.text2
  property color tooltipBorder: "transparent"
  property var borderSpec: null
  property real leftPadding: horizontalPadding
  property real rightPadding: horizontalPadding
  property real topPadding: verticalPadding
  property real bottomPadding: verticalPadding

  signal clicked()
  signal rightClicked()
  signal hovered(bool isHovered)

  activeFocusOnTab: focusable
  Keys.onReturnPressed: if (focusable) root.clicked()
  Keys.onEnterPressed: if (focusable) root.clicked()
  Keys.onSpacePressed: if (focusable) root.clicked()

  implicitWidth: row.implicitWidth + horizontalPadding * 2
  implicitHeight: Math.max(Tokens.rowData, row.implicitHeight + verticalPadding * 2)

  readonly property bool hot: mouseArea.containsMouse || hasCursor || (focusable && activeFocus)
  readonly property bool chosen: selected || active
  readonly property color textColor: chosen ? Tokens.onAccent : (hot ? Tokens.text1 : root.foreground)

  // Base: chosen (accent-soft), bordered choice (surface-2) or none.
  Rectangle {
    anchors.fill: parent
    radius: root.radius
    visible: root.chosen || root.bordered || root.background.a > 0
    color: root.chosen ? Tokens.accentSoft : (root.bordered ? Tokens.surface2 : root.background)
  }

  // Lift: one layer (fill, highlight, shadow) that fades in 80ms.
  property real liftOpacity: root.hot && !root.chosen ? 1 : 0
  Behavior on liftOpacity { NumberAnimation { duration: 80; easing.type: Easing.OutCubic } }

  RectangularShadow {
    anchors.fill: surface
    opacity: root.liftOpacity
    visible: opacity > 0
    radius: root.radius
    offset.y: 2
    blur: 8
    color: Qt.rgba(0, 0, 0, 0.4)
  }

  Rectangle {
    id: surface
    anchors.fill: parent
    radius: root.radius
    color: Tokens.lift
    opacity: root.liftOpacity
    visible: opacity > 0
    Rectangle {
      anchors { top: parent.top; left: parent.left; right: parent.right; leftMargin: root.radius; rightMargin: root.radius }
      height: 1
      color: Tokens.highlight
    }
  }

  ToolTip {
    visible: root.tooltipText !== "" && mouseArea.containsMouse
    text: root.tooltipText
    delay: 400
    padding: 0
    background: Rectangle { color: Tokens.surface1; radius: Tokens.radiusRow }
    contentItem: Text {
      textFormat: Text.PlainText
      text: root.tooltipText
      color: Tokens.text2
      font.family: Tokens.labelFont
      font.pixelSize: 12
      leftPadding: 8; rightPadding: 8; topPadding: 4; bottomPadding: 4
    }
  }

  Row {
    id: row
    anchors.verticalCenter: parent.verticalCenter
    anchors.left: root.leftAlign ? parent.left : undefined
    anchors.leftMargin: root.leftAlign ? root.horizontalPadding : 0
    anchors.horizontalCenter: root.leftAlign ? undefined : parent.horizontalCenter
    spacing: 8

    Text {
      textFormat: Text.PlainText
      visible: root.iconText !== ""
      text: root.iconText
      color: root.chosen ? Tokens.onAccent : (root.hot ? Tokens.accent : Tokens.text3)
      font.family: Tokens.valueFont
      font.pixelSize: root.iconSize
      rotation: root.iconSpinning ? 0 : root.iconRotation
      transformOrigin: Item.Center
      anchors.verticalCenter: parent.verticalCenter
      RotationAnimation on rotation {
        from: 0; to: 360; duration: 900
        loops: Animation.Infinite
        running: root.iconSpinning
      }
    }

    Text {
      textFormat: Text.PlainText
      visible: root.text !== ""
      text: root.text
      color: root.textColor
      font.family: root.fontFamily
      font.pixelSize: root.fontSize
      anchors.verticalCenter: parent.verticalCenter
    }
  }

  MouseArea {
    id: mouseArea
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    onClicked: function(mouse) {
      if (root.focusable) root.forceActiveFocus()
      if (mouse.button === Qt.RightButton) root.rightClicked()
      else root.clicked()
    }
  }

  HoverHandler {
    onHoveredChanged: root.hovered(hovered)
  }
}
