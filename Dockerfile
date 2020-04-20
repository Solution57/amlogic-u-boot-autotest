FROM debian:buster
MAINTAINER Neil Armstrong <narmstrong@baylibre.com>
LABEL Description="This image is for building u-boot inside a container"

# Make sure apt is happy
ENV DEBIAN_FRONTEND=noninteractive

# Update packages
RUN dpkg --add-architecture i386
RUN apt-get update -qq

# Install OE dependencies
RUN apt-get install -qq gawk bison flex wget git-core diffstat unzip texinfo gcc-multilib build-essential chrpath socat libsdl1.2-dev xterm python2.7 python-minimal cpio python3 python3-usb python-usb python3-serial python-serial bc
    
# Install git
RUN apt-get install -qq git

# Add missing libz for linaro gcc
RUN apt-get install -qq zlib1g:i386

# Add tools
RUN apt-get install -qq uhubctl

# Clone lab-tools
RUN mkdir -p /opt/lab-tools
RUN git clone https://github.com/montjoie/lab-tools --depth 1 /opt/lab-tools

# Clone pyamlboot
RUN mkdir -p /opt/pyamlboot
RUN git clone https://github.com/superna9999/pyamlboot --depth 1 /opt/pyamlboot

# Download and decompress toolchain
RUN mkdir -p /opt/toolchain
RUN wget -qO- https://releases.linaro.org/components/toolchain/binaries/7.5-2019.12/aarch64-linux-gnu/gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu.tar.xz  | tar -xJ --strip-components=1 -C /opt/toolchain
