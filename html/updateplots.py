#!/usr/bin/python

import matplotlib as mpl
mpl.use('Agg') #no graphics
import matplotlib.pyplot as plt
import csv
import numpy as np
from pytz import timezone

src_dir = '/home/spacegpurig/autominer/html/'
plot_dir = '/var/www/html/png/'

def init_plt(w=4.2, h=2):
  figgabx, ax = plt.subplots()
  figgabx.set_size_inches(w,h)
  plt.tight_layout()
  plt.tick_params(axis='x', which='major', labelsize=6, rotation=17)
  plt.tick_params(axis='y', which='major', labelsize=6)
  plt.subplots_adjust(left=0.07, right=0.98, top=0.93, bottom=0.15)
  
  return figgabx, ax

if __name__ == '__main__':

  logFiles = ['logs_time/log.fan.csv', 'logs_time/log.power.csv', 'logs_time/log.temp.csv', 'logs_time/log.util.csv']
  labels = ['Fan', 'Power', 'Temp', 'Util']
  xvals = {}
  yvals = {}

  # loop thru logfiles
  for logFile, label in zip(logFiles, labels):
    # init dictionary for this label
    xvals[label] = []
    yvals[label] = [] 
    # read csv
    with open(src_dir + logFile, 'rb') as csvfile:
      reads = csv.reader(csvfile)
      for row in reads:
        xvals[label].append(int(row[0]))
        yvals[label].append([float(x) for x in row[1:]])

  # plot
  figgabx, ax = init_plt()

  for label in labels:
    leg_label = [range(len(yvals[label][0]))] #plain numeric legend
    xdates = mpl.dates.epoch2num(xvals[label])
    ax.plot_date(xdates, yvals[label], linestyle='solid', marker='None', tz=timezone('US/Eastern'))
    ax.legend(range(len(yvals[label])), loc=3, fontsize=5)
    plt.suptitle(label, fontsize=7)
    plt.grid(axis = 'both')
    plt.savefig(plot_dir + label + '.png')
    plt.cla()
    

