#!/bin/bash
set -e
admin_user=$(whoami)

if [ "$(rpm -qa openpbs-server)" = "" ];then
    version=`wget -O - https://www.openpbs.org/Download.aspx#download | grep -i \<h5\>OpenPBS | awk '{print $2}'`
    pbs_ver=${version::${#version}-6}
    yum install -y openpbs-server-${pbs_ver}-0.x86_64.rpm 
    systemctl enable pbs
    systemctl start pbs
    /opt/pbs/bin/qmgr -c "s s managers += ${admin_user}@*"
    /opt/pbs/bin/qmgr -c 's s flatuid=t'
    /opt/pbs/bin/qmgr -c 's s job_history_enable=t'
    /opt/pbs/bin/qmgr -c 'c r pool_name type=string,flag=h'

    # Update the sched_config file to schedule jobs that request pool_name
    sed -i "s/^resources: \"ncpus,/resources: \"ncpus, pool_name,/g" /var/spool/pbs/sched_priv/sched_config
    systemctl restart pbs
else
    echo "PBSPro already installed"
fi
