FROM alpine:3.13
MAINTAINER Matt Whitted <https://github.com/mwhitted4u>

RUN apk --no-cache add wget curl python3 python3-dev py-setuptools coreutils netcat-openbsd bash py3-requests py3-pip \
    && apk --no-cache add --virtual build-dependencies build-base \
    && mkdir -p /usr/etc/exabgp \
    && pip3 install ipaddr exabgp==4.2.13 ipy ntplib \
    && apk del build-dependencies \
    && ln -s /usr/bin/python3 /usr/bin/python

ADD entrypoint.sh /
ADD exabgp.conf.example /usr/etc/exabgp/
ADD check_dns.py /usr/local/bin/
ADD check_ntp.py /usr/local/bin/
ADD health.sh /usr/local/bin/

ENTRYPOINT ["/entrypoint.sh"]
CMD ["exabgp"]
VOLUME ["/usr/etc/exabgp"]
EXPOSE 179
