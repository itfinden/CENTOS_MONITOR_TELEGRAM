#!/bin/sh
# itfinden.com

ALERT=39
df -H | grep -vE '^Filesystem|tmpfs|cdrom' | awk '{ print $5 " " $1 }' | while read output;
do
 #echo $output
 usep=$(echo $output | awk '{ print $1}' | cut -d'%' -f1  )
 partition=$(echo $output | awk '{ print $2 }' )
  if [ $usep -ge $ALERT ]; then
    msg="La particion \"$partition tiene utilizado ($usep%)\" en el servidor  $(hostname)
    Estado de las particiones actualmente:
    ${NEWLINE}
    $(df -h)
    ${NEWLINE}
    Saludos Bot de monitoreo ITFINDEN =)"

    echo $msg
     #mail -s "Alerta : Una particion tiene utilizado  mas del $usep%" $(/bin/cat -- /root/friedrich/.envios)
     telegram -t 123456:AbcDefGhi-JklMnoPrw -c 12345 "Hello, World."
  fi
done
