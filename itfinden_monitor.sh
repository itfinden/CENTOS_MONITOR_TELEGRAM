#!/bin/sh
# itfinden.com

######### Edit here ##########

Correos_Notificacion=soporte@itfinden.com
Limite_de_Correos=200 
Porcentaje_Uso_Disco=39

##############################

# EXIM INI 
clear;
Salida=”/tmp/eximqueue.txt”
Cantidad_Correos_Cola=$(exim -bpc)

if [ $Cantidad_Correos_Cola -ge $Limite_de_Correos ]; then
	
msg="
Alerta  $(hostname)

La cola de Correos tiene : $Cantidad_Correos_Cola

Sumario de Correos
$(exim -bp | exiqsumm)

Saludos Bot de monitoreo ITFINDEN =)"

sh telegram.sh  "$msg"

fi

# EXIM END


# USO DISCO 

df -H | grep -vE '^Filesystem|tmpfs|cdrom' | awk '{ print $5 " " $1 }' | while read output;
do
 #echo $output
 usep=$(echo $output | awk '{ print $1}' | cut -d'%' -f1  )
 partition=$(echo $output | awk '{ print $2 }' )
  if [ $usep -ge $Porcentaje_Uso_Disco ]; then
    msg="
Alerta  $(hostname)

La particion \"$partition tiene utilizado ($usep%)\"

Particiones actualmente:

$(df -h)

Saludos Bot de monitoreo ITFINDEN =)"

     #mail -s "Alerta : Una particion tiene utilizado  mas del $usep%" $(/bin/cat -- /root/friedrich/.envios)
     sh telegram.sh  "$msg"
  fi
done

# FIN USO DISCO 

