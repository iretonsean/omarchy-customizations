import QtQuick

// A value that follows `target` on a damped spring.
//
// The value is a pure function of the time since the last retarget: the
// closed-form step response from the position and velocity the value had
// at that moment. A retarget mid-flight keeps the velocity, so a value that
// changes target many times moves as one continuous motion.
//
// riseResponse / fallResponse pick a different response for moves up and
// down. The two edges of a highlight use them to lead and trail, so the
// highlight stretches in the direction of travel.
Item {
  id: root
  visible: false

  property real target: 0
  property real response: Tokens.moveResponse
  property real damping: Tokens.moveDamping
  property real riseResponse: -1
  property real fallResponse: -1
  // While true the value follows the target directly (a drag, or content
  // that should not glide in). Released, it springs from where it is.
  property bool instant: false

  property real value: 0
  property real velocity: 0
  readonly property bool moving: clock.running

  // Motion state at the last retarget.
  property real _start: 0
  property real _from: 0
  property real _v0: 0
  property real _to: 0
  property real _omega: 1
  property real _zeta: 1
  // Targets set while the component is still being created (the first
  // evaluation of a binding) place the value; they do not animate it.
  property bool _ready: false

  function jump(v) {
    clock.running = false
    root._to = v
    root.value = v
    root.velocity = 0
  }

  // Start from `v` and spring to the current target (a card that takes
  // over another card's place starts where that card was).
  function launchFrom(v) {
    root.jump(v)
    if (v !== root.target) root._retarget()
  }

  function _now() { return Date.now() / 1000 }

  function _retarget() {
    if (!root._ready || root.instant || Tokens.motion <= 0) {
      root.jump(root.target)
      return
    }
    var now = root._now()
    if (clock.running) root._step(now)
    var rising = root.target > root.value
    var r = rising && root.riseResponse > 0 ? root.riseResponse
          : !rising && root.fallResponse > 0 ? root.fallResponse
          : root.response
    root._start = now
    root._from = root.value
    root._v0 = root.velocity
    root._to = root.target
    root._omega = 2 * Math.PI / Math.max(0.01, r / Math.max(0.01, Tokens.motion))
    root._zeta = root.damping
    clock.running = true
  }

  function _step(now) {
    var t = Math.max(0, now - root._start)
    var w = root._omega, z = root._zeta
    var e0 = root._from - root._to, v0 = root._v0
    var e, v
    if (z >= 1) {
      var b = v0 + w * e0
      var k = Math.exp(-w * t)
      e = (e0 + b * t) * k
      v = (v0 - w * b * t) * k
    } else {
      var a = z * w
      var wd = w * Math.sqrt(1 - z * z)
      var c = Math.cos(wd * t), s = Math.sin(wd * t)
      var bb = (v0 + a * e0) / wd
      var kk = Math.exp(-a * t)
      e = kk * (e0 * c + bb * s)
      v = kk * (v0 * c + (-a * bb - wd * e0) * s)
    }
    // Settled: land exactly on the target, so a scale ends at exactly 1
    // and text is not left resampled.
    var span = Math.max(1, Math.abs(root._from - root._to))
    if (Math.abs(e) < 0.002 * span && Math.abs(v) < 0.05 * span) {
      root.jump(root._to)
      return
    }
    root.value = root._to + e
    root.velocity = v
  }

  onTargetChanged: root._retarget()
  onInstantChanged: if (root.instant) root.jump(root.target)
  Component.onCompleted: {
    root._ready = true
    if (!clock.running) root.jump(root.target)
  }

  FrameAnimation {
    id: clock
    running: false
    onTriggered: root._step(root._now())
  }
}
