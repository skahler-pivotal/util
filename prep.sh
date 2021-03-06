#!/bin/sh
set -e
set -x

OSVERSION=`rpm -q --qf "%{VERSION}" $(rpm -q --whatprovides redhat-release)`

yum -y install gcc gcc-c++ git wget ncurses-devel bzip2 bison flex openssl-devel libcurl-devel json-c-devel readline-devel bzip2-devel libyaml libyaml-devel libevent-devel openldap-devel libxml2-devel libxslt-devel apr-devel apr-util-devel libffi-devel libxml2-devel python-devel perl-ExtUtils-Embed

# EARLY 6 or 7 options
if [ "$OSVERSION" -eq "6" ]
then
 wget http://springdale.math.ias.edu/data/puias/computational/6/x86_64/libarchive3-3.2.1-1.sdl6.x86_64.rpm
 rpm -Uvh --force libarchive3-3.2.1-1.sdl6.x86_64.rpm

  # Need C++11
  wget http://people.centos.org/tru/devtools-2/devtools-2.repo -O /etc/yum.repos.d/devtools-2.repo
  yum -y install devtoolset-2-gcc devtoolset-2-binutils devtoolset-2-gcc-c++
  scl enable devtoolset-2 bash
  rpm -ivh http://dl.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm
fi

if [ "$OSVERSION" -eq "7" ]
then
  rpm -ivh http://dl.fedoraproject.org/pub/epel/7/x86_64/Packages/e/epel-release-7-11.noarch.rpm
fi

yum -y install python-pip cmake3
pip install --upgrade psutil
pip install --upgrade lockfile
pip install --upgrade paramiko
pip install --upgrade setuptools
pip install --upgrade epydoc
pip install --upgrade pyyaml

cat >> /etc/sysctl.conf <<EOF
kernel.shmmax = 500000000
kernel.shmmni = 4096
kernel.shmall = 4000000000
kernel.sem = 250 512000 100 2048
kernel.sysrq = 1
kernel.core_uses_pid = 1
kernel.msgmnb = 65536
kernel.msgmax = 65536
kernel.msgmni = 2048
net.ipv4.tcp_syncookies = 1
net.ipv4.ip_forward = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_max_syn_backlog = 4096
net.ipv4.conf.all.arp_filter = 1
net.ipv4.ip_local_port_range = 1025 65535
net.core.netdev_max_backlog = 10000
net.core.rmem_max = 2097152
net.core.wmem_max = 2097152
EOF

sysctl -p

cat > /etc/security/limits.d/90-nproc.conf <<EOF
kernel.msgmni = 2048
* soft nofile 65536
* hard nofile 65536
* soft nproc 131072
* hard nproc 131072
EOF

useradd -m -r gpadmin -d /home/gpadmin
mkdir /usr/local/gpdb
chown -R gpadmin /usr/local/gpdb
mkdir /data
chown -R gpadmin /data/

# LATE 6 or 7 options
if [ "$OSVERSION" -eq "6" ]
then
  echo '. /opt/rh/devtoolset-2/enable' >> /home/gpadmin/.bash_profile
fi
