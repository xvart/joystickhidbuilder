#!/bin/sh

set -x

if [ -n "$1" ];then
cd /sys/kernel/config/usb_gadget/$1
else
cd /sys/kernel/config/usb_gadget/mykeyboard
fi

echo "" > UDC

rm configs/c.1/*.*[0-9]

rmdir configs/c.1/strings/0x409

rmdir configs/c.1

rmdir functions/*

rmdir strings/0x409

cd ..

if [ -n $1 ];then
rmdir "$1"
else
rmdir mykeyboard
fi


