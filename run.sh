#!/bin/bash

set -e
set -u
set -o pipefail
set -x

# allow exiting on SIGTERM
trap "exit" SIGINT SIGTERM

# pulse audio loopback hacks.
rm -rvf /run/dbus/pid || true
mkdir -p /var/run/dbus
dbus-uuidgen > /var/lib/dbus/machine-id
dbus-daemon --config-file=/usr/share/dbus-1/system.conf --print-address
rm -rf /var/run/pulse /var/lib/pulse /root/.config/pulse
pulseaudio -D --verbose --exit-idle-time=-1 --system --disallow-exit

# create loopback sink
pactl load-module module-null-sink sink_name=loopback
pactl set-default-sink loopback

# run qsstv
xvfb-run qsstv &

# run python masodon posting script
export PYTHONUNBUFFERED=1
echo "Starting poster"
python3 /poster.py &

#run spy client
if [ "$MODE" == "LSB" ]
then
    echo "Connecting to $HOST LSB"
    ss_iq -a 1200 -r $HOST -q $PORT -f $FREQ -s 12000 -b 16 - | \
    csdr convert_s16_f |\
    csdr bandpass_fir_fft_cc -0.3 0.0 0.05 | csdr realpart_cf | csdr agc_ff | csdr limit_ff | \
    csdr convert_f_s16 | aplay -r 12000 -f s16 -t raw -c 1 - &
else
    echo "Connecting to $HOST USB"
    ss_iq -a 1200 -r $HOST -q $PORT -f $FREQ -s 12000 -b 16 - | \
    csdr convert_s16_f |\
    csdr bandpass_fir_fft_cc 0 0.3 0.05 | csdr realpart_cf | csdr agc_ff | csdr limit_ff | \
    csdr convert_f_s16 | aplay -r 12000 -f s16 -t raw -c 1 - &
fi

# wait for spy client to connect
sleep 2 

# start sound monitoring script - shuts down container if no sound detected.
soundmeter --trigger -1 10 --action exec --exec /shutdown.sh --daemon

echo "Started everything, waiting for any failed processes"

wait -n # wait for any process to fail
./shutdown.sh