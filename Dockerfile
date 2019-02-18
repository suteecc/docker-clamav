FROM debian:stretch-slim

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -q -y update &&\
    apt-get install --no-install-recommends -y -qq \
        clamav-daemon \
        clamav-freshclam \
#        libclamunrar7 \
        wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# initial update of av databases 
RUN wget -O /var/lib/clamav/main.cvd http://database.clamav.net/main.cvd && \
    wget -O /var/lib/clamav/daily.cvd http://database.clamav.net/daily.cvd && \
    wget -O /var/lib/clamav/bytecode.cvd http://database.clamav.net/bytecode.cvd && \
    chown clamav:clamav /var/lib/clamav/*.cvd

# permission juggling 
RUN mkdir /var/run/clamav && \
    chown clamav:clamav /var/run/clamav && \
    chmod 750 /var/run/clamav && \
    groupadd -g 103 amavis && \
    usermod -a -G amavis clamav

# av configuration update 
RUN sed -i 's/^Foreground .*$/Foreground true/g' /etc/clamav/clamd.conf && \
    echo "TCPSocket 3310" >> /etc/clamav/clamd.conf && \
    sed -i 's/^Foreground .*$/Foreground true/g' /etc/clamav/freshclam.conf

# volume provision 
VOLUME ["/var/lib/clamav"]

EXPOSE 3310

CMD ["clamd"]
