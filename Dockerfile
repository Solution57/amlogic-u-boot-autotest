FROM debian:buster
MAINTAINER Neil Armstrong <narmstrong@baylibre.com>
LABEL Description="This image is for building u-boot inside a container"

# Make sure apt is happy
ENV DEBIAN_FRONTEND=noninteractive

# Update packages
RUN dpkg --add-architecture i386
RUN apt-get update -qq

# Install OE dependencies
RUN apt-get install -qq gawk bison flex wget git-core diffstat unzip texinfo gcc-multilib build-essential chrpath socat libsdl1.2-dev xterm python2.7 python-minimal cpio python3
    
# Install git
RUN apt-get install -qq git

# Add missing libz for linaro gcc
RUN apt-get install -qq zlib1g:i386

# Add tools
RUN apt-get install uhubctl

# Setup system
RUN apt-get install -qq locales
RUN locale-gen en_US.UTF-8
RUN update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8

# Use en_US.UTF-8 locale
ENV LANG=en_US.UTF-8

# Clone lab-tools
RUN git clone https://github.com/montjoie/lab-tools --depth 1

# Clone pyamlboot
RUN git clone https://github.com/superna9999/pyamlboot --depth 1
