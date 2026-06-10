#!/bin/bash

lagi='y'
while  [ $lagi != 'x' ] || [ $lagi != 'x' ];
do
clear
echo "SILAHKAN PILIH AKSI YANG TERSEDIA";
echo "-------------";
echo "1. Tampilkan list spam email ";
echo "2. Hapus spam email dari domain ";
echo "3. Suspend by domain       ";
echo "4. Suspend by username     ";
echo "5. Hapus email bounce/freeze       ";
read -p "Pilihan anda [1-5] :" pil;

if [ $pil -eq 1 ];
then
   exim -bpr | grep "<" | awk {'print $4'} | cut -d "<" -f 2 | cut -d ">" -f 1 | sort -n | uniq -c | sort -n
elif [ $pil -eq 2 ];
then
   echo "masukan domain=";
   read dom;
   exiqgrep -i -f $dom | xargs exim -Mrm;
elif [ $pil -eq 3 ];
then
echo "masukan domain=";
read dom;
touch userlist
grep $dom /etc/domainusers | cut -d: -f1 >> userlist ;
while read user; do
   /scripts/suspendacct $user
done < userlist
rm -f userlist
elif [ $pil -eq 4 ];
then
echo "masukan user=";
read user1;
/scripts/suspendacct $user1
elif [ $pil -eq 5 ];
then
exim -bp | grep '<>' | awk '/^ *[0-9]+[mhd]/{print "exim -Mrm " $3}' | bash
else
echo "Terimakasih"
   exit 1
fi

read lagi2;
lagi='y'
done
echo "Selesai"
