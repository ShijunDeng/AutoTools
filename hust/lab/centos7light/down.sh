#!/bin/bash
#调黯
if [ ! -w /sys/class/backlight/intel_backlight/brightness ];then
    echo "password" | sudo -S chmod 777 /sys/class/backlight/intel_backlight/brightness
fi

read bright < '/sys/class/backlight/intel_backlight/brightness'

v=600
v=$(($bright - 4882 / 9 ))

echo $v | tee /sys/class/backlight/intel_backlight/brightness