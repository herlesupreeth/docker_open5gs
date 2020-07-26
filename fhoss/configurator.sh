#!/bin/bash

# Initialization & global vars
# if you execute this script for the second time
# you should change these variables to the latest
# domain name and ip address
DDOMAIN="open-ims\.test"
DSDOMAIN="open-ims\\\.test"
DEFAULTIP="127\.0\.0\.1"
CONFFILES=`ls *.cfg *.xml *.sql *.properties 2>/dev/null`

# Interaction
domainname=$1
ip_address=$2

# input domain is to be slashed for cfg regexes 
slasheddomain=`echo $domainname | sed 's/\./\\\\\\\\\./g'`

printf "changing: "
for i in $CONFFILES 
do
sed -i -e "s/$DDOMAIN/$domainname/g" $i
sed -i -e "s/$DSDOMAIN/$slasheddomain/g" $i
sed -i -e "s/$DEFAULTIP/$ip_address/g" $i

printf "$i " 
done 
echo
