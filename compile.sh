#!/bin/bash

# Checkout u-boot
if [ ! -d "u-boot" ]; then
  git clone https://github.com/u-boot/u-boot.git
else
  cd u-boot
  git checkout master
  git pull
  cd ..
fi

# Checkout amlogic-boot-fip
if [ ! -d "fip" ]; then
  git clone https://github.com/LibreELEC/amlogic-boot-fip.git fip
else
  cd fip
  git checkout master
  git pull
  cd ..
fi

