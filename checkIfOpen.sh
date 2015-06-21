#!/bin/bash

checkIfOpen() {
check_file="$1"
while :
do
if ! [[ `lsof -- $1 ` ]]
then
break
fi
sleep 1
done
}

checkIfOpen $1
echo "mv $1"
