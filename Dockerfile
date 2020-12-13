ARG  CENTOS_VERSION=8
FROM docker.io/library/centos:${CENTOS_VERSION}

# Maybe add 
# libselinux-devel
# glibc-static
# device-mapper-devel 
RUN yum -y install \
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
    major_version=$(cut -d '.' -f 1 <<< "$CENTOS_VERSION") && \
    if [ $major_version == "8" ]; then \
      minor_version=$(cut -d '.' -f 2 <<< "$CENTOS_VERSION") && \
      repo=/etc/yum.repos.d/CentOS-PowerTools.repo && \
      if [ -n "$minor_version" -a $minor_version -ge 3 ]; then \
        repo=/etc/yum.repos.d/CentOS-Linux-PowerTools.repo; \
      fi && \
      sed -i s/enabled=0/enabled=1/ $repo ; \
    fi && \
    yum install -y \
      device-mapper \
      device-mapper-devel \
      device-mapper-libs \
      gpgme-devel \
      libassuan-devel && \
    yum clean all
