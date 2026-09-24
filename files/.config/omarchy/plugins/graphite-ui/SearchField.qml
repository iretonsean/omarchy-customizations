import QtQuick

// Search field: the value-field shape (5px radius, surface-2 on a panel) with
// a search icon, 24px high. Shows what is typed, or the placeholder in
// text-3. Typing goes to the panel's own key handler; this part only draws.
Rectangle {
  id: root

  property string text: ""
  property string placeholder: "Search"
  property bool active: true
  property color background: Tokens.surface2

  implicitWidth: 240
  implicitHeight: 24
  radius: Tokens.radiusField
  color: background

  Text {
    id: icon
    anchors.left: parent.left
    anchors.leftMargin: 8
    anchors.verticalCenter: parent.verticalCenter
    text: ""
    textFormat: Text.PlainText
    font.family: Tokens.valueFont
    font.pixelSize: 11
    color: Tokens.text3
  }

  Text {
    id: label
    anchors.left: icon.right
    anchors.leftMargin: 7
    anchors.right: clearKey.visible ? clearKey.left : parent.right
    anchors.rightMargin: 8
    anchors.verticalCenter: parent.verticalCenter
    text: root.text || root.placeholder
    textFormat: Text.PlainText
    font.family: Tokens.labelFont
    font.pixelSize: Tokens.sizeValue
    color: root.text ? Tokens.text1 : Tokens.text3
    elide: Text.ElideLeft
  }

  // Text cursor after the typed text.
  Rectangle {
    visible: root.active
    x: label.x + (root.text ? Math.min(label.contentWidth, label.width) + 1 : -1)
    anchors.verticalCenter: parent.verticalCenter
    width: 1
    height: 14
    color: Tokens.accent
    SequentialAnimation on opacity {
      running: root.active
      loops: Animation.Infinite
      NumberAnimation { to: 0; duration: 500; easing.type: Easing.InOutQuad }
      NumberAnimation { to: 1; duration: 500; easing.type: Easing.InOutQuad }
    }
  }

  // Esc clears the search.
  Keycap {
    id: clearKey
    visible: root.text !== ""
    anchors.right: parent.right
    anchors.rightMargin: 3
    anchors.verticalCenter: parent.verticalCenter
    text: "esc"
    textColor: Tokens.text3
  }
}
