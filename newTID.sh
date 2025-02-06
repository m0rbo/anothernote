#!/bin/bash
#
#       Author: Brad Bendily
#         Date: 02/06/2025
#  Description: This script queries suse.com for new TIDs.  It saves new TIDs
#               to a tmp file and emails it to the email string defined in
#               'email' variable below. 
#
#               The script requires the html-xml-utils pkg.  To install:
#
#                    $ sudo zypper in html-xml-utils
#
#               This script can be run by hand @ cmdline or via cron:
#
#  0 8 * * * /usr/bin/flock -xn /tmp/newTID.sh.lck -c "/path/newTID.sh  >/tmp/newTID.sh.cron.log 2>&1
#
#    Changelog:
#       06/06/2025 - Initial version

#
######### Changes these value(s) ONLY!!!!#########

# Add your email here
email="xxxxxxxxx@xxxxx.com"

################################################

NTVERSION="0.01"
TEMPFILE="$(mktemp)"
TEMPFILE2="$(mktemp)"
mv /tmp/tidlist.txt $TEMPFILE

#the sort on this curl puts "12" (december) over/on top of "01" (january) which puts all the new january TIDs out of the list.
#curl -Ls 'https://www.suse.com/support/kb/?maxIndex=300&startIndex=1' | hxnormalize -ex | hxselect '#results' | w3m -T text/html -dump -cols 1024 | tac | tr '\n' '\0' | xargs -0 -L2 | sort -Vr | nl|head -n20 > /tmp/tidlist.txt

#at this time, (Jan 17 2025), this curl is showing the january TIDs at the top of the list

curl -Ls 'https://www.suse.com/support/kb/?maxIndex=10&startIndex=1' | hxnormalize -ex | hxselect '#results' | w3m -T text/html -dump -cols 1024 |tr '\n' '\0' | xargs -0 -L2 |nl|head -n 20 > /tmp/tidlist.txt


#awk 'BEGIN{FS="\\(00"}{print $2}' /tmp/tidlist.txt |sed s'/)//'
#for i in $(curl -s https://lists.suse.com/pipermail/sle-updates/$dyear-$dmonth/thread.html|grep -i kernel|grep -v "Live Patch"|grep -v firmware|awk -F\" '{print $2}')
IFS='
'
for f in $(cat /tmp/tidlist.txt)
do
    # 1 11/13/2024 How to check if an NFS mount point supports xattr (000021619)
    # <a href="https://www.facebook.com/Seravo" class="social-facebook"><span>Facebook</span></a>
    # echo $f

    TIDNUM=$(echo $f|awk 'BEGIN{FS="\\(00"}{print $2}' |sed s'/)//')

    #https://www.suse.com/support/kb/doc/?id=000019214
    echo $tidnum
    TIDLINK="https://www.suse.com/support/kb/doc/?id=00$TIDNUM"
    # TIDLINK="<a href="https://www.suse.com/support/kb/doc/?id=00$TIDNUM" <span>$TIDNUM</span></a>"

    echo $f $TIDLINK
    echo $f $TIDLINK >> $TEMPFILE2
done
diff -q /tmp/tidlist.txt $TEMPFILE
if [ $? -ne 0 ]; then
    #       cat /srv/www/htdocs/kernellist/$dyear-$dmonth.html;echo "http://192.168.0.46/kernellist/"|mail -s "New Kernels found" bendily@gmail.com
    #         cat /tmp/tidlist.txt |mail -s "New TIDs found" bendily@gmail.com
    cat $TEMPFILE2 |mail -s "New TIDs found" ${email}
fi

#   done
rm $TEMPFILE
rm $TEMPFILE2
