#!/bin/bash
# System changes for the trackpad. Needs sudo; install.sh runs it too.
#
# - Scroll momentum in apps without their own (~/.local/bin/trackpad-momentum)
#   reads the trackpad and creates a virtual scroll wheel. That needs the
#   "input" group and access to /dev/uinput.
# - The T2 MacBook's keyboard and trackpad are labelled "external", so
#   libinput never pauses the trackpad while you type. A udev rule labels
#   them built in.
# - libinput ignores palms on the trackpad (a measured palm-size limit).
#
# Restart the computer once afterwards, so the input group takes effect.
set -e
sudo usermod -aG input "$USER"
echo 'KERNEL=="uinput", GROUP="input", MODE="0660", OPTIONS+="static_node=uinput"' |
  sudo tee /etc/udev/rules.d/60-uinput.rules >/dev/null
echo uinput | sudo tee /etc/modules-load.d/uinput.conf >/dev/null
# Numbered 71 so it runs after 65-integration.rules and 70-touchpad.rules,
# which set these values too.
sudo rm -f /etc/udev/rules.d/61-apple-t2-internal-input.rules
echo 'ACTION=="add|change", SUBSYSTEM=="input", ATTRS{idVendor}=="05ac", ATTRS{idProduct}=="027c", ENV{ID_INTEGRATION}="internal", ENV{ID_INPUT_TOUCHPAD_INTEGRATION}="internal"' |
  sudo tee /etc/udev/rules.d/71-apple-t2-internal-input.rules >/dev/null
# Palm limit for this trackpad, measured with ~/.local/bin/trackpad-measure:
# fingers and thumb clicks reach 576, resting palms start at 1264. libinput's
# general Apple value (1600) is for other models. Pressure does not separate
# them (a firm click presses harder than a palm), so it is not set.
sudo mkdir -p /etc/libinput
sudo tee /etc/libinput/local-overrides.quirks >/dev/null <<'QUIRKS'
[Apple T2 MacBook trackpad palm size]
MatchUdevType=touchpad
MatchBus=usb
MatchVendor=0x05AC
MatchProduct=0x027C
AttrPalmSizeThreshold=1000
QUIRKS
sudo modprobe uinput
sudo udevadm control --reload
sudo udevadm trigger --subsystem-match=input --subsystem-match=misc
systemctl --user daemon-reload
systemctl --user enable trackpad-momentum.service >/dev/null 2>&1
echo "Restart the computer once, so the input group takes effect. (Your account keeps its"
echo "user services running after log-out, so logging out is not enough.)"

