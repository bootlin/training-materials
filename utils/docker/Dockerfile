# Docker file to create a container with everything needed to build
# Bootlin trainig materials
#
# Build the container (once):
#
#  sudo docker build -t bootlin-training utils/docker
#
# Use the container:
#
#  sudo docker run -u $(id -u):$(id -g) -v $(pwd):/training -it --rm bootlin-training make <target>
#
# Note: "docker run" must run from the top-level directory of the
# training materials

FROM fedora:34

LABEL maintainer="Bootlin <feedback@bootlin.com>" \
      vendor="Bootlin" \
description="Container with everything needed to build Bootlin training materials"

RUN dnf -y update && \
    dnf -y install \
	dia \
	fakeroot \
	ghostscript \
	git \
	inkscape \
	levien-inconsolata-fonts \
	liberation-serif-fonts \
	liberation-sans-fonts \
	liberation-mono-fonts \
	make \
	python3-pygments \
	rsync \
	texlive-beamer \
	texlive-environ \
	texlive-epstopdf \
	texlive-eurosym \
	texlive-hyphenat \
	texlive-inconsolata \
	texlive-lstaddons \
	texlive-mdframed \
	texlive-moreverb \
	texlive-overpic \
	texlive-parskip \
	texlive-texfot \
	texlive-titling \
	texlive-ulem \
	texlive-upquote \
	texlive-wrapfig \
	texlive-xetex \
	texlive-textpos \
	texlive-makecell \
	texlive-stmaryrd \
	texlive-fmtcount \
	texlive-babel-english \
	texlive-babel-french \
	texlive-appendixnumberbeamer

ENV HOME /tmp

WORKDIR /training
