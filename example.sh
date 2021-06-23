#!/usr/bin/bash

# SHELL PARA EJECUCION DEL PROGRAMA NATURAL WPINACTI
# DESACTIVACION DEL PROCESO TARIFICACION OPTIMIZADA

# salida=/opt/salida
# WPINACTI.sh

#Codigo Para Desactivacion Masiva de Procesos
act=$(cat /opt/sisve/Shell/check.lst)
if test "$act" -eq 0
then
    exit
fi

#Estadisticas
bi=`date +%d/%m/%Y`
di=`date +"%H:%M:%S"`
##########

PRG=WPINACTI
fch=`date +%Y%m%d_%H%M%S`

. /home/sisve/.profile > /dev/null
a=`ls /opt/sisve/demonio/lockfile/$PRG.log`
if test "$a" = ""
then
    touch /opt/sisve/demonio/lockfile/$PRG.log
    cmsynin=/opt/salida/$PRG-cmd-$fch.txt            # Comando
    cmobjin=/opt/salida/$PRG-input-$fch.txt          # Data para el PRGrama / input
    cmprint=/opt/salida/$PRG-output-$fch.txt         # Salida
    cmprt01=/opt/salida/$PRG-report1-$fch.txt
    export WRKF1=/opt/salida/$PRG_WF1.txt  # As defined in natparm
    export WRKF3=/opt/salida/$PRG_WF3.txt  # As defined in natparm
    export WRKF4=/opt/salida/$PRG_WF4.txt
    CMWRK01=/opt/salida/$PRG-wrk01-$fch.txt
    salida=/opt/salida/$PRG-out-$fch.txt

    #Libreria Natural
    lib=BATCH

    echo "====================================================" > $salida
    echo "$PRG Fecha: $fch                     "    >> $salida
    echo "cmsynin=/opt/salida/$PRG-cmd-$fch.txt"    >> $salida
    echo "cmobjin=/opt/salida/$PRG-input-$fch.txt"  >> $salida
    echo "cmprint=/opt/salida/$PRG-output-$fch.txt" >> $salida
    echo "cmprt01=/opt/salida/$PRG-report1-$fch.txt" >> $salida
    echo "CMWRK01=/opt/salida/$PRG-wrk01-$fch.txt"  >> $salida
    echo "====================================================" >> $salida

    echo  "LOGON $lib\n$PRG \nFIN" > $cmsynin

    # cuando Shell se ejecuta con parametros asignarlo a la variable cmobjin
    echo  " \n" > $cmobjin

    natural batchmode bp=$BPAPP parm=$BATCHAPP etid=$$ cc=on cmsynin=$cmsynin cmobjin=$cmobjin CMPRT01=$cmprt01 cmprint=$cmprint CMWRK01=$CMWRK01 NATLOG=ERR
    rc=$?
    rm /opt/sisve/demonio/lockfile/$PRG.log
else
    exit
fi

#Tiempos de ejecucion
bo=`date +%d/%m/%Y`
do=`date +"%H:%M:%S"`

#Log registro de ejecucion Shell
echo "$bi $di|$0|$$|$*|$rc|`whoami`|$bo $do" >> /opt/sisve/Shell/estadisticas.log

sh /opt/sisve/Shell/Estadisticas/stdfin.sh $$ $0 $rc
sh /opt/sisve/Shell/monitoreo/alersalida-mod.sh $0 $cmprint $cmobjin

if $rc -ne 0
then
    #Envio de correo
    sh /opt/sag/Shell/sendMail.sh carlos.miranda@softwareag.com carlos.miranda.ortega@gmail.com "TARIFICACION - Shell WPINACTI - ERROR" "Finalizacion de Shell con RC=$rc \n \nFAVOR REVISAR Y EJECUTAR MANUALMENTE \n \n -------Directorio-------- \n/opt/sisve/demonio/WPINACTI.sh \n \n -------PROGRAMA NATURAL-------- \n$PRG"
else
    exit
fi
