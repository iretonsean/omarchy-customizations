import QtQuick

// Status text: SF Mono 12px in ok, warn or error ("connected", "3 ready",
// "failed"). Set `status` to "ok", "warn" or "error".
Text {
  property string status: "ok"
  textFormat: Text.PlainText
  font.family: Tokens.valueFont
  font.pixelSize: Tokens.sizeValue
  color: status === "error" ? Tokens.error : (status === "warn" ? Tokens.warn : Tokens.ok)
}
