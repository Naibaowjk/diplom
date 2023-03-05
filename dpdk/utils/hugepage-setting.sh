#!/bin/bash

# Print script commands and exit on errors.
set -xe

# setting
echo 1024 > /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages
mkdir /mnt/huge
mount -t hugetlbfs pagesize=1GB /mnt/huge
echo "nodev /mnt/huge hugetlbfs pagesize=1GB 0 0" | tee -a /etc/fstab
chmod -R 777 /dev/hugepages