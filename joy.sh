#!/bin/bash

set -x

# Create gadget
if [ -n "$1" ]; then
mkdir /sys/kernel/config/usb_gadget/$1
cd /sys/kernel/config/usb_gadget/$1
else
mkdir /sys/kernel/config/usb_gadget/mykeyboard
cd /sys/kernel/config/usb_gadget/mykeyboard
fi

# Add Device Descriptor information
echo 0x0100 > bcdDevice # Version 1.0.0
echo 0x0200 > bcdUSB # USB 2.0
echo 0x00 > bDeviceClass
echo 0x00 > bDeviceProtocol
echo 0x00 > bDeviceSubClass
echo 0x40 > bMaxPacketSize0
echo 0x6969 > idProduct # Keyboard Joystick Composite Gadget
echo 0x1d6b > idVendor # Linux Foundation

# Create English locale
mkdir strings/0x409

echo "Languid" > strings/0x409/manufacturer
echo "keyboard, joystick, dual gamepad"> strings/0x409/product
echo "0123456789" > strings/0x409/serialnumber

# Create configuration descriptor
mkdir configs/c.1
mkdir configs/c.1/strings/0x409

echo 0x80 > configs/c.1/bmAttributes
echo 200 > configs/c.1/MaxPower # 200 mA
# echo 0 > configs/c.1/iConfiguration
echo "Composite configuration" > configs/c.1/strings/0x409/configuration

# Create HID endpoints
INDEX=0

# Create keyboard
keyboard() {
if [ -z "$3" ]; then
        echo "Not enough fields in call"
        exit
fi
# Create interface descriptor information
FN="functions/hid.kb$1"
mkdir $FN
echo 1 > $FN/protocol
echo $2 > $FN/report_length # 9-byte reports
echo 0 > $FN/subclass
# Write report descriptor, keyboard 2 parts ID:1,2
echo $3 | xxd -r -ps > $FN/report_desc
ln -s $FN configs/c.1
}

# Create extreme joystick
joystick() {
if [ -z "$3" ]; then
        echo "Not enough fields in call"
        exit
fi
# Create interface descriptor information
FN="functions/hid.js$1"
mkdir $FN
echo 0 > $FN/protocol
echo $2 > $FN/report_length # 12-byte reports
echo 0 > $FN/subclass
# Write report descriptor, stolen from teensy forum extreme joystick
# Write 64 bytes to the following endpoint in the same order as listed
# buttons 64 so 64/8 = 8 bytes
# axis and sliders 12 for x,y,z,R(x),R(y),R(z),Slider*6 so 12*2 = 24 bytes
# hats 4 so 4*.5 = 2 bytes
echo $3 | xxd -r -ps > $FN/report_desc
ln -s $FN configs/c.1
}

# Create dual gamepad, index by "Report ID"
gamepad() {
if [ -z "$3" ]; then
        echo "Not enough fields in call"
        exit
fi
# Create interface descriptor information
FN="functions/hid.gp$1"
mkdir $FN
echo 0 > $FN/protocol
echo $2 > $FN/report_length # 9-byte reports
echo 0 > $FN/subclass
# Format..
echo $3 | xxd -r -ps > $FN/report_desc
ln -s $FN configs/c.1
}

# Normal joystick with throttle thing, use 2 for dual joystck plane thing
JOYHID="05010904A1011500250175019510050919012910810205010901A10016018026FF7F0930093109320933751095038102C0A100150026FF0009360936750895028102C0150025073500463B01750495046514050109390939093909398142C0"

# The big joystick
JOYBIG="05010904a1011500250175019540050919012940810205010901a100150027ffff00007510951009300931093209330934093509360936093609360936093609360936093609368102c0150025073500463b01750495046514050109390939093909398142c0"

JOYCOMP="05010904A10185011500250175019510050919012910810205010901A10016018026FF7F0930093109320933751095038102C0A100150026FF0009360936750895028102C0150025073500463B01750495046514050109390939093909398142C005010904A10185021500250175019510050919012910810205010901A10016018026FF7F0930093109320933751095038102C0A100150026FF0009360936750895028102C0150025073500463B01750495046514050109390939093909398142C005010904A10185031500250175019540050919012940810205010901A100150027FFFF00007510951009300931093209330934093509360936093609360936093609360936093609368102C0150025073500463B01750495046514050109390939093909398142C0"

# Link HID function to configuration
keyboard $INDEX 9 "05010906A10105078501193C29651425017501952A810219672973950D8102750195098101C005010906A1010507850219E029E71425017501950881021904293B14250175019538810205081901290314250175019503910295059101C0"
INDEX=$(($INDEX + 1))
joystick $INDEX 42 $JOYCOMP # Joystick
INDEX=$(($INDEX + 1))
joystick $INDEX 8 $JOYHID
INDEX=$(($INDEX + 1))
# Stolen from some guys tutorial on
# doing composite report ID thing, microsoft shows both devices
gamepad $INDEX 9 "05010905A101A100850105091901291015002501951075018102050109300931093209331581257F750895048102C0C005010905A101A100850205091901291015002501951075018102050109300931093209331581257F750895048102C0C0"

# Enable gadget
ls /sys/class/udc > UDC
