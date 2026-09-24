import QtQuick

// Group name (docs/theme-direction.md): SF Pro 11px semibold in label-tint.
// Keeps the properties of Omarchy's PanelSectionHeader; the Graphite look
// wins over a caller's color and font.
Text {
  id: root

  property color foreground: Tokens.labelTint
  property string fontFamily: Tokens.labelFont
  property real fontSize: Tokens.sizeGroupName

  textFormat: Text.PlainText
  color: Tokens.labelTint
  font.family: Tokens.labelFont
  font.pixelSize: Tokens.sizeGroupName
  font.weight: Font.DemiBold
  topPadding: 2
}
