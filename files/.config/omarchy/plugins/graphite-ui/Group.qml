import QtQuick

// Group: surface-2, 8px radius, 4px padding. Put rows (or anything) in it;
// they stack with 2px gaps. Set `title` for the group name line, and `count`
// for the mono count or value at its right.
Rectangle {
  id: root

  property string title: ""
  property string count: ""
  default property alias content: column.data
  property alias spacing: column.spacing

  width: parent ? parent.width : implicitWidth
  implicitWidth: column.implicitWidth + Tokens.padGroup * 2
  implicitHeight: column.implicitHeight + Tokens.padGroup * 2
  radius: Tokens.radiusGroup
  color: Tokens.surface2

  Column {
    id: column
    x: Tokens.padGroup
    y: Tokens.padGroup
    width: root.width - Tokens.padGroup * 2
    spacing: Tokens.gapRow

    Item {
      visible: root.title !== "" || root.count !== ""
      width: parent.width
      height: Tokens.rowGroupName
      Text {
        anchors.left: parent.left
        anchors.leftMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        text: root.title
        textFormat: Text.PlainText
        font.family: Tokens.labelFont
        font.pixelSize: Tokens.sizeGroupName
        font.weight: Font.DemiBold
        color: Tokens.labelTint
      }
      Text {
        anchors.right: parent.right
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        text: root.count
        textFormat: Text.PlainText
        font.family: Tokens.valueFont
        font.pixelSize: Tokens.sizeMeta
        color: Tokens.text3
      }
    }
  }
}
