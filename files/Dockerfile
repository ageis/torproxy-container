FROM alpine:3.10.2
MAINTAINER Kevin M. Gallagher <kevingallagher@gmail.com>

ARG TOR_CONTROL_PASSWD
ENV TOR_CONTROL_PASSWD=${TOR_CONTROL_PASSWD}

RUN addgroup -g 666 -S proxy
RUN adduser -S -D -H -k /dev/null -s /bin/bash -G proxy -u 666 -g 'Tor Proxy' proxy

ADD repositories /etc/apk/repositories

RUN /sbin/apk update
RUN /sbin/apk -U upgrade
RUN /sbin/apk --no-cache add --update ca-certificates curl openssl bash runit &&  /sbin/apk -v add tor@edge torsocks@edge privoxy@edge supervisor@edge && \
    chmod 700 /var/lib/tor && \
    rm -rf /var/cache/apk/* && \
    tor --version

HEALTHCHECK --timeout=10s --start-period=60s \
    CMD curl --fail --socks5-hostname torproxy:9050 -I -L 'https://check.torproject.org/' || exit 1

RUN /usr/bin/curl -s https://bootstrap.pypa.io/get-pip.py > /tmp/get-pip.py
RUN /usr/bin/python2 /tmp/get-pip.py
RUN pip2 install -U supervisor

RUN /usr/bin/install -m 02755 -o root -g root -d /run/tor -d /var/run/tor -d /var/log/tor -d /var/lib/tor
RUN /usr/bin/install -m 02775 -o privoxy -g adm -d /run/privoxy -d /var/run/privoxy -d /var/log/privoxy

ADD privoxy_config /etc/privoxy/config
ADD torrc /etc/tor/torrc
ADD torsocks.conf /etc/tor/torsocks.conf
ADD supervisord.conf /etc/supervisor/supervisord.conf

RUN /bin/sed -i -r "s/TOR_CONTROL_PASSWD/${TOR_CONTROL_PASSWD}/g" /etc/tor/torrc /etc/tor/torsocks.conf
RUN export HASHED_CONTROL_PASSWD=$(/usr/bin/tor --quiet --hash-password "${TOR_CONTROL_PASSWD}") && echo "HashedControlPassword ${HASHED_CONTROL_PASSWD}" >> /etc/tor/torrc

EXPOSE 8118 9050 9051 9053

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]