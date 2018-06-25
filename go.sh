#!/bin/bash

# enable fan control
sudo nvidia-xconfig --enable-all-gpus
sudo nvidia-xconfig --cool-bits=4

# turn on fans
# todo (without killing x server)

# start monitoring temp/power use etc.
cd ~/autominer/html
rm logs_time/*
bash cronjob.sh &
cd ..


# first undervolt
sudo nvidia-smi -pm 1

sudo nvidia-smi -i 0 -pl 38   # 750Ti            55%
sudo nvidia-smi -i 1 -pl 300  # 1080Ti           80%
sudo nvidia-smi -i 2 -pl 170  # 1080 zotac       90%
sudo nvidia-smi -i 3 -pl 170  # 1070Ti cerberus  80%
sudo nvidia-smi -i 4 -pl 130  # 1070Ti mini      90%


python mine.py
