#!/bin/bash
# Copyright (c) 2018 Felix Almeida (white-glider)
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

umask 077
IPC=${XDG_RUNTIME_DIR:-/tmp}/numlock-notifier
LOCK=${IPC}.lock
GSET_PID=0

function tidy_up {
	[ $GSET_PID -ne 0 ] && kill $GSET_PID
	[ -p $IPC ] && rm -f $IPC
	[ -f $LOCK ] && rm -f $LOCK
}

[ "$_FLOCKER" != "$LOCK" ] && exec env _FLOCKER="$LOCK" flock -en "$LOCK" "$0"
trap "tidy_up 2>/dev/null" EXIT

mkfifo $IPC 2>/dev/null
gsettings monitor org.gnome.settings-daemon.peripherals.keyboard numlock-state > $IPC &
GSET_PID=$!
while read status < $IPC; do
	MSG=$(echo $status | awk '{split($2, p, "'\''"); print toupper(p[2])}')
	notify-send -u low -c device -i /usr/share/icons/Adwaita/scalable/devices/input-keyboard-symbolic.svg "NumLock" "<b>$MSG</b>"
done
