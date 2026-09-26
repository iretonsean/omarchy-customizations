pragma Singleton
import QtQuick

// Motion state shared by the Graphite panels. The open panel keeps its
// card's place here, so the panel that replaces it (a click on another bar
// icon) can start its card from there and morph instead of cutting.
QtObject {
  property rect panelRect: Qt.rect(0, 0, 0, 0)
  property string panelScreen: ""
  // Bumped when a panel starts from another panel's place. The panel that
  // just closed sees it and stays whole until the new card is on screen.
  property int takeoverSerial: 0
  // Per channel ("lift", "chosen"): the GlideLift that is lit, or was last.
  property var lifts: ({})
}
