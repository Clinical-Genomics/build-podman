ARG  CENTOS_VERSION=latest
FROM docker.io/library/centos:${CENTOS_VERSION}

# Maybe add 
# libselinux-devel
# glibc-static
# device-mapper-devel 
RUN yum -y update && \
  yum -y install \
    autoconf \
    automake \
    gcc \
    git \
    glib2-devel \
    glibc-devel \
    iptables \
    libgpg-error-devel \
    libseccomp-devel \
    libtool \
    make \
    pkgconf-pkg-config \
    pkgconfig \
    systemd-devel && \
  . /etc/os-release && \
  major_version=$(cut -d '.' -f 1 <<< "$VERSION_ID") && \
  if [ $major_version == "8" ]; \
    then sed -i s/enabled=0/enabled=1/ /etc/yum.repos.d/CentOS-PowerTools.repo ; \
  fi && \
  yum install -y \
    device-mapper \
    device-mapper-devel \
    device-mapper-libs \
    gpgme-devel \
    libassuan-devel && \
  yum clean all
