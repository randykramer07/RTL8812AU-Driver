#!/bin/sh
#==================================================================================================
#title           :RK-RTL8812AU.sh
#description     :Install RTL8812AU Drivers
#author          :Randy Kramer
#date            :06/02/2023
#version         :1.0
#==================================================================================================

#Check if root rights are true
if ! [ "$(id -u)" -eq 0 ]; then
	echo "You stupid! You're trying to execute this without root rights"
	exit 1
fi

# Check if networking is working
echo "First, we're going to check if there is a working network connection."
if ! nc -zw1 google.com 443 >/dev/null; then
	printf "%s\n " "There is no working network connection, please fix this first."
	exit 1
fi
echo "We found a working network connection, we're going to install some packages\n"

# Loop to install all necessary packages
packages="dkms git"
for package in $packages
do
	if ! yes | sudo apt-get install $package >/dev/null 2>&1; then
	printf "%s\n" "The following package couldn't be installed: $package"
	exit 1
	fi
done
printf "%s\n\n" "The following packages are installed succesfully: $packages"

#Clone git to local machine
printf "%s\n" "It's time to clone the git repository, give this a few seconds"
if git clone -b v5.6.4.2 --depth=1 https://github.com/aircrack-ng/rtl8812au.git >/dev/null 2>&1; then
	printf "%s\n" "We've succesfuly cloned the repository onto the local machine"
else
	printf "%s\n" "We couldn't clone the repository onto the local machine"
	exit 1
fi

cd rtl*

#Installation of Driver
printf "%s\n" "Finally it's time to install the driver, here we go."
printf "%s\n" "This could take a while. Light up a cigaret or something"
make dkms_install >/dev/null 2>&1

printf "%s\n" "The driver has been installed successfully and the repository has been removed"
cd ..
rm -rf rtl*

modprobe rtl8812au
