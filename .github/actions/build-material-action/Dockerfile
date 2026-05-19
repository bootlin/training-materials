FROM fedora:44

LABEL maintainer="Bootlin <feedback@bootlin.com>" \
      vendor="Bootlin" \
description="Container with everything needed to build Bootlin training materials"

COPY build_materials.sh /build_materials.sh

ENTRYPOINT ["/build_materials.sh"]

RUN dnf -y update && \
    dnf -y install \
	appstream-devel \
	curl \
	desktop-file-utils \
	fakeroot \
	g++ \
	gcc \
	ghostscript \
	git \
	glib2-devel \
	graphene-devel \
	gtk3-devel \
	ImageMagick \
	inkscape \
	levien-inconsolata-fonts \
	liberation-serif-fonts \
	liberation-sans-fonts \
	liberation-mono-fonts \
	libxml2-devel \
	libzip-devel \
	make \
	meson \
	ninja-build \
	python3-devel \
	python3-pygments \
	rsync \
	texlive-beamer \
	texlive-environ \
	texlive-epstopdf \
	texlive-eurosym \
	texlive-collection-fontsextra \
	texlive-enumitem \
	texlive-hypcap \
	texlive-hyphenat \
	texlive-inconsolata \
	texlive-lstaddons \
	texlive-ltablex \
	texlive-marvosym \
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
	texlive-appendixnumberbeamer \
	which

ARG DIA_REVISION=3ce95975211707efe15d936923a2ae62433f27ec
RUN git clone https://gitlab.gnome.org/GNOME/dia.git /tmp/dia && \
    cd /tmp/dia && \
    git checkout ${DIA_REVISION} && \
    meson setup build --prefix=/usr/local --buildtype=release && \
    meson compile -C build && \
    meson install -C build && \
    echo "/usr/local/lib64" > /etc/ld.so.conf.d/dia.conf && \
    ldconfig && \
    rm -rf /tmp/dia

ARG TYPST_VERSION=0.14.2
RUN curl -fsSL https://github.com/typst/typst/releases/download/v${TYPST_VERSION}/typst-x86_64-unknown-linux-musl.tar.xz \
        -o /tmp/typst.tar.xz && \
    tar -xJf /tmp/typst.tar.xz -C /tmp && \
    install -m 0755 /tmp/typst-x86_64-unknown-linux-musl/typst /usr/local/bin/typst && \
    rm -rf /tmp/typst.tar.xz /tmp/typst-x86_64-unknown-linux-musl

ENV HOME /tmp

WORKDIR /training
