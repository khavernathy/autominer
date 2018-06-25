#!/bin/bash

cd ~/autominer/html

tmp=$( mktemp )
nvidia-smi -q > $tmp

#GPU Utilization
USE=$( grep Gpu $tmp | sed -e 's|.*\ \([0-9][0-9]*\).*|\1|' | tr '\n' ',' | sed 's|,$|\n|' )

#Temperature
TEMP=$( grep GPU\ Current $tmp | sed -e 's|.*\ \([0-9][0-9]*\).*|\1|' | tr '\n' ',' | sed 's|,$|\n|' )
 
#Fan Speed
FAN=$( grep Fan $tmp | sed -e 's|.*\ \([0-9][0-9]*\).*|\1|' | tr '\n' ',' | sed 's|,$|\n|' )

#Power Draw
PWER=$( grep Power\ Draw $tmp | sed -e 's|.*\ \([0-9][0-9]*\).*|\1|' | tr '\n' ',' | sed 's|,$|\n|' )

TIME=$( date +%s )
echo "$TIME,$USE" >> logs_time/log.util.csv
echo "$TIME,$FAN" >> logs_time/log.fan.csv
echo "$TIME,$TEMP" >> logs_time/log.temp.csv
echo "$TIME,$PWER" >> logs_time/log.power.csv

#rotate logs

for i in logs_time/log.util.csv logs_time/log.temp.csv logs_time/log.fan.csv logs_time/log.power.csv; do
  tail -n 600 $i > $tmp
  cp $tmp $i
done

rm $tmp
