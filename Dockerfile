FROM alpine:latest
ARG GIT_VER=
ENV VER=2.3.3
LABEL version=2.3.3${GIT_VER}
LABEL author="Alexandre Cassen <acassen@gmail.com>"
LABEL project="https://github.com/acassen/keepalived"
LABEL homepage="https://www.keepalived.org"

# add keepalived sources to /tmp/keepalived-2.3.3
ADD keepalived-2.3.3.tar.gz /tmp

# Add keepalived default script user to make sure their IDs get assigned consistently,
# regardless of whatever dependencies get added
RUN addgroup -S keepalived_script && adduser -D -S -G keepalived_script keepalived_script

# 1. install required libraries and tools
# 2. compile and install keepalived
# 3. remove keepalived sources and unnecessary libraries and tools
RUN apk --no-cache add \
	binutils \
#	file \
#	file-dev \
	gcc \
	glib \
	glib-dev \
#	ipset \
#	ipset-dev \
	iptables \
	iptables-dev \
	libmnl-dev \
	libnftnl-dev \
	libnl3 \
	libnl3-dev \
	linux-headers \
	make \
	musl-dev \
	net-snmp-dev \
	openssl \
	openssl-dev \
#	pcre2 \
#	pcre2-dev \
	autoconf \
	automake \
    && cd /tmp/keepalived-2.3.3/ \
    && ./autogen.sh \
    && ./configure \
		--disable-dynamic-linking \
		--prefix=/usr \
		--exec-prefix=/usr \
		--bindir=/usr/bin \
		--sbindir=/usr/sbin \
		--sysconfdir=/etc \
		--datadir=/usr/share \
		--localstatedir=/var \
		--mandir=/usr/share/man \
		--with-dbus-data-dir=/usr/share \
		--enable-bfd \
		--enable-dbus \
#		--enable-regex \
		--enable-snmp \
		--enable-snmp-rfc \
		--enable-nftables \
#		--disable-iptables \
		--disable-libipset \
		--enable-json \
    && make && make install \
    && strip /usr/sbin/keepalived \
    && cd - \
    && rm -rf /tmp/keepalived-2.3.3 \
    && apk --no-cache del \
	binutils \
#	file-dev \
	gcc \
	glib-dev \
#	ipset-dev \
	iptables-dev \
	libmnl-dev \
	libnl3-dev \
	libnftnl-dev \
	make \
	musl-dev \
	openssl-dev \
#	pcre2-dev \
	autoconf \
	automake

ADD docker/keepalived.conf /etc/keepalived/keepalived.conf

# set keepalived as image entrypoint with --dont-fork and --log-console (to make it docker friendly)
# define /etc/keepalived/keepalived.conf as the configuration file to use
ENTRYPOINT ["/usr/sbin/keepalived","--dont-fork","--log-console", "-f","/etc/keepalived/keepalived.conf"]

# example command to customise keepalived daemon:
# CMD ["--log-detail","--dump-conf"]
