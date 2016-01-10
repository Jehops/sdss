#!/bin/sh

## You may need to customize the sysctl command below to use variables that show
## your system's battery state and remaining life.

interval=15 # customize this
stump_pid=$(pgrep -a -n stumpwm)

# while stumpwm is still running
while kill -0 $stump_pid > /dev/null 2>&1; do
    echo $(/sbin/sysctl -n hw.acpi.battery.state \
			hw.acpi.battery.life \
		  | tr '\n' ' ')
    sleep ${interval}
done
