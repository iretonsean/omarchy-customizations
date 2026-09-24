#!/bin/bash
# System changes for the trackpad. Needs sudo; install.sh runs it too.
#
# - Scroll momentum in Chromium and Electron apps (~/.local/bin/trackpad-momentum)
#   reads the trackpad and creates a virtual scroll wheel. That needs the
#   "input" group and access to /dev/uinput.
# - The T2 MacBook's keyboard and trackpad are labelled "external", so
#   libinput never pauses the trackpad while you type. A udev rule labels
#   them built in.
#
# Log out and in once afterwards, so the input group takes effect.
set -e
sudo usermod -aG input "$USER"
echo 'KERNEL=="uinput", GROUP="input", MODE="0660", OPTIONS+="static_node=uinput"' |
  sudo tee /etc/udev/rules.d/60-uinput.rules >/dev/null
echo uinput | sudo tee /etc/modules-load.d/uinput.conf >/dev/null
echo 'ACTION=="add|change", SUBSYSTEM=="input", ATTRS{idVendor}=="05ac", ATTRS{idProduct}=="027c", ENV{ID_INTEGRATION}="internal", ENV{ID_INPUT_TOUCHPAD_INTEGRATION}="internal"' |
  sudo tee /etc/udev/rules.d/61-apple-t2-internal-input.rules >/dev/null
sudo modprobe uinput
sudo udevadm control --reload
sudo udevadm trigger --subsystem-match=input --subsystem-match=misc
systemctl --user daemon-reload
systemctl --user enable trackpad-momentum.service >/dev/null 2>&1
echo "Log out and in once, so the input group takes effect."

