FROM alpine:3.10.2
MAINTAINER Kevin M. Gallagher <kevingallagher@gmail.com>

RUN addgroup -g 666 -S proxy
RUN adduser -S -D -H -k /dev/null -s /bin/bash -G proxy -u 666 -g 'Tor Proxy' proxy

ADD files/repositories /etc/apk/repositories

RUN apk update
RUN apk upgrade
RUN apk --no-cache add --update ca-certificates curl openssl polipo privoxy tor torsocks supervisor bash

RUN curl -s wget https://bootstrap.pypa.io/get-pip.py > /tmp/get-pip.py
RUN python2 /tmp/get-pip.py
RUN pip2 install -U supervisor

RUN /usr/bin/install -m 02755 -o root -g root -d /run/tor -d /var/run/tor -d /var/log/tor -d /var/lib/tor
RUN /usr/bin/install -m 02775 -o root -g root -d /run/polipo -d /var/run/polipo -d /var/log/polipo -d /var/cache/polipo
RUN /usr/bin/install -m 02775 -o privoxy -g adm -d /run/privoxy -d /var/run/privoxy -d /var/log/privoxy

ADD files/privoxy_config /etc/privoxy/config
ADD files/polipo_config /etc/polipo/config
# ADD files/redsocks_config /etc/redsocks.conf
ADD files/torrc /etc/tor/torrc
ADD files/torsocks.conf /etc/tor/torsocks.conf

ADD files/supervisord.conf /etc/supervisor/supervisord.conf

EXPOSE 8123 8118 9050 9051 9053
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
