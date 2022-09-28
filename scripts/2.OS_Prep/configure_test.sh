#!/usr/bin/bash

PRINT_OK=" = OK"
PRINT_EMPTY="BLABALA "
PRINT_ERROR=" = ERROR"
TMPF=/tmp/check_rhel.tmp


check_and_config_str_equal() {
if [ x"$1" = x"$2" ]
PROBLEM=0
  then echo -e $1 "$PRINT_OK" >> /tmp/_configure/"$lhost"_$(date +"%Y_%m_%d_%I_%M_%p").txt
  #echo -e PROBLEM NOTEXIST >> /tmp/_configure/"$lhost"_$(date +"%Y_%m_%d_%I_%M_%p").txt
  else
  PROBLEM=EXIST
fi
}

check_str_equal() {
if [ x"$1" != x"$2" ]
  #then echo -e $1 "$PRINT_EMPTY" >> /tmp/_configure/"$lhost"_$(date +"%Y_%m_%d_%I_%M_%p").txt
  then echo -e " calculated value = " $1 " required value = " $2 "$PRINT_ERROR" >> /tmp/_configure/"$lhost"_$(date +"%Y_%m_%d_%I_%M_%p").txt
fi
PROBLEM=0
}


echo -ne "1.2.1 Checking timezone    "  >> /tmp/_configure/"$lhost"_$(date +"%Y_%m_%d_%I_%M_%p").txt

par=`timedatectl | grep Europe/Moscow`
val='       Time zone: Europe/Moscow (MSK, +0300)'
check_and_config_str_equal  "$par" "$val"
if PROBLEM=EXIST 
then timedatectl set-timezone Europe/Moscow 
fi
check_str_equal  "$par" "$val"
