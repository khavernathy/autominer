#!/bin/bash

# generates/replaces index.html with temperature data and fan speeds
head=$(mktemp)
body=$(mktemp)

# fun with colors
COLOR1="#b35656 #b36d56 #b38556 #b39c56 #b3b356 #9cb356 #85b356 #6db356 #56b356 #56b36d #56b385 #56b39c #56b3b3 #569cb3 #5685b3 #566db3 #5656b3 #6d56b3 #8556b3 #9c56b3 #b356b3 #b3569c #b35685 #b3566d #b35656"
COLOR2="#8d3f3f #8d533f #8d663f #8d793f #8d8d3f #798d3f #668d3f #538d3f #3f8d3f #3f8d53 #3f8d66 #3f8d79 #3f8d8d #3f798d #3f668d #3f538d #3f3f8d #533f8d #663f8d #793f8d #8d3f8d #8d3f79 #8d3f66 #8d3f53 #8d3f3f"
BORDER="#9900cc #cc00cc #cc0099 #cc0066 #cc0033 #cc0000 #cc0000 #cc3300 #cc6600 #cc9900 #cccc00 #99cc00 #66cc00 #33cc00 #00cc00 #00cc33 #00cc66 #00cc99 #00cccc #0099cc #0066cc #0033cc #0000cc #3300cc #6600cc"

# select the element desired (faster than cut or awk perhaps?)
HOUR=$( date +%H )
(( HOUR++ ))
COLOR1NOW=$( echo $COLOR1 | cut -d " " -f $HOUR )
COLOR2NOW=$( echo $COLOR2 | cut -d " " -f $HOUR )
BORDERNOW=$( echo $BORDER | cut -d " " -f $HOUR )

# html head
cat > $head << EOF
<html><head>
<meta http-equiv="refresh" content="60">
<style>
tr:first-child {
  color : #fff;
  /* Old browsers */
  background: $COLOR1NOW; 
  /* FF3.6-15 */
  background: -moz-linear-gradient(top, $COLOR1NOW 0%,$COLOR2NOW 100%); 
  /* Chrome10-25,Safari5.1-6 */
  background: -webkit-linear-gradient(top,  $COLOR1NOW 0%,$COLOR2NOW 100%); 
  /* W3C, IE10+, FF16+, Chrome26+, Opera12+, Safari7+ */
  background: linear-gradient(to bottom,  $COLOR1NOW 0%,$COLOR2NOW 100%); 
  /* IE6-9 */
  filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='$COLOR1NOW', endColorstr='$COLOR2NOW',GradientType=0 ); 
  -webkit-background:linear-gradient(rgb(116, 195, 80), rgb(160, 219, 132));
}

tr:first-child th{
  border-top-left-radius : 5px;
  border-top-right-radius : 5px;
  border: 2px solid $BORDERNOW;
  padding : 10px;
}
</style>
</head>
EOF


# html body
echo -n '<body>' > $body


# dump gpu data
tmp=$(mktemp)
nvidia-smi -q > $tmp


# output gpu data
echo '<table width="900"><th>' >> $body

echo "GPU Deets<hr>" >> $body
grep Product\ Name $tmp | sed 's|.*\ \([0-9][0-9]*.*\)|\1<br>|' >> $body
echo '</th><th>' >> $body

echo "GPU Use<hr>" >> $body
grep Gpu $tmp | sed -e 's|.*\ \([0-9][0-9]*\ %\).*|\1<br>|' >> $body
echo '</th><th>' >> $body

echo "Temp<hr>" >> $body
grep GPU\ Current $tmp | sed -e 's|.*\ \([0-9][0-9]*\ C\).*|\1<br>|' >> $body
echo '</th><th>' >> $body
 
echo "Fans<hr>" >> $body
grep Fan $tmp | sed -e 's|.*\ \([0-9][0-9]*\ %\).*|\1<br>|' >> $body
echo '</th><th>' >> $body

# get total power draw
POWER=$( grep Power\ Draw $tmp | sed -e 's|.*\ \([0-9][0-9]*.*\)W.*|\1|' ) 
total=$( echo $POWER | sed 's|\([0-9]\)\ \([0-9]\)|\1+\2|g' | bc)
# cost/mo based on wattage of entire system, approx GPU watts + 150W
cost=$(echo "scale=1; ("$total"+150.0)/1000.0 * 24.0 * 30.0 * 0.106" | bc -l)

echo "Power = $total W ($"$cost"/mo)<hr>" >> $body
echo $POWER | sed -e 's|\ | W<br>\n|g' -e 's|$| W<br>\n|g' >> $body
echo '</th></table>' >> $body


# add some plots 
echo '<table width="900"><th>' >> $body
echo '<p align="center"><img src="./png/Fan.png"> <img src="./png/Power.png">' >> $body
echo '<img src="./png/Temp.png"> <img src="./png/Util.png"></p>' >> $body
echo '</th></table>' >> $body

# output recently mined
echo '<table width="900"><th>Recently Mined<hr>' >> $body
grep -a mining ~/autominer/automine.log | tail -n 18 | sed -e 's|mining\ ||' -e 's|$|<br>|g' >> $body
echo "</th></table>" >> $body

# output time info
echo '<hr align="left" width="900px">' >> $body
echo '<p style="width: 900px;" align="center">Updated ' >> $body
echo "$(date)</p>" >> $body

# close tags
echo '</body></html>' >> $body


# replace index.html
cat $head $body > /var/www/html/index.html
rm $head $body
