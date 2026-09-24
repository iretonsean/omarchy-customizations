import QtQuick

// Panel title: SF Pro 15px semibold in text-1.
Text {
  textFormat: Text.PlainText
  font.family: Tokens.labelFont
  font.pixelSize: Tokens.sizePanelTitle
  font.weight: Font.DemiBold
  color: Tokens.text1
  elide: Text.ElideRight
}
