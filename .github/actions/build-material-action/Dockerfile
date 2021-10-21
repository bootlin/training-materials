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
	texlive-stmaryrd

ENV HOME /tmp

WORKDIR /training
