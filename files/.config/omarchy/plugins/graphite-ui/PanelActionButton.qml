import QtQuick
import QtQuick.Effects
import qs.Ui
import "." as Graphite

// Small icon button in a panel header (QR code, speed test, refresh). Line
// icon in text-3; under the pointer or keyboard cursor it lifts and the icon
// turns accent. Keeps the properties and signals of Omarchy's
// PanelActionButton.
Item {
  id: root

  property string iconText: ""
  property string tooltipText: ""
  property color foreground: Tokens.text3
  property color hoverColor: Tokens.accent
  property string fontFamily: Tokens.valueFont
  property real fontSize: 15
  property real size: 28
  property bool focusable: false
  property bool hasCursor: false
  property bool bordered: false
  property int radius: Tokens.radiusRow

  signal clicked()
  signal hovered(bool isHovered)

  activeFocusOnTab: focusable
  Keys.onReturnPressed: if (focusable) root.clicked()
  Keys.onEnterPressed: if (focusable) root.clicked()
  Keys.onSpacePressed: if (focusable) root.clicked()

  implicitWidth: size
  implicitHeight: size

  readonly property bool _hot: (mouse.containsMouse || root.hasCursor || (focusable && activeFocus)) && root.enabled

  // Lift: a CursorSurface, so it glides to a neighbouring button.
  Graphite.CursorSurface {
    id: liftSurface
    anchors.fill: parent
    radius: root.radius
    hasCursor: root._hot
  }
  readonly property real liftOpacity: liftSurface.liftOpacity


  Text {
    textFormat: Text.PlainText
    anchors.centerIn: parent
    text: root.iconText
    color: root.enabled ? (root._hot ? Tokens.accent : Tokens.text3) : Tokens.text4
    font.family: Tokens.valueFont
    font.pixelSize: root.fontSize
  }

  MouseArea {
    id: mouse
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
    enabled: root.enabled
    onContainsMouseChanged: root.hovered(containsMouse)
    onClicked: {
      if (root.focusable) root.forceActiveFocus()
      root.clicked()
    }
  }

  PanelToolTip {
    visible: root.tooltipText !== "" && mouse.containsMouse
    text: root.tooltipText
    fontFamily: Tokens.labelFont
  }
}
