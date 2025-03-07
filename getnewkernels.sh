#!/bin/bash
#set -x
#curl -s https://lists.suse.com/pipermail/sle-updates/2024-July/thread.html|grep -i kernel|grep -v "Live Patch"|grep -v firmware

#curl -s https://lists.suse.com/pipermail/sle-updates/2024-July/thread.html|grep -i kernel|grep -v "Live Patch"|grep -v firmware|awk -F\" '{print $2}'
#https://lists.suse.com/pipermail/sle-updates/2024-July/035872.html
#curl -s https://lists.suse.com/pipermail/sle-updates/2024-July/035874.html

#currentmonth=$(date)
# date '+%B'
#July
# date '+%Y'
#2024

dyear=$(date '+%Y')
dmonth=$(date '+%B')
dnano=$(date +%N)
#dmonth=May
if [ ! -f /srv/www/htdocs/kernellist/$dyear-$dmonth.html ]
then
touch /srv/www/htdocs/kernellist/$dyear-$dmonth.html
echo "<br><a href="http://192.168.0.46/kernellist/"> Home</a><br><br><br>" >> /srv/www/htdocs/kernellist/$dyear-$dmonth.html
cp /srv/www/htdocs/kernellist/$dyear-$dmonth.html /tmp/$dyear-$dmonth.html-$dnano
else
mv /srv/www/htdocs/kernellist/$dyear-$dmonth.html /tmp/$dyear-$dmonth.html-$dnano
echo "<br><a href="http://192.168.0.46/kernellist/"> Home</a><br>" >> /srv/www/htdocs/kernellist/$dyear-$dmonth.html
fi

#rm /srv/www/htdocs/kernellist/$dyear-$dmonth.html
for i in $(curl -s https://lists.suse.com/pipermail/sle-updates/$dyear-$dmonth/thread.html|grep -i kernel|grep -v "Live Patch"|grep -v firmware|awk -F\" '{print $2}')
do
curl -s https://lists.suse.com/pipermail/sle-updates/$dyear-$dmonth/$i -o /tmp/$i
#DEBUGOUTPUT-uncomment the echo below
#echo "list thread ID: "$i
#	echo $i #uncomment to check the list of threads fount
ccount=$( awk '/SUSE Linux Enterprise Server [0-9]/ { ver=$0 } /kernel-default-[0-9]/ { print ver "\n" $0 }' < /tmp/$i |head -n2|wc -l)

#DEBUGOUTPUT-uncomment the echo below
#echo "number of threads found: "$ccount
#awk '/SUSE Linux Enterprise Server [0-9]/ { ver=$0 } /kernel-default-[0-9]/ { print ver "\n" $0 }' < /tmp/$i |head -n2|wc -l

if [ "$ccount" -eq "2" ]
then
#	echo $ccount #uncomment to check the count of found files.
	echo "<a href="https://lists.suse.com/pipermail/sle-updates/$dyear-$dmonth/$i"> $dyear-$dmonth-$i</a>" >> /srv/www/htdocs/kernellist/$dyear-$dmonth.html
	echo "<br>" >> /srv/www/htdocs/kernellist/$dyear-$dmonth.html
	echo "<b>" >> /srv/www/htdocs/kernellist/$dyear-$dmonth.html
	awk '/SUSE Linux Enterprise Server [0-9]/ { ver=$0 } /kernel-default-[0-9]/ { print ver "<br>\n" $0 }' < /tmp/$i |head -n2 >> /srv/www/htdocs/kernellist/$dyear-$dmonth.html
	echo "</b>" >> /srv/www/htdocs/kernellist/$dyear-$dmonth.html
	echo "<br>" >> /srv/www/htdocs/kernellist/$dyear-$dmonth.html
	grep "TITLE=\"SUSE-SU" /tmp/$i  >> /srv/www/htdocs/kernellist/$dyear-$dmonth.html
	echo "<br>" >> /srv/www/htdocs/kernellist/$dyear-$dmonth.html
	grep "UTC $dyear" /tmp/$i|sed 's/<I>//'|sed -e 's/<\/I>//' >> /srv/www/htdocs/kernellist/$dyear-$dmonth.html 
	echo "<br>" >> /srv/www/htdocs/kernellist/$dyear-$dmonth.html
	#grep "Announcement ID" /tmp/$i
	echo "<br>" >> /srv/www/htdocs/kernellist/$dyear-$dmonth.html
	#echo "" >> /srv/www/htdocs/kernellist.html
fi

rm /tmp/$i



done

if [ -f /srv/www/htdocs/kernellist/$dyear-$dmonth.html ]
then
	diff -q /srv/www/htdocs/kernellist/$dyear-$dmonth.html /tmp/$dyear-$dmonth.html-$dnano
	if [ $? -ne 0 ]
	then
	#	cat /srv/www/htdocs/kernellist/$dyear-$dmonth.html;echo "http://192.168.0.46/kernellist/"|mail -s "New Kernels found" <emailaddr@email.com>
		echo "http://192.168.0.46/kernellist/ $(cat /srv/www/htdocs/kernellist/$dyear-$dmonth.html|pandoc -f html -t plain)"|mail -s "New Kernels found" <emailaddr@email.com>
	fi
fi
#<a href="https://btrfs.wiki.kernel.org/index.php/Using_Btrfs_with_Multiple_Devices">BTRFS Wiki - Using Btrfs with Multiple Devices</a>
#ls -latr /srv/www/htdocs/kernellist/ |grep html|grep -v index|awk '{print $9}' > index.html

ls -latr /srv/www/htdocs/kernellist/|grep html|grep -v index|awk '{print "<a href=\"http://192.168.0.46/kernellist/"$9"\">"$9"</a><br>"}' > /srv/www/htdocs/kernellist/index.html
rm /tmp/$dyear-$dmonth.html-$dnano
