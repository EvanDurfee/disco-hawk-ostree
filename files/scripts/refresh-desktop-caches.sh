#!/usr/bin/env bash

# Rebuild caches that RPM scriptlets would normally update, for files added
# outside of dnf (e.g. the ghostty copy). ostree zeroes mtimes, so GTK can't
# tell a stale icon cache apart from a current one.
set -oue pipefail

gtk-update-icon-cache --force --ignore-theme-index /usr/share/icons/hicolor
update-desktop-database /usr/share/applications
