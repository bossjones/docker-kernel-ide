FROM ubuntu:18.04
MAINTAINER Tomasz Sętkowski <tom@ai-traders.com>

RUN apt-get update && apt-get upgrade -y
RUN apt-get update && apt-get install -y bc git fakeroot build-essential ncurses-dev xz-utils cpio
RUN apt-get -y --no-install-recommends install kernel-package
RUN apt-get build-dep -y linux-image-$(uname -r)
RUN apt-get install kernel-wedge -y

# some of these may have already been installed, and some may not even be needed.
RUN apt install bison flex libelf-dev fakeroot build-essential crash kexec-tools makedumpfile kernel-wedge libncurses5 libncurses5-dev libelf-dev asciidoc binutils-dev libudev-dev pciutils-dev -y

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
