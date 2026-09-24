import QtQuick

// Value field: surface-1, 22px high, 5px radius, SF Mono 12px. The unit is
// text-3 ("62 %", "12 px").
Rectangle {
  id: root

  property string value: ""
  property string unit: ""
  property color background: Tokens.surface1

  implicitWidth: row.implicitWidth + 14
  implicitHeight: 22
  radius: Tokens.radiusField
  color: background

  Row {
    id: row
    anchors.centerIn: parent
    spacing: 5
    Text {
      text: root.value
      textFormat: Text.PlainText
      font.family: Tokens.valueFont
      font.pixelSize: Tokens.sizeValue
      color: Tokens.text2
    }
    Text {
      visible: root.unit !== ""
      text: root.unit
      textFormat: Text.PlainText
      font.family: Tokens.valueFont
      font.pixelSize: Tokens.sizeValue
      color: Tokens.text3
    }
  }
}
