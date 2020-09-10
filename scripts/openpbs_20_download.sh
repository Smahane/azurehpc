#!/bin/bash

version=`wget -O - https://www.openpbs.org/Download.aspx#download | grep -i \<h5\>OpenPBS | awk '{print $2}'`
pbs_ver=${version::${#version}-6}

filename=openpbs_${pbs_ver}.centos_8.zip

if [ ! -f "$filename" ];then
    wget -q http://wpc.23a7.iotacdn.net/8023A7/origin2/rl/OpenPBS/$filename
    unzip $filename
fi

