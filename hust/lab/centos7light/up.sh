#!/bin/bash
#调亮
f [ ! -w /sys/class/backlight/intel_backlight/brightness ];then
    echo "password" | sudo -S chmod 777 /sys/class/backlight/intel_backlight/brightness
fi

read bright < '/sys/class/backlight/intel_backlight/brightness'

v=600
v=$((4882 / 20 + $bright))

if [ $v -gt 4882 ]; then
    v=4882
fi

echo $v | tee /sys/class/backlight/intel_backlight/brightness