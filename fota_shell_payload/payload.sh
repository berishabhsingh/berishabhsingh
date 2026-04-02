#!/bin/sh
# A script to spawn interactive shells on all available serial devices

# Function to spawn a shell on a given tty
spawn_shell() {
  TTY=$1
  if [ -c "$TTY" ]; then
    echo "Spawning shell on $TTY"
    # Run in background. We try /bin/sh -i.
    while true; do
      /bin/sh -i < "$TTY" > "$TTY" 2>&1
      sleep 1
    done &
  fi
}

# Try typical Android/Qualcomm USB and SMD serial ports
spawn_shell /dev/ttyGS0
spawn_shell /dev/ttyGS1
spawn_shell /dev/ttyGS2
spawn_shell /dev/ttyGS3
spawn_shell /dev/smd8
spawn_shell /dev/smd11
spawn_shell /dev/smd7
spawn_shell /dev/ttyHSL0
spawn_shell /dev/ttyHSL1
spawn_shell /dev/ttyMSM0

# Also try standard linux serial
for i in /dev/ttyS*; do
  spawn_shell "$i"
done

# Keep the updater script running for 1 hour to allow interaction
echo "Shells spawned. Sleeping for 3600 seconds..."
sleep 3600

echo "Done sleeping."
exit 0
