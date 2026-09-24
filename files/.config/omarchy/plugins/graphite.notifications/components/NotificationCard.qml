// Notification card. Pure presentational — no service, Notification, or
// ListModel references. The popup container drives lifetime; the history
// panel drives static rendering. Both use the same component.
//
// Graphite (docs/theme-direction.md, Components 9): a panel with 12px
// padding, no border, a line icon in accent-soft, the title in SF Pro 14px
// semibold with the time in SF Mono at the right edge, the body in text-3.
// Hover lifts the card. The properties and signals are the stock card's, so
// Service.qml drives it unchanged.

import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import qs.Commons
import "../NotificationLogic.js" as NotificationLogic
import "../../graphite-ui" as G

Item {
  id: root

  property string app: ""
  property string appIcon: ""
  property string summary: ""
  property string body: ""
  property string image: ""
  // Nerd Font glyph rendered in the icon slot when no real icon is set.
  // Used by omarchy-notification-send so user-action toasts (`Silenced
  // notifications` etc.) show their bell/lock/etc. glyph without leaking
  // into the summary text.
  property string glyph: ""
  // NotificationUrgency: Low=0, Normal=1, Critical=2 (upstream).
  property int urgency: 1
  property double timestamp: 0
  // Accepted for compatibility. The card uses the Graphite panel radius.
  property int cornerRadius: 0

  // System monospace font injected by the container. Accepted for
  // compatibility; glyphs use the Graphite value font (a Nerd Font).
  property string fontFamily: ""

  readonly property bool hovered: hoverTracker.hovered

  signal closeRequested()
  signal cardClicked()
  // Prefer per-notification media/avatar data, then fall back to the app icon.
  // The `check` flag avoids Qt's missing-texture placeholder for unknown names.
  readonly property string smallIconSource: image.length > 0 ? image : iconSource(appIcon)
  readonly property bool hasGlyph: glyph.length > 0
  readonly property bool hasSmallIcon: smallIconSource.length > 0
  readonly property bool summaryStartsWithGlyph: NotificationLogic.summaryStartsWithGlyph(summary)
  readonly property bool singleLineToast: sanitizedBody.length === 0
  readonly property bool collapseRedundantIcon: singleLineToast && !hasGlyph && summaryStartsWithGlyph
  readonly property string sanitizedBody: sanitizeBody(body)
  readonly property string styledBody: NotificationLogic.styledBody(body, app, appIcon)

  readonly property bool critical: urgency === 2

  // Icon slot. As in the stock card, a glyph shows until a real icon has
  // loaded, and an icon that fails to load (a themed name the icon theme
  // lacks) shows nothing rather than Qt's broken-image placeholder.
  readonly property bool imageReady: smallIconImage.status === Image.Ready
  readonly property bool showImage: !collapseRedundantIcon && hasSmallIcon
                                    && (imageReady || (!hasGlyph && smallIconImage.status !== Image.Error))
  readonly property bool showGlyph: !collapseRedundantIcon && hasGlyph && !imageReady

  // Card padding and the gap from icon to text (brief: 12px and 10px).
  readonly property int padding: 12
  readonly property int iconGap: 10
  // App icons and images are larger than a line icon, so they stay readable.
  readonly property int imageSize: 32
  readonly property int glyphSize: 15

  // Time since the notification arrived: "now", then "2m", "1h", "3d".
  property double now: Date.now()
  readonly property string timeText: relativeTime(timestamp, now)

  function relativeTime(ts, nowMs) {
    if (!(ts > 0)) return ""
    var seconds = Math.max(0, Math.floor((nowMs - ts) / 1000))
    if (seconds < 60) return "now"
    var minutes = Math.floor(seconds / 60)
    if (minutes < 60) return minutes + "m"
    var hours = Math.floor(minutes / 60)
    if (hours < 24) return hours + "h"
    return Math.floor(hours / 24) + "d"
  }

  Timer {
    interval: 15000
    repeat: true
    running: root.visible && root.timestamp > 0
    onTriggered: root.now = Date.now()
  }

  function sanitizeBody(s) {
    return NotificationLogic.sanitizeBody(s, app, appIcon)
  }

  function iconSource(icon) {
    var value = String(icon || "")
    if (value.length === 0) return ""
    if (value.indexOf("file://") === 0 || value.indexOf("image://") === 0) return value
    if (value.charAt(0) === "/") return Util.fileUrl(value)
    return Quickshell.iconPath(value, true)
  }

  implicitWidth: Style.space(380)
  implicitHeight: content.implicitHeight + padding * 2

  // Hover lifts the card (rule 1): the lift fill fades in over 80ms.
  property real liftOpacity: root.hovered ? 1 : 0
  Behavior on liftOpacity { NumberAnimation { duration: 80; easing.type: Easing.OutCubic } }

  // Panel shadow, outside the card.
  RectangularShadow {
    anchors.fill: card
    radius: G.Tokens.radiusPanel
    offset.y: 20
    blur: 48
    color: Qt.rgba(0, 0, 0, 0.55)
  }

  Rectangle {
    id: card
    anchors.fill: parent
    radius: G.Tokens.radiusPanel
    color: G.Tokens.surface1

    Rectangle {
      anchors.fill: parent
      radius: parent.radius
      color: G.Tokens.lift
      opacity: root.liftOpacity
      visible: opacity > 0
    }

    // 1px top highlight.
    Rectangle {
      anchors { top: parent.top; left: parent.left; right: parent.right; leftMargin: G.Tokens.radiusPanel; rightMargin: G.Tokens.radiusPanel }
      height: 1
      color: G.Tokens.highlight
    }
  }

  HoverHandler { id: hoverTracker }

  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    onClicked: function(mouse) {
      if (mouse.button === Qt.RightButton) {
        root.closeRequested()
      } else {
        root.cardClicked()
      }
    }
  }

  RowLayout {
    id: content
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.margins: root.padding
    spacing: iconSlot.visible ? root.iconGap : 0

    Item {
      id: iconSlot
      Layout.alignment: Qt.AlignTop
      // A line glyph sits on the title line; an image starts at the top.
      Layout.topMargin: root.showImage ? 0 : 2
      Layout.preferredWidth: visible ? (root.showImage ? root.imageSize : root.glyphSize) : 0
      Layout.preferredHeight: visible ? (root.showImage ? root.imageSize : root.glyphSize) : 0
      visible: root.showImage || root.showGlyph

      // App icons and images keep rounded corners (no square cut).
      Item {
        anchors.fill: parent
        visible: root.showImage
        layer.enabled: true
        layer.effect: G.RoundedClip { radius: G.Tokens.radiusRow }

        Image {
          id: smallIconImage
          anchors.fill: parent
          source: root.smallIconSource
          sourceSize.width: root.imageSize * Screen.devicePixelRatio
          sourceSize.height: root.imageSize * Screen.devicePixelRatio
          fillMode: Image.PreserveAspectFit
          asynchronous: true
          smooth: true
        }
      }

      // Glyph fallback (Nerd Font character) when no image icon is
      // available. Used by omarchy-notification-send's `-g` flag.
      Text {
        textFormat: Text.PlainText
        anchors.centerIn: parent
        visible: root.showGlyph
        text: root.glyph
        color: root.critical ? G.Tokens.error : G.Tokens.accentSoft
        font.family: G.Tokens.valueFont
        font.pixelSize: root.glyphSize
      }
    }

    ColumnLayout {
      Layout.fillWidth: true
      Layout.alignment: Qt.AlignTop
      spacing: 2

      RowLayout {
        Layout.fillWidth: true
        spacing: 8

        G.Label {
          // The spec defines the summary as a single line of plain text, so
          // AutoText could only ever promote a hostile string to rich text.
          // The body below is StyledText on purpose — see Service.qml's
          // bodyMarkupSupported — and is stripped in NotificationLogic.
          Layout.fillWidth: true
          Layout.alignment: Qt.AlignBaseline
          nav: true
          text: root.summary
          color: G.Tokens.text1
          font.weight: Font.DemiBold
          wrapMode: Text.WordWrap
          maximumLineCount: 2
        }

        // Critical notifications stay until dismissed; say why.
        G.StatusText {
          Layout.alignment: Qt.AlignBaseline
          visible: root.critical
          status: "error"
          text: "urgent"
        }

        G.PanelMeta {
          Layout.alignment: Qt.AlignBaseline
          visible: root.timeText.length > 0
          text: root.timeText
        }
      }

      G.Label {
        Layout.fillWidth: true
        visible: root.sanitizedBody.length > 0
        text: root.styledBody
        textFormat: Text.StyledText
        color: G.Tokens.text3
        linkColor: G.Tokens.accentSoft
        wrapMode: Text.WordWrap
        maximumLineCount: 3
      }
    }
  }
}
