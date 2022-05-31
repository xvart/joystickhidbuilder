# joystickhidbuilder
Script and tools to create HID devices on linux

# Purpose
Initially I did all this to create a hardware device so that it would remember all the crazy keybinds needed for games and be able to serve up web pages to provide access to those same keybindings.

The procedures here are also applicable to any scenario where you have an old USB device with no drivers you want to use on a system without doing the create a driver thing for Windows, MAC, Linux or anything else that has a USB host input as long as you can get the HID's you're good to go.

For this I used an [orangeopi zero](http://http://www.orangepi.org/orangepizero/) as it has an OTG port for the device along with WIFI, Ethernet and USB Host ports.

# Tools
- hidrd
- usbhid-dump
- writehex, this is a small c file that includes the .h that I create with the scripts.sh helper, the file is auto built each time

# scripts
- scripts.sh, 

# Important
When using hidrd work through code and use writehex to create the hex used in the scripts.

The hidrd conversion from XML to code/natv etc will reduce COLLECTION(Physical) 0xA1 0x00 to 0xA0 and "Logical Minimum" (0) 0x15 0x00 to 0x14, while this seems legal it will break Windows and the devices will not work. 

Linux does not have this issue.

# Workflow

In building this I found it easier to grab some real device HID's convert it to code with hidrd and remix throwing out what made no sense and inserting the extra things I wanted.

To grab a HID I use scripts.sh to simplify my work it boils down to replacing the following,
- ##### usbhid-dump -m 1d6b:6969 -i 0 | sed '/^.*DESCRIPTOR.*$/d' | hidrd-convert -ihex -o code > report.h
with,
- ##### ./scripts d code report.h
and entering the bits needed when asked.

The hidrd "code" output is fully commented so you can just move stuff around as needed without fighting with the details.

#### Dual Gamepad Dump
A typical report in ```report.h``` produced with ```./scripts d code report.h``` 
```
unsigned char report[] = {
0x05, 0x01, /*  Usage Page (Desktop),           */
0x09, 0x05, /*  Usage (Gamepad),                */
0xA1, 0x01, /*  Collection (Application),       */
0xA1, 0x00, /*      Collection (Physical),      */
0x85, 0x01, /*          Report ID (1),          */
0x05, 0x09, /*          Usage Page (Button),    */
0x19, 0x01, /*          Usage Minimum (01h),    */
0x29, 0x10, /*          Usage Maximum (10h),    */
0x15, 0x00, /*          Logical Minimum (0),    */
0x25, 0x01, /*          Logical Maximum (1),    */
0x95, 0x10, /*          Report Count (16),      */
0x75, 0x01, /*          Report Size (1),        */
0x81, 0x02, /*          Input (Variable),       */
0x05, 0x01, /*          Usage Page (Desktop),   */
0x09, 0x30, /*          Usage (X),              */
0x09, 0x31, /*          Usage (Y),              */
0x09, 0x32, /*          Usage (Z),              */
0x09, 0x33, /*          Usage (Rx),             */
0x15, 0x81, /*          Logical Minimum (-127), */
0x25, 0x7F, /*          Logical Maximum (127),  */
0x75, 0x08, /*          Report Size (8),        */
0x95, 0x04, /*          Report Count (4),       */
0x81, 0x02, /*          Input (Variable),       */
0xC0,       /*      End Collection,             */
0xC0,       /*  End Collection,                 */
0x05, 0x01, /*  Usage Page (Desktop),           */
0x09, 0x05, /*  Usage (Gamepad),                */
0xA1, 0x01, /*  Collection (Application),       */
0xA1, 0x00, /*      Collection (Physical),      */
0x85, 0x02, /*          Report ID (2),          */
0x05, 0x09, /*          Usage Page (Button),    */
0x19, 0x01, /*          Usage Minimum (01h),    */
0x29, 0x10, /*          Usage Maximum (10h),    */
0x15, 0x00, /*          Logical Minimum (0),    */
0x25, 0x01, /*          Logical Maximum (1),    */
0x95, 0x10, /*          Report Count (16),      */
0x75, 0x01, /*          Report Size (1),        */
0x81, 0x02, /*          Input (Variable),       */
0x05, 0x01, /*          Usage Page (Desktop),   */
0x09, 0x30, /*          Usage (X),              */
0x09, 0x31, /*          Usage (Y),              */
0x09, 0x32, /*          Usage (Z),              */
0x09, 0x33, /*          Usage (Rx),             */
0x15, 0x81, /*          Logical Minimum (-127), */
0x25, 0x7F, /*          Logical Maximum (127),  */
0x75, 0x08, /*          Report Size (8),        */
0x95, 0x04, /*          Report Count (4),       */
0x81, 0x02, /*          Input (Variable),       */
0xC0,       /*      End Collection,             */
0xC0        /*  End Collection                  */
};
```

- The keyboard I had to create from scratch as keyboard HID's are a jumble of strange fragments smashed together.
- The mouse is a remix of two different mice.
- The joystick is a remix of Teensy extreme a gamepad HID and a joystick I have, again commercial joysticks and gamepads are a jumble of weird blocks smashed together with no seeming order or purpose.

