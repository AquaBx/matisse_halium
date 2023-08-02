FROM ubuntu:focal

SHELL ["/bin/bash", "-c"]
WORKDIR /halium
ENV TZ=Europe/Paris
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone


RUN dpkg --add-architecture i386
RUN apt update
RUN apt install -y git gnupg flex bison gperf build-essential zip bzr curl libc6-dev libncurses5-dev:i386 \
x11proto-core-dev libx11-dev:i386 libreadline6-dev:i386 libgl1-mesa-glx:i386 libgl1-mesa-dev \
g++-multilib mingw-w64-i686-dev tofrodos python3-markdown libxml2-utils xsltproc zlib1g-dev:i386 \
schedtool liblz4-tool bc lzop imagemagick libncurses5 rsync python-is-python2 python2

RUN echo export PATH=\$PATH:\$HOME/bin >> ~/.bashrc
RUN source ~/.bashrc
RUN curl https://storage.googleapis.com/git-repo-downloads/repo > /bin/repo
RUN chmod a+rx /bin/repo

RUN git config --global user.email "you@example.com"
RUN git config --global user.name "Your Name"

COPY ./matissewifi.xml .repo/local_manifests/

RUN repo init -u https://github.com/Halium/android -b halium-9.0 --depth=1
RUN repo sync -c -j 16

COPY ./lineage_matissewifi_defconfig /halium/kernel/samsung/msm8226/arch/arm/configs/

RUN hybris-patches/apply-patches.sh --mb
RUN source build/envsetup.sh \ 
&& breakfast matissewifi \
&& mka mkbootimg \
&& export USE_HOST_LEX=yes \
&& mka halium-boot \
&& mka e2fsdroid \
&& mka systemimage 
