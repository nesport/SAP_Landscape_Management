#!/usr/bin/bash

PRINT_OK=" = OK"
PRINT_ERROR=" = ERROR"
TMPF=/tmp/check_rhel.tmp

check_str_equal() {
if [ x"$1" = x"$2" ]
  then echo -e $1 "$PRINT_OK" >> /tmp/_check/"$lhost"_$(date +"%Y_%m_%d_%I_%M_%p").txt
  else echo -e $1 / $2 "$PRINT_ERROR" >> /tmp/_check/"$lhost"_$(date +"%Y_%m_%d_%I_%M_%p").txt
fi
}

check_num_equal() {
if [ "$1" -eq "$2" ]
  then echo -e "$PRINT_OK" >> /tmp/_check/"$lhost"_$(date +"%Y_%m_%d_%I_%M_%p").txt
  else echo -e "$PRINT_ERROR" >> /tmp/_check/"$lhost"_$(date +"%Y_%m_%d_%I_%M_%p").txt
fi
}

check_num_gt() {
if [ "$1" -gt "$2" ]
  then echo -e "$PRINT_OK" >> /tmp/_check/"$lhost"_$(date +"%Y_%m_%d_%I_%M_%p").txt
  else echo -e "$PRINT_ERROR" >> /tmp/_check/"$lhost"_$(date +"%Y_%m_%d_%I_%M_%p").txt
fi
}

check_num_ge() {
if [ "$1" -ge "$2" ]
  then echo -e "$PRINT_OK" >> /tmp/_check/"$lhost"_$(date +"%Y_%m_%d_%I_%M_%p").txt
  else echo -e "$PRINT_ERROR" >> /tmp/_check/"$lhost"_$(date +"%Y_%m_%d_%I_%M_%p").txt
fi
}


