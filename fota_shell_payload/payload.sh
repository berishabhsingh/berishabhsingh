#!/bin/sh
# A script to spawn interactive shells on all available serial devices

# Attempt to remount root and system partitions as read-write
mount -o remount,rw / 2>/dev/null || true
mount -o remount,rw /system 2>/dev/null || true

# Function to spawn a shell on a given tty
spawn_shell() {
  TTY=$1
  if [ -c "$TTY" ]; then
    echo "Spawning shell on $TTY"
    # Run in background. We try /bin/sh -i.
    (
      while true; do
        /bin/sh -i < "$TTY" > "$TTY" 2>&1
        EXIT_CODE=$?
        if [ "$EXIT_CODE" -eq 99 ]; then
          echo "Exit code 99 received. Breaking loop and terminating sleep." > "$TTY"
          # Kill the sleep process to resume normal boot
          if [ -f /tmp/payload_sleep.pid ]; then
            kill -9 $(cat /tmp/payload_sleep.pid) 2>/dev/null || true
          fi
          break
        fi
        sleep 1
      done
    ) &
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
sleep 3600 &
SLEEP_PID=$!
echo $SLEEP_PID > /tmp/payload_sleep.pid
wait $SLEEP_PID

echo "Done sleeping."
exit 0
