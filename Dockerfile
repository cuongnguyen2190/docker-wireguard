FROM hungcuongvt90/ubuntu_base_tool:focal

# set version label
# ARG BUILD_DATE
# ARG VERSION
ARG WIREGUARD_RELEASE
ENV WIREGUARD_RELEASE=${WIREGUARD_RELEASE:-v1.0.20210914}
# LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="aptalca"

ENV DEBIAN_FRONTEND="noninteractive"

RUN \
 echo "**** install dependencies ****" && \
 apt-get update && \
 apt-get install -y --no-install-recommends \
	bc \
	build-essential \
	curl \
	sudo \
	dkms \
	git \
	gnupg \ 
	ifupdown \
	iproute2 \
	iptables \
	iputils-ping \
	jq \
	libc6 \
	libelf-dev \
	net-tools \
	openresolv \
	perl \
	pkg-config \
	qrencode && \
 echo "**** install wireguard-tools ****" && \
 if [ -z ${WIREGUARD_RELEASE+x} ]; then \
	WIREGUARD_RELEASE=$(curl -sX GET "https://api.github.com/repos/WireGuard/wireguard-tools/tags" \
	| jq -r .[0].name); \
 fi && \
 cd /home/cuong/app && \
 git clone https://git.zx2c4.com/wireguard-linux-compat && \
 git clone https://git.zx2c4.com/wireguard-tools && \
 cd wireguard-tools && \
 git checkout "${WIREGUARD_RELEASE}" && \
 make -C src -j$(nproc) && \
 make -C src install && \
 echo "**** install CoreDNS ****" && \
 COREDNS_VERSION=$(curl -sX GET "https://api.github.com/repos/coredns/coredns/releases/latest" \
	| awk '/tag_name/{print $4;exit}' FS='[""]' | awk '{print substr($1,2); }') && \
 curl -o \
	/tmp/coredns.tar.gz -L \
	"https://github.com/coredns/coredns/releases/download/v${COREDNS_VERSION}/coredns_${COREDNS_VERSION}_linux_amd64.tgz" && \
 tar xf \
	/tmp/coredns.tar.gz -C \
	/home/cuong/app && \
 echo "**** clean up ****" && \
 rm -rf \
	/tmp/* \
	/var/lib/apt/lists/* \
	/var/tmp/*

# add local files
COPY /root/app /home/cuong/app
COPY /root/defaults /home/cuong/defaults
COPY /root/etc /etc

ENV PATH=${PATH}:/home/cuong/app

# ports and volumes
EXPOSE 51820/udp
