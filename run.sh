#!/bin/bash

mkdir -p /var/run/dbus
dbus-uuidgen > /var/lib/dbus/machine-id
dbus-daemon --config-file=/usr/share/dbus-1/system.conf --print-address

rm -rf /var/run/pulse /var/lib/pulse /root/.config/pulse
pulseaudio -D --verbose --exit-idle-time=-1 --system --disallow-exit

# create loopback sink
pactl load-module module-null-sink sink_name=loopback
pactl set-default-sink loopback

xvfb-run qsstv &
export PYTHONUNBUFFERED=1
echo "Starting poster"
python3 /poster.py &

echo "Connecting to $HOST"
ss_iq -a 1200 -r $HOST -q $PORT -f $FREQ -s 12000 -b 16 - | \
csdr convert_s16_f |\
csdr bandpass_fir_fft_cc 0 0.3 0.05 | csdr realpart_cf | csdr agc_ff | csdr limit_ff | \
csdr convert_f_s16 | aplay -r 12000 -f s16 -t raw -c 1 - 
