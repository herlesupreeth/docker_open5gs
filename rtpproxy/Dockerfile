FROM docker_open5gs

RUN apt-get install -y rtpproxy

EXPOSE 7722/udp
EXPOSE 2223/UDP

COPY rtpproxy /etc/default/
ENV CONTROL_SOCK=udp:0.0.0.0:7722
CMD /usr/bin/rtpproxy -f -l 0.0.0.0 -d DBUG:LOG_LOCAL0 -u rtpproxy
