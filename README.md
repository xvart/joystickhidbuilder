# joystickhidbuilder
Script and tools to create HID devices on linux

# Tools
hidrd
usbhid-dump
writehex

# scripts
csripts.sh

# Important
When using hidrd work through code and use writehex to create the hex used in the scripts.

The hidrd conversion from XML to code/natv etc will reduce COLLECTION(Physical) 0xA1 0x00 to 0xA0 and "Logical Minimum" (0) 0x15 0x00 to 0x14, while this seems legal it will break Windows and the devices will not work. 

Linux does not have this issue.

# Workflow
To grab a HID I use scripts.sh to simplify my work it boils down to replacing,
"usbhid-dump -m 1d6b:6969 -i 0 | sed '/^.*DESCRIPTOR.*$/d' | hidrd-convert -ihex -o code"
with,
"./scripts d code"
and entering the bits needed when asked.


hidrd produces a code output that is fully commented so you can just move stuff around as needed.

In building this I found it easier to grab some real device HID's convert it to code with hidrd and remix throwing out what made no sense and inserting the rest. 


The keyboard I had to create from scratch as keyboard HID's are a jumble of strange fragments smashed together.
The mouse is a remix.
The joystick is a remix of Teensy extreme a gamepad HID and a joystick I have, again commercial joysticks and gamepads are a jumble of weird blocks smashed together in no seeming order.

