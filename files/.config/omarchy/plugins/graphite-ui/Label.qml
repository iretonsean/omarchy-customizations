import QtQuick

// Label text: SF Pro in text-2. `nav: true` is the 14px navigation size;
// the default is the 13px data size. Names (networks, devices, apps) are
// labels.
Text {
  property bool nav: false
  textFormat: Text.PlainText
  font.family: Tokens.labelFont
  font.pixelSize: nav ? Tokens.sizeNavRow : Tokens.sizeDataRow
  color: Tokens.text2
  elide: Text.ElideRight
}
