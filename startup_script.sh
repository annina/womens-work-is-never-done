#!/bin/bash
set -e

jackd -d alsa -dhw:0,0 1>/dev/null 2>/dev/null &
sleep 2
qjackctl 1>/dev/null 2>/dev/null &
sleep 1
sonic-pi 1>/dev/null 2>/dev/null &
echo "started sonic pi"
sleep 30
STR=$(jack_connect system:capture_1 SuperCollider:in_1 2>&1)
echo $STR
sleep 1
newstring=$(echo $STR | cut -c1-5)
echo $newstring
while [ "$newstring" = "Canno" ] || [ "$newstring" = "ERROR" ]; do
sleep 2
echo "another try"
STR=$(jack_connect system:capture_1 SuperCollider:in_1 2>&1)
newstring=$(echo $STR | cut -c1-5)
done
echo "done with connections"
sleep 10
cat ~/Desktop/RaspberryPiVersion/midi_script.txt | sonic_pi
exit



























