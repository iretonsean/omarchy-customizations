import QtQuick

// Value text: SF Mono 12px in text-3. Numbers, units, times, addresses,
// counts and keys are values.
Text {
  textFormat: Text.PlainText
  font.family: Tokens.valueFont
  font.pixelSize: Tokens.sizeValue
  color: Tokens.text3
}
