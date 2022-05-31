# echo $#
if [ -n "$1" ]
then
	case "$1" in
	d)
		if [[ $# -gt 3 ]]
		then
			usbhid-dump -m $2 -i $3 | sed '/^.*DESCRIPTOR.*$/d' | hidrd-convert -ihex -o $4
		else
			lsusb | sed '/^.* [hH]ub.*$/d' >&2
			read -p 'Select ID: ' id
			read -p 'Interface: ' num
			if [ -n "$num" ]; then
				iface="-i $num"
			fi
			echo "./script d $id $iface $2" >&2
			if [ -n "$3" ]
			then
				echo "unsigned char report[] = {" > $3
				usbhid-dump -m $id $iface | sed '/^.*DESCRIPTOR.*$/d' | hidrd-convert -ihex -o $2 >> $3
				echo "};" >> $3

cat  << EOF > writehex.c
#include <stdio.h>
#include "$3"

void main() {
        for(int i=0;i<sizeof(report);i++) {
                printf("%02X", report[i]);
        }
        printf("\n");
}
EOF
			gcc writehex.c -owritehex
			./writehex
			else
				usbhid-dump -m $id $iface | sed '/^.*DESCRIPTOR.*$/d' | hidrd-convert -ihex -o $2
			fi
		fi
	;;
	r)
		lsusb | sed '/^.* [hH]ub.*$/d' >&2
		read -p 'Select ID: ' id
		read -p 'Interface: ' num
		if [ -n "$num" ]; then
			iface="-i $num"
		fi
		echo "./script d $id $iface $2" >&2
		usbhid-dump -m $id $iface
	;;
	c)
		echo ""
		#~ hidrd-convert -ixml -ohex $2 | sed 's/[ ]//g' | tr -d '[ \n]'
		hidrd-convert -ixml -ohex $2
		echo ""
		echo ""
	;;
	h)
		hidrd-convert -ixml -ohex $2
	;;
	esac
else
	echo "No parameters found."
fi




