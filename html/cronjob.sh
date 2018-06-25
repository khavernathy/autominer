#!/bin/bash

x=0
sleeper=300
while true; do 

echo "running stats logger/website updater iteration "$x

cd ~/autominer/html; 
bash ~/autominer/html/updatehtml.sh
bash ~/autominer/html/log_stats.sh
python ~/autominer/html/updateplots.py


sleep $sleeper;
let x=$x+1
done