lhost=`hostname -s`
OS=`uname`
echo "$lhost"
mkdir /tmp/_check/
rm -rf /tmp/_check/*


echo -ne "1.1 Checking locale    "  >> /tmp/_check/"$lhost"_$(date +"%Y_%m_%d_%I_%M_%p").txt  
fileset=`locale -a | grep de_DE | wc -l`
check_num_ge "$fileset" 1 >> /tmp/_check/"$lhost"_$(date +"%Y_%m_%d_%I_%M_%p").txt 

echo -ne "1.2.1 Checking timezone    "  >> /tmp/_check/"$lhost"_$(date +"%Y_%m_%d_%I_%M_%p").txt
par=`timedatectl | grep  Europe/Moscow`
check_str_equal  "$par" "       Time zone: Europe/Moscow (MSK, +0300)"

echo -ne "1.2.2 Checking NTP enabled    "  >> /tmp/_check/"$lhost"_$(date +"%Y_%m_%d_%I_%M_%p").txt
par=`timedatectl | grep  "NTP enabled"`
check_str_equal  "$par" "     NTP enabled: yes"

echo -ne "1.2.3 Checking NTP sync    "  >> /tmp/_check/"$lhost"_$(date +"%Y_%m_%d_%I_%M_%p").txt
ntp_x=`ps -ef | grep ntp | grep -- -x | wc -l`
check_num_equal  $ntp_x 1

ntp_sync=`ntpstat | grep "time correct" | wc -l`
check_num_equal  $ntp_sync 1


echo -e "1.3 Check misc OS group of packets   "  >> /tmp/_check/"$lhost"_$(date +"%Y_%m_%d_%I_%M_%p").txt
for i in "Large Systems Performance" "Network File System Client" "Performance Tools" "Compatibility Libraries" "Large Systems Performance" "X Window System"
do
echo -ne "    $i    "  >> /tmp/_check/"$lhost"_$(date +"%Y_%m_%d_%I_%M_%p").txt 
#echo $i
PRG=$(yum grouplist hidden | grep "$i" | wc -l)
if [ -n "$PRG" ]
 then
  check_num_ge  $PRG 1
 else
  check_str_equal "not found" "$i"
 fi
done

echo -e "1.4 Check misc OS packets   "  >> /tmp/_check/"$lhost"_$(date +"%Y_%m_%d_%I_%M_%p").txt
for i in "compat-libstdc++-33" "libstdc++.x86_64" "compat-locales-sap" "resource-agents-sap" "tuned-profiles-sap" "sapconf" "uuidd" "nmon" "csh" "ksh" "at"
do
echo -ne "    $i    "  >> /tmp/_check/"$lhost"_$(date +"%Y_%m_%d_%I_%M_%p").txt 
#echo $i
PRG=$(yum list installed | grep "$i" | wc -l)
if [ -n "$PRG" ]
 then
  check_num_ge  $PRG 1
 else
  check_str_equal "not found" "$i"
 fi
done

echo -e "1.5 Check glib&systemd versions    "  >> /tmp/_check/"$lhost"_$(date +"%Y_%m_%d_%I_%M_%p").txt
if [ "$(yum list installed | grep "^glibc\.x86_64" | awk '{print($2)}')" = "2.17-196.el7_4.2" ] && [ "$(yum list installed | grep "^systemd\.x86_64" | awk '{print($2)}')" = "219-42.el7_4.6" ] ;
 then
  echo -e "$PRINT_OK" >> /tmp/_check/"$lhost"_$(date +"%Y_%m_%d_%I_%M_%p").txt
 else
  echo -e "$PRINT_ERROR" >> /tmp/_check/"$lhost"_$(date +"%Y_%m_%d_%I_%M_%p").txt
 fi


echo -e "1.6 Check hostnames   "  >> /tmp/_check/"$lhost"_$(date +"%Y_%m_%d_%I_%M_%p").txt
for i in "hostname" "hostname -s" "hostname -f"
do
echo -ne "    $i    "  >> /tmp/_check/"$lhost"_$(date +"%Y_%m_%d_%I_%M_%p").txt 
PRG2=$(exec $i | wc -l)
if [ -n "$PRG2" ]
 then
  check_num_equal  $PRG2 1
  cc="`exec $i`"
  echo $cc  >> /tmp/_check/"$lhost"_$(date +"%Y_%m_%d_%I_%M_%p").txt
 else
  check_str_equal "not set" "$i"
 fi
done

echo -e "1.7 Check RHEL release "  >> /tmp/_check/"$lhost"_$(date +"%Y_%m_%d_%I_%M_%p").txt
RELEASE=`cat /etc/redhat-release`
echo $RELEASE  >> /tmp/_check/"$lhost"_$(date +"%Y_%m_%d_%I_%M_%p").txt
if [ "$RELEASE" = "CentOS Linux release 8.2.2004 (Core)" ];
 then
  echo -e "$PRINT_OK" >> /tmp/_check/"$lhost"_$(date +"%Y_%m_%d_%I_%M_%p").txt
 else
  echo -e "$PRINT_ERROR" >> /tmp/_check/"$lhost"_$(date +"%Y_%m_%d_%I_%M_%p").txt
 fi

echo -ne "1.9 Checking swap size >=128GB    "  >> /tmp/_check/"$lhost"_$(date +"%Y_%m_%d_%I_%M_%p").txt
swap=`lsblk -a | grep swap | awk '{print($4)}' | sed 's/[A-Z]//g'`
#ss=`for i in "$swaps"; do echo -ne $i" "; done | sed 's/ $//g' | sed 's/ /+/g'`
#s1=$(echo $ss | bc)
echo -ne SWAP size "$swap"GB   >> /tmp/_check/"$lhost"_$(date +"%Y_%m_%d_%I_%M_%p").txt
check_num_ge $swap 128

echo -ne "1.10.1 Check kernel parameters kernel.msgmni and kernel.sem   "  >> /tmp/_check/"$lhost"_$(date +"%Y_%m_%d_%I_%M_%p").txt
echo
kern_msg=`sysctl -a --ignore 2>/dev/null | grep "^kernel\.msgmni" | head -n 1 | awk '{print($3)}'`
echo -ne kernel.msgmni=$kern_msg  >> /tmp/_check/"$lhost"_$(date +"%Y_%m_%d_%I_%M_%p").txt
check_num_equal $kern_msg 1024



kern_sem1=`sysctl -a --ignore 2>/dev/null | grep "^kernel\.sem" | head -n 1 | awk '{print($3)}'`
check_num_equal $kern_sem1 1250

kern_sem2=`sysctl -a --ignore 2>/dev/null | grep "^kernel\.sem" | head -n 1 | awk '{print($4)}'`
check_num_equal $kern_sem2 256000

kern_sem3=`sysctl -a --ignore 2>/dev/null | grep "^kernel\.sem" | head -n 1 | awk '{print($5)}'`
check_num_equal $kern_sem3 100

kern_sem4=`sysctl -a --ignore 2>/dev/null | grep "^kernel\.sem" | head -n 1 | awk '{print($6)}'`
check_num_equal $kern_sem4 1024
echo -ne kernel.sem=$kern_sem1 $kern_sem2 $kern_sem3 $kern_sem4   >> /tmp/_check/"$lhost"_$(date +"%Y_%m_%d_%I_%M_%p").txt

echo   >> /tmp/_check/"$lhost"_$(date +"%Y_%m_%d_%I_%M_%p").txt

echo -ne  "1.10.2 Check kernel parameters vm.max_map_count,kernel.shmmax,kernel.shmall   "  >> /tmp/_check/"$lhost"_$(date +"%Y_%m_%d_%I_%M_%p").txt

kern_vmmax=`sysctl -a --ignore 2>/dev/null | grep "^vm\.max_map_count" | head -n 1 | awk '{print($3)}'`

echo -ne vm.max_map_count=$kern_vmmax  >> /tmp/_check/"$lhost"_$(date +"%Y_%m_%d_%I_%M_%p").txt
check_num_equal $kern_vmmax 2000000

kern_shmmax=`sysctl -a --ignore 2>/dev/null | grep "^kernel\.shmmax" | head -n 1 | awk '{print($3)}'`

echo -ne kernel.shmmax =$kern_shmmax  >> /tmp/_check/"$lhost"_$(date +"%Y_%m_%d_%I_%M_%p").txt
check_num_equal $kern_shmmax 68719476736

kern_shmall=`sysctl -a --ignore 2>/dev/null | grep "^kernel\.shmall" | head -n 1 | awk '{print($3)}'`
echo -ne kernel.shmall =$kern_shmall  >> /tmp/_check/"$lhost"_$(date +"%Y_%m_%d_%I_%M_%p").txt
check_num_equal $kern_shmall 35230140

echo -ne  "1.10.5 Check tmpfs size   "  >> /tmp/_check/"$lhost"_$(date +"%Y_%m_%d_%I_%M_%p").txt

tmpfs=`df -k /dev/shm  | grep tmpfs | awk '{print($2)}'`
echo -ne tmpfs=$tmpfs  >> /tmp/_check/"$lhost"_$(date +"%Y_%m_%d_%I_%M_%p").txt
check_num_ge $tmpfs 396031252

echo -ne  "1.11  Check  limits   "  >> /tmp/_check/"$lhost"_$(date +"%Y_%m_%d_%I_%M_%p").txt

lim_sapsys=`cat /etc/security/limits\.d/90-nproc\.conf | grep @sapsys | awk '{print($4)}'`
lim_dba=`cat /etc/security/limits\.d/90-nproc\.conf | grep @dba | awk '{print($4)}'`
echo  >> /tmp/_check/"$lhost"_$(date +"%Y_%m_%d_%I_%M_%p").txt
check_str_equal $lim_sapsys unlimited
check_str_equal $lim_dba unlimited
echo  >> /tmp/_check/"$lhost"_$(date +"%Y_%m_%d_%I_%M_%p").txt
echo -ne "cat /etc/security/limits.d/90-nproc.conf"  >> /tmp/_check/"$lhost"_$(date +"%Y_%m_%d_%I_%M_%p").txt
echo  >> /tmp/_check/"$lhost"_$(date +"%Y_%m_%d_%I_%M_%p").txt
/bin/cat /etc/security/limits.d/90-nproc.conf

echo -ne  "1.11  Check  limits   "  >> /tmp/_check/"$lhost"_$(date +"%Y_%m_%d_%I_%M_%p").txt

lim_sec_sapsys=`cat /etc/security/limits.conf  | grep sapsys | awk '{print($4)}'`
lim_sec_dba=`cat /etc/security/limits.conf  | grep dba | awk '{print($4)}'`
lim_sec_sdba=`cat /etc/security/limits.conf  | grep sdba | awk '{print($4)}'`
echo  >> /tmp/_check/"$lhost"_$(date +"%Y_%m_%d_%I_%M_%p").txt
check_num_equal $lim_sec_sapsys 65536
check_num_equal $lim_sec_dba 65536
check_num_equal $lim_sec_sdba 65536

echo  >> /tmp/_check/"$lhost"_$(date +"%Y_%m_%d_%I_%M_%p").txt
echo -ne "cat /etc/security/limits.conf"  >> /tmp/_check/"$lhost"_$(date +"%Y_%m_%d_%I_%M_%p").txt
echo  >> /tmp/_check/"$lhost"_$(date +"%Y_%m_%d_%I_%M_%p").txt
cat /etc/security/limits.conf | grep sapsys
cat /etc/security/limits.conf | grep dba

echo -ne  "1.13 Check SELinux Technology ..  "  >> /tmp/_check/"$lhost"_$(date +"%Y_%m_%d_%I_%M_%p").txt
selinux=`cat /etc/sysconfig/selinux | grep SELINUX=permissive`
echo  >> /tmp/_check/"$lhost"_$(date +"%Y_%m_%d_%I_%M_%p").txt
check_str_equal $selinux SELINUX=permissive

echo -e "2.2 Check misc programs   "  >> /tmp/_check/"$lhost"_$(date +"%Y_%m_%d_%I_%M_%p").txt
for i in ftp ssh python sshpass rsync ksh nmon csh
do
echo -ne "    $i    "  >> /tmp/_check/"$lhost"_$(date +"%Y_%m_%d_%I_%M_%p").txt 
PRG=$(which $i 2>/dev/null)
if [ -n "$PRG" ]
 then
  check_str_equal "$PRG" "$PRG"
 else
  check_str_equal "not found" "$i"
 fi
done



