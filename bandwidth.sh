#!/bin/bash
 
#shows traffic on the specified device
 
function human_readable {
	value=$1

   kilo=$( echo "scale=2; $value / 1000" | bc )
   kiloint=$( echo "$value / 1000" | bc )

   mega=$( echo "scale=2; $kilo / 1000" | bc )
   megaint=$( echo "$kilo / 1000" | bc )

   giga=$( echo "scale=2; $mega / 1000" | bc )
   gigaint=$( echo "$mega / 1000" | bc )

   if [ $kiloint -lt 1 ] ; then
   echo "$value bytes"
   elif [ $megaint -lt 1 ] ; then
   echo "${kilo}KB"
   elif [ $gigaint -lt 1 ] ; then
   echo "${mega}MB"
   else
   echo "${giga}GB"
   fi
}

RECEIVED=`grep $1 /proc/net/dev |  cut -d':' -f2 | awk '{print $1}' |  cut -d':' -f1 `
TRANSMITTED=`grep $1 /proc/net/dev  |  cut -d':' -f2 | awk '{print $9}'`
TOTAL=$(($RECEIVED+$TRANSMITTED))


cd /var/log/

if [ ! -d 'bandwitdh' ]; then
	mkdir bandwitdh
fi

cd bandwitdh

if [ ! -f date ]; then
	echo 0 > date
fi

if [ ! -f total ]; then
	echo 0 > total
fi

if [ ! -f old ]; then
	echo $TOTAL > old
fi

date=`cat date `
month=`date -d "$D" '+%m'`
machine=`uname -n `
oldTotal=`cat total `
oldMonth=`date +%B --date '-1 month'`

if [ $month -gt $date ]; then

	# mail de rapport
	echo "Vous avez utilise : `human_readable $oldTotal` / 2.5To sur le serveur $machine pour le mois de $oldMonth ." | mail -s "Rapport Bande passante" veka61@laposte.net

	#reset
	echo $TOTAL > old
	echo 0 > total
	echo $month > date

fi

oldTotal=`cat total `
old=`cat old `

#echo "Transmitted: `human_readable $TRANSMITTED`"
#echo "Received: `human_readable $RECEIVED`"
#echo "Total: `human_readable $TOTAL`"
#echo "oldTotal: $oldTotal"

if [ $old -gt $TOTAL ]; then
	newTotal=$(($TOTAL+$oldTotal))
else
	newTotal=$(($TOTAL-$old+$oldTotal))
fi

echo "Bande passante utilise dans le mois : `human_readable $newTotal`"

echo $TOTAL > old
echo $newTotal > total

if [ $newTotal -gt 2000000000000 ] ; then
	echo "Vous avez utilise : `human_readable $newTotal` / 2.5To Avec le serveur $machine." | mail -s "Alert Bande passante" veka61@laposte.net
fi
 
