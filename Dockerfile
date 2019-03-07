FROM ubuntu:18.04
MAINTAINER Tomasz Sętkowski <tom@ai-traders.com>


RUN echo "deb-src http://archive.ubuntu.com/ubuntu bionic main restricted" >> /etc/apt/sources.list
RUN echo "deb-src http://archive.ubuntu.com/ubuntu bionic-updates main restricted" >> /etc/apt/sources.list
RUN echo "deb-src http://archive.ubuntu.com/ubuntu bionic universe" >> /etc/apt/sources.list
RUN echo "deb-src http://archive.ubuntu.com/ubuntu bionic-updates universe" >> /etc/apt/sources.list
RUN echo "deb-src http://archive.ubuntu.com/ubuntu bionic multiverse" >> /etc/apt/sources.list
RUN echo "deb-src http://archive.ubuntu.com/ubuntu bionic-updates multiverse" >> /etc/apt/sources.list
RUN echo "deb-src http://archive.ubuntu.com/ubuntu bionic-backports main restricted universe multiverse" >> /etc/apt/sources.list
RUN echo "deb-src http://security.ubuntu.com/ubuntu bionic-security main restricted" >> /etc/apt/sources.list
RUN echo "deb-src http://security.ubuntu.com/ubuntu bionic-security universe" >> /etc/apt/sources.list
RUN echo "deb-src http://security.ubuntu.com/ubuntu bionic-security multiverse" >> /etc/apt/sources.list

ENV _KERNEL_VERSION=4.15.0

RUN apt-get update && apt-get upgrade -y
RUN apt-get update && apt-get install -y bc git fakeroot build-essential ncurses-dev xz-utils cpio
RUN apt-get -y --no-install-recommends install kernel-package
RUN apt-get build-dep -y linux-image-${_KERNEL_VERSION}-generic
RUN apt-get install kernel-wedge -y

# some of these may have already been installed, and some may not even be needed.
RUN apt install bison flex libelf-dev fakeroot build-essential crash kexec-tools makedumpfile kernel-wedge libncurses5 libncurses5-dev libelf-dev asciidoc binutils-dev libudev-dev pciutils-dev -y

RUN echo "deb http://ddebs.ubuntu.com $(lsb_release -cs) main restricted universe multiverse" | tee -a /etc/apt/sources.list.d/ddebs.list
RUN echo "deb http://ddebs.ubuntu.com $(lsb_release -cs)-updates main restricted universe multiverse" | tee -a /etc/apt/sources.list.d/ddebs.list
RUN echo "deb http://ddebs.ubuntu.com $(lsb_release -cs)-proposed main restricted universe multiverse" | tee -a /etc/apt/sources.list.d/ddebs.list


# RUN echo "deb http://ddebs.ubuntu.com $(lsb_release -cs) main restricted universe multiverse
# deb http://ddebs.ubuntu.com $(lsb_release -cs)-updates main restricted universe multiverse
# deb http://ddebs.ubuntu.com $(lsb_release -cs)-proposed main restricted universe multiverse" | \
# tee -a /etc/apt/sources.list.d/ddebs.list

RUN sudo apt install -y ubuntu-dbgsym-keyring
RUN sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys F2EDC64DC5AEE1F6B9C621F0C8CAB6595FDFF622
RUN sudo apt-get update

RUN apt-get install pkg-config-dbgsym -y

RUN useradd -d /home/ide -p pass -s /bin/bash -u 1000 -m ide

RUN mkdir -p /ide/work && mkdir -p /ide/output && mkdir -p /ide/work
RUN chown ide:ide -R /ide
# RUN su - ide -c "git clone https://github.com/torvalds/linux.git /ide/linux"
RUN su - ide -c "touch /ide/work/.ide-mark"

COPY ide-scripts/* /usr/bin/
RUN chmod 755 /usr/bin/ide-fix-uid-gid.sh &&\
    chmod 755 /usr/bin/ide-setup-identity.sh &&\
    chmod 755 /usr/bin/entrypoint.sh &&\
    chown ide:ide -R /home/ide

ADD kernel-scripts/kernel-build.sh /usr/bin/kernel-build
ADD kernel-scripts/kernel-checkout.sh /usr/bin/kernel-checkout

RUN chmod 755 /usr/bin/kernel-build &&\
 chmod 755 /usr/bin/kernel-checkout

# ENTRYPOINT ["/usr/bin/entrypoint.sh"]
# CMD ["/usr/bin/kernel-build"]

# cd /usr/src/linux-source-$(uname -r| cut -d\- -f1)
# mkdir debian/stamps
# bunzip2 linux-source-$(uname -r| cut -d\- -f1).tar.bz2
# tar xf linux-source-$(uname -r| cut -d\- -f1).tar
# # if you don't do this you will get the "ubuntu-retpoline-extract-one no such file" error
# mv linux-source-$(uname -r| cut -d\- -f1)/* .
# mkdir debian/stamps # otherwise build failure because touch command fa

# chmod a+x debian/rules
# chmod a+x debian/scripts/*
# chmod a+x debian/scripts/misc/*

# # After that, I could successfully run:
# fakeroot debian/rules clean
# # you need to go through each (Y, Exit, Y, Exit..) or get a complaint about config later
# fakeroot debian/rules editconfigs
# # DO I NEED THIS? sudo fakeroot debian/rules binary-headers binary-generic binary-perarch
# # SOURCE: https://askubuntu.com/questions/1085411/unable-to-follow-kernel-buildyourownkernel
# sudo fakeroot debian/rules binary-headers binary-generic binary-perarch

# # FYI: build w/ DEBUG symbols
# fakeroot debian/rules binary-headers binary-generic binary-perarch skipdbg=false

