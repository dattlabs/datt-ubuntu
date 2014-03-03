FROM ubuntu:12.04
MAINTAINER John Albietz "inthecloud247@gmail.com"

RUN \
  `# ubuntu sources.list setup`; \
  echo deb http://archive.ubuntu.com/ubuntu precise main > /etc/apt/sources.list; \
  echo deb http://archive.ubuntu.com/ubuntu precise universe multiverse >> /etc/apt/sources.list; \
  echo deb http://archive.ubuntu.com/ubuntu precise-updates main restricted universe >> /etc/apt/sources.list; \
  echo deb http://security.ubuntu.com/ubuntu precise-security main restricted universe >> /etc/apt/sources.list; \
  \
  `# prevent udev, initscripts and upstart from being updated with apt-get update`; \
  echo udev hold | dpkg --set-selections; \
  echo initscripts hold | dpkg --set-selections; \
  echo upstart hold | dpkg --set-selections; \
  \
  `# update packages`; \
  apt-get update; \
  apt-get -y -u upgrade --no-install-recommends;

RUN \
  `# https support for apt`; \
  apt-get install -y apt-transport-https; \
  \
  `# fix apt issue: https://github.com/dotcloud/docker/issues/1024`; \
  dpkg-divert --local --rename --add /sbin/initctl; \
  ln -sf /bin/true /sbin/initctl; \
  \
  `# fix locale`; \
  apt-get -y install language-pack-en; \
  locale-gen en_US; \
  \
  `# disable ipv6`; \
  echo 'net.ipv6.conf.default.disable_ipv6 = 1' > /etc/sysctl.d/20-ipv6-disable.conf; \
  echo 'net.ipv6.conf.all.disable_ipv6 = 1' >> /etc/sysctl.d/20-ipv6-disable.conf; \
  echo 'net.ipv6.conf.lo.disable_ipv6 = 1' >> /etc/sysctl.d/20-ipv6-disable.conf; \
  cat /etc/sysctl.d/20-ipv6-disable.conf; \
  sysctl -p; \
  \
 `# setup ubuntu user and set default passwords`; \
  useradd -d /home/ubuntu -m ubuntu -s /bin/bash -c "ubuntu user"; \
  adduser ubuntu sudo; \
  echo 'ubuntu:ubuntu' | chpasswd; \
  echo 'root:root' | chpasswd;

CMD ["/bin/bash"]
