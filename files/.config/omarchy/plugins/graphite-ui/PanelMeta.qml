import QtQuick

// Panel meta: SF Mono 11px in text-3, next to or under the panel title.
// Lower case, no letter spacing.
Text {
  textFormat: Text.PlainText
  font.family: Tokens.valueFont
  font.pixelSize: Tokens.sizeMeta
  color: Tokens.text3
  elide: Text.ElideRight
}
