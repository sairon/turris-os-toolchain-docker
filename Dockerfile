FROM ubuntu:trusty

MAINTAINER Jan Cermak <jan.cermak@nic.cz>

ENV HOME=/openwrt

RUN \
  sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list && \
  echo "# Installing base packages" && \
  apt-get update && \
  apt-get -y upgrade && \
  apt-get -y install --no-install-recommends \
    build-essential bzr ccache curl cvs gawk gcc-multilib flex \
    gawk git-core gettext libncurses5-dev libssl-dev libxml-parser-perl \
    mercurial openjdk-6-jdk quilt subversion \
    unzip wget xsltproc zip zlib1g-dev && \
  apt-get clean

RUN \
    echo "# Cloning Turris OS repository" && \
    git clone https://gitlab.labs.nic.cz/turris/openwrt.git

RUN \
    echo "# Building Turris OS tools and toolchain" && \
    cd /openwrt && \
    cat configs/common configs/$TARGET_BOARD | sed -e "s|@BOARD@|$TARGET_BOARD|" -e "s|@BRANCH@|$PKG_BRANCH|" > .config && \
    echo "CONFIG_CCACHE=y" >> .config && \
    make defconfig && \
    make tools/install toolchain/install -j$(($(nproc) + 2)) IS_TTY=1 LOGFILE=1 BUILD_LOG=1 IGNORE_ERRORS=m \
      || (tail -n 1000 logs/build.log && false)

CMD [ "bash" ]
