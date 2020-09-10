#!/bin/bash
set -e
# arg: $1 = pbs_server
pbs_server=$1

if [ "$(rpm -qa openpbs-execution)" = "" ];then
    version=`wget -O - https://www.openpbs.org/Download.aspx#download | grep -i \<h5\>OpenPBS | awk '{print $2}'`
    pbs_ver=${version::${#version}-6}
    yum install -y openpbs-execution-${pbs_ver}-0.x86_64.rpm

    sed -i "s/CHANGE_THIS_TO_PBS_PRO_SERVER_HOSTNAME/${pbs_server}/g" /etc/pbs.conf
    sed -i "s/CHANGE_THIS_TO_PBS_PRO_SERVER_HOSTNAME/${pbs_server}/g" /var/spool/pbs/mom_priv/config
    sed -i "s/^if /#if /g" /opt/pbs/lib/init.d/limits.pbs_mom
    sed -i "s/^fi/#fi /g" /opt/pbs/lib/init.d/limits.pbs_mom
    systemctl enable pbs
    systemctl start pbs

    # Retrieve the VMSS name to be used as the pool name for multiple VMSS support
    poolName=$(curl -s -H Metadata:true "http://169.254.169.254/metadata/instance?api-version=2018-10-01" | jq -r '.compute.vmScaleSetName')
    /opt/pbs/bin/qmgr -c "c n $(hostname) resources_available.pool_name='$poolName'"
    
else
    echo "PBS client was already installed"
fi
