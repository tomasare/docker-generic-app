FROM otechlabs/busybox-java:jdk8

MAINTAINER Dawid Malinowski <d.malinowski@oberthur.com>

ENV HOME=/opt/app
WORKDIR /opt/app

# Add user app
RUN echo "app:x:999:999::/opt/app:/bin/false" >> /etc/passwd; \
    echo "app:x:999:" >> /etc/group; \
    mkdir -p /opt/app; chown app:app /opt/app
