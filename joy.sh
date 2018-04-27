#!/bin/bash

set -x

function checkModule(){
  MODULE="$1"
  if lsmod | grep "$MODULE" &> /dev/null ; then
    echo "$MODULE" found.
    return 0
  else
    echo "$MODULE" not found.
    return 1
  fi
}

if which 'systemctl' | grep "systemctl" &> /dev/null ; then
 systemctl stop serial-getty@ttyGS0.service >/dev/null
fi

if checkModule "g_serial" == 0; then
  modprobe -r g_serial
fi

if checkModule "usb_f_acm" == 0; then
  modprobe -r usb_f_acm
fi

if ! checkModule "g_multi" == 0; then
  modprobe -r g_multi
fi

if ! checkModule "libcomposite" == 0; then
    modprobe -r libcomposite
    modprobe libcomposite
fi

cd /sys/kernel/config/usb_gadget/

if [ -d joystick ]; then
    echo “” > /config/usb_gadget/g1/UDC #Disable the Gadget
    rm joystick/configs/c.1/hid.xyz #Unlink Function from Configuration
    rmdir joystick/configs/c.1/strings/0x409 #Remove Configuration Strings
    rmdir joystick/configs/c.1/strings
    rmdir joystick/configs/c.1/ #Remove Configuration
    rmdir joystick/functions/hid.xyz #Remove Function
    rmdir joystick/strings/0x409 #Remove Gadget Strings
    rmdir joystick/strings
    rmdir joystick #Remove Gadget
    # umount /config
fi

mkdir -p joystick
cd joystick
echo 0x1d6b > idVendor # Linux Foundation
echo 0x0104 > idProduct # Multifunction Composite Gadget
echo 0x0100 > bcdDevice # v1.0.0
echo 0x0200 > bcdUSB # USB2
mkdir -p strings/0x409
echo "1337" > strings/0x409/serialnumber
echo "languid" > strings/0x409/manufacturer
echo "Joystick USB Device" > strings/0x409/product
mkdir -p configs/c.1/strings/0x409
echo "Config 1: ECM network" > configs/c.1/strings/0x409/configuration
echo 250 > configs/c.1/MaxPower

# Add functions here
pwd
# xyz becayse it's a pointer thing
mkdir -p functions/hid.xyz
echo 1 > functions/hid.xyz/protocol
echo 1 > functions/hid.xyz/subclass
echo 8 > functions/hid.xyz/report_length

# echo -ne \\x05\\x01\\x09\\x04\\xA1\\x01\\x15\\x00\\x25\\x01\\x75\\x01\\x95\\x20\\x05\\x09\\x19\\x01\\x29\\x20\\x81\\x02\\x15\\x00\\x25\\x07\\x35\\x00\\x46\\x3B\\x01\\x75\\x04\\x95\\x04\\x65\\x14\\x05\\x01\\x09\\x39\\x09\\x39\\x09\\x39\\x09\\x39\\x81\\x42\\x05\\x01\\x09\\x01\\xA1\\x00\\x15\\x00\\x27\\xFF\\xFF\\x00\\x00\\x75\\x10\\x95\\x08\\x09\\x30\\x09\\x31\\x09\\x32\\x09\\x33\\x09\\x34\\x09\\x35\\x09\\x36\\x09\\x36\\x81\\x02\\xC0\\xC0 > functions/hid.xyz/report_desc
# hidrd-convert -i xml /home/marian/joyhid.xml -o natv /sys/kernel/config/usb_gadget/joystick/functions/hid.xyz/report_desc

cat <<EOF | hidrd-convert -i xml -o natv > /sys/kernel/config/usb_gadget/joystick/functions/hid.xyz/report_desc
<?xml version="1.0"?>
<descriptor xmlns="http://digimend.sourceforge.net" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://digimend.sourceforge.net hidrd.xsd">
<usage_page>desktop<!-- Generic desktop controls (01h) --></usage_page>
<usage>desktop_joystick<!-- Joystik (04h, application collection) --></usage>
<COLLECTION type="application">
<logical_minimum>0</logical_minimum>
<logical_maximum>1</logical_maximum>
<report_size>1</report_size>
<report_count>64</report_count>
<usage_page>button<!-- Button (09h) --></usage_page>
<usage_minimum>01</usage_minimum>
<usage_maximum>40</usage_maximum>
<input>
<variable/>
</input>
<logical_minimum>0</logical_minimum>
<logical_maximum>7</logical_maximum>
<physical_minimum>0</physical_minimum>
<physical_maximum>315</physical_maximum>
<report_size>4</report_size>
<report_count>4</report_count>
<unit>
<english_rotation>
<degrees/>
</english_rotation>
</unit>
<usage_page>desktop<!-- Generic desktop controls (01h) --></usage_page>
<usage>desktop_hat_switch<!-- Hat switch (39h, dynamic value) --></usage>
<usage>desktop_hat_switch<!-- Hat switch (39h, dynamic value) --></usage>
<usage>desktop_hat_switch<!-- Hat switch (39h, dynamic value) --></usage>
<usage>desktop_hat_switch<!-- Hat switch (39h, dynamic value) --></usage>
<input>
<variable/>
<null_state/>
</input>
<usage_page>desktop<!-- Generic desktop controls (01h) --></usage_page>
<usage>desktop_pointer<!-- Pointer (01h, physical collection) --></usage>
<COLLECTION type="physical">
<logical_minimum>0</logical_minimum>
<logical_maximum>65535</logical_maximum>
<report_size>16</report_size>
<report_count>10</report_count>
<usage>desktop_x<!-- X (30h, dynamic value) --></usage>
<usage>desktop_y<!-- Y (31h, dynamic value) --></usage>
<usage>desktop_z<!-- Z (32h, dynamic value) --></usage>
<usage>desktop_rx<!-- Rx (33h, dynamic value) --></usage>
<usage>desktop_ry<!-- Ry (34h, dynamic value) --></usage>
<usage>desktop_rz<!-- Rz (35h, dynamic value) --></usage>
<usage>desktop_slider<!-- Slider (36h, dynamic value) --></usage>
<usage>desktop_slider<!-- Slider (36h, dynamic value) --></usage>
<usage>desktop_slider<!-- Slider (36h, dynamic value) --></usage>
<usage>desktop_slider<!-- Slider (36h, dynamic value) --></usage>
<input>
<variable/>
</input>
</COLLECTION>
</COLLECTION>
</descriptor>
EOF
#hidrd-convert -o natv /sys/kernel/config/usb_gadget/joystick/functions/hid.xyz/report_desc -i xml

ln -s functions/hid.xyz configs/c.1/
# End functions
ls /sys/class/udc > UDC
