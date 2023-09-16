#!/bin/bash

sudo mkdir /var/tmp-nvidia
sudo chmod 1777 /var/tmp-nvidia
sudo cp nvidia-power-management.conf /etc/modprobe.d/nvidia-power-mangement.conf
sudo systemctl enable nvidia-suspend.service
sudo mkinitcpio -P
