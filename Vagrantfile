#Commands to install an iscsi VM and 2 cluster nodes.

 echo "starting iscsi VM deploy..."
 zypper install -y chrony tgt man;
 echo "maxdistance 16.0" >>/etc/chrony.conf;
 echo "server 192.168.0.46" >>/etc/chrony.conf;
 systemctl restart chronyd;
 systemctl enable chronyd;
 aa-disable dnsmasq
 systemctl stop apparmor;
 systemctl disable apparmor;
 echo "StrictHostKeyChecking no" >>/etc/ssh/ssh_config
 mkdir /var/lib/hanaiscsi_disks
 dd if=/dev/zero of=/var/lib/hanaiscsi_disks/hana15_disk01.img count=0 bs=1 seek=10G
 dd if=/dev/zero of=/var/lib/hanaiscsi_disks/hana15_disk02.img count=0 bs=1 seek=10G
 dd if=/dev/zero of=/var/lib/hanaiscsi_disks/hana15_disk03.img count=0 bs=1 seek=1G
 echo "<target iqn.2019-12.com.domain.labs.hanaiscsi:hana15>" >/etc/tgt/conf.d/hana15.conf
 echo "  backing-store /var/lib/hanaiscsi_disks/hana15_disk01.img" >>/etc/tgt/conf.d/hana15.conf
 echo "  backing-store /var/lib/hanaiscsi_disks/hana15_disk02.img" >>/etc/tgt/conf.d/hana15.conf
 echo "  backing-store /var/lib/hanaiscsi_disks/hana15_disk03.img" >>/etc/tgt/conf.d/hana15.conf
 echo "  initiator-name iqn.2019-20.com.domain.labs.hana01:hana01" >>/etc/tgt/conf.d/hana15.conf
 echo "  initiator-name iqn.2019-20.com.domain.labs.hana02:hana02" >>/etc/tgt/conf.d/hana15.conf
 echo "  incominguser username password" >>/etc/tgt/conf.d/hana15.conf
 echo "</target>" >>/etc/tgt/conf.d/hana15.conf
 systemctl start tgtd
 systemctl enable tgtd

      #HANA Cluster node 01 
 echo "starting hana01 deploy.."
 zypper install -y chrony open-iscsi lsscsi man;
 echo "maxdistance 16.0" >>/etc/chrony.conf;
 echo "server 192.168.0.46" >>/etc/chrony.conf;
 systemctl restart chronyd;
 systemctl enable chronyd;
 aa-disable dnsmasq
 systemctl stop apparmor;
 systemctl disable apparmor;
 zypper install -y -t pattern ha_sles sap-hana
 echo "StrictHostKeyChecking no" >>/etc/ssh/ssh_config
 echo "InitiatorName=iqn.2019-20.com.domain.labs.hana01:hana01" >/etc/iscsi/initiatorname.iscsi
 echo "node.session.auth.authmethod = CHAP" >>/etc/iscsi/iscsid.conf
 echo "node.session.auth.username = username" >>/etc/iscsi/iscsid.conf
 echo "node.session.auth.password = password" >>/etc/iscsi/iscsid.conf
 sed -i 's/node.startup = manual/node.startup = automatic/g' /etc/iscsi/iscsid.conf 
 systemctl restart iscsi iscsid
 iscsiadm -m discovery -t sendtargets -p hanaiscsi.domain2.com
 iscsiadm --mode node --target iqn.2019-12.com.domain.labs.hanaiscsi:hana15 --portal hanaiscsi.domain2.com:3260 -o new
 systemctl restart iscsi iscsid
      #TODO use /dev/disk/by-id/ path for sbd
      #setup/share ssh keys for root users between nodes
 ha-cluster-init -s $(fdisk -l 2>/dev/null | grep "1 GiB" | awk '{print $2}' | cut -c 1-8) -i eth1 -y
 zypper install -y cron;
 saptune solution apply HANA
 saptune service takeover
 saptune service enablestart
      #zypper install -y qemu-guest-agent;
      #systemctl start qemu-ga@virtio\\x2dports-org.qemu.guest_agent.0.service
      #systemctl enable qemu-ga@virtio\\x2dports-org.qemu.guest_agent.0.service
      # parted /dev/vdb mklabel gpt
      # parted /dev/vdb mkpart primary xfs 1MiB 204799MiB
      # mkfs -t xfs /dev/vdb1 
      # mkdir /hana 
      # echo "$(blkid | grep vdb1 | awk '{print $2}' | sed -e 's/\"//g') /hana xfs defaults 0 0" >>/etc/fstab
      # mount -a
 mkdir -p /hana/files
      # scp -r root@192.168.0.91:/opt/sap-full* /hana/files/
      # scp -r root@192.168.0.91:/opt/SAP_HANA_DATABASE_053_20SPS05 /hana/files/
 mv /hana/files/SAP_HANA_DATABASE_053_20SPS05/* /opt/
 echo "hxeadm ALL=(ALL) NOPASSWD: /usr/sbin/crm_attribute -n hana_hxe_site_srHook_*" >> /etc/sudoers
    ##  /opt/hdblcm --hdbinst_server_import_content=off --batch --configfile=/tmp/install.rsp
    /opt/hdblcm --hdbinst_server_import_content=off --batch --configfile=/hana/files/sap-full-install/install.rsp
      echo "Waiting for SAPHANA to be ready, sleeping for 120..."
 sleep 120;
    ##  /usr/sap/HXE/HDB00/exe/hdbsql -p SuSE1234 -u SYSTEM -d SYSTEMDB "BACKUP DATA FOR FULL SYSTEM USING FILE ('backup')"
      /usr/sap/HXE/HDB00/exe/hdbsql -p SuSE1234 -u SYSTEM -d SYSTEMDB "BACKUP DATA FOR FULL SYSTEM USING FILE ('backup')"
      su - hxeadm -c 'hdbnsutil -sr_enable --name=hana01'
      echo "end HANA01.."


  # Cluster Node 2
 echo "starting hana02 deploy, sleeping for 120sec..."
 zypper install -y chrony open-iscsi lsscsi man;
 echo "maxdistance 16.0" >>/etc/chrony.conf;
 echo "server 192.168.0.46" >>/etc/chrony.conf;
 systemctl restart chronyd;
 systemctl enable chronyd;
 aa-disable dnsmasq
 systemctl stop apparmor;
 systemctl disable apparmor;
 zypper install -y -t pattern ha_sles sap-hana
 echo "StrictHostKeyChecking no" >>/etc/ssh/ssh_config
 echo "InitiatorName=iqn.2019-20.com.domain.labs.hana02:hana02" >/etc/iscsi/initiatorname.iscsi
 echo "node.session.auth.authmethod = CHAP" >>/etc/iscsi/iscsid.conf
 echo "node.session.auth.username = username" >>/etc/iscsi/iscsid.conf
 echo "node.session.auth.password = password" >>/etc/iscsi/iscsid.conf
 sed -i 's/node.startup = manual/node.startup = automatic/g' /etc/iscsi/iscsid.conf 
 systemctl restart iscsi iscsid
 iscsiadm -m discovery -t sendtargets -p hanaiscsi.domain2.com
 iscsiadm --mode node --target iqn.2019-12.com.domain.labs.hanaiscsi:hana15 --portal hanaiscsi.domain2.com:3260 -o new
 systemctl restart iscsi iscsid
 zypper install -y cron;
 saptune solution apply HANA
 saptune service takeover
 saptune service enablestart
      # zypper install -y qemu-guest-agent;
      #systemctl start qemu-ga@virtio\\x2dports-org.qemu.guest_agent.0.service
      #systemctl enable qemu-ga@virtio\\x2dports-org.qemu.guest_agent.0.service
 mkdir /hana/
 echo "$(blkid | grep vdb1 | awk '{print $2}' | sed -e 's/\"//g') /hana xfs defaults 0 0" >>/etc/fstab
 mount -a
 mkdir -p /hana/files
 scp -r root@192.168.0.91:/opt/sap-full* /hana/files/
 scp -r root@192.168.0.91:/opt/SAP_HANA_DATABASE_053_20SPS05 /hana/files/
 mv /hana/files/SAP_HANA_DATABASE_053_20SPS05/* /opt/
      # Message said this WAS OLD  ha-cluster-join -y -i eth1 -c hana01
      sleep 60;
 crm cluster join -y -i eth1 -c hana01
 echo "hxeadm ALL=(ALL) NOPASSWD: /usr/sbin/crm_attribute -n hana_hxe_site_srHook_*" >> /etc/sudoers
      sleep 60;
      /opt/hdblcm --hdbinst_server_import_content=off --batch --configfile=/hana/files/sap-full-install/install.rsp
      /usr/sap/HXE/HDB00/exe/hdbsql -p SuSE1234 -u SYSTEM -d SYSTEMDB "BACKUP DATA FOR FULL SYSTEM USING FILE ('backup')"
   ##   rsync -zahP hana01:/hana/shared/HXE/global/security/rsecssfs/ /hana/shared/HXE/global/security/rsecssfs/
    scp -r hana01:/hana/shared/HXE/global/security/rsecssfs/ /hana/files/
    rm -rf /hana/shared/HXE/global/security/rsecssfs/*
    cp -a /hana/files/rsecssfs/* /hana/shared/HXE/global/security/rsecssfs/
    chown -R hxeadm:sapsys /hana/shared/HXE/global/security/rsecssfs/
      su - hxeadm -c 'HDB stop'
      su - hxeadm -c 'hdbnsutil -sr_register --remoteHost=hana01 --remoteInstance=00 --replicationMode=syncmem --operationMode=delta_datashipping --name=hana02'
      su - hxeadm -c 'HDB start'
   ##   rsync -ahP rabble.domain.cloud::rabble/Team_Files/training/labs/sap/fulldeploy/crm_sap_part* /tmp/
   #Load CRM config options from SUSE SAP angi docs.
   https://documentation.suse.com/sbp/sap-15/html/SLES4SAP-hana-angi-perfopt-15/index.html

    # crm configure load update /hana/files/sap-full-crm/crm_sap_part1.txt
    # crm configure load update /hana/files/sap-full-crm/crm_sap_part2.txt
    # crm configure load update /hana/files/sap-full-crm/crm_sap_part3.txt
    # crm configure load update /hana/files/sap-full-crm/crm_sap_part4.txt
    # crm configure load update /hana/files/sap-full-crm/crm_sap_part5.txt
     echo "end HANA02..."

