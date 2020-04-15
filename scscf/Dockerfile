FROM open5gs_kamailio

RUN apt-get install -y netcat
ADD kamailio_scscf /etc/kamailio_scscf/

EXPOSE 6060/tcp
EXPOSE 6060/udp
EXPOSE 3870/tcp
EXPOSE 3870/sctp

CMD /mnt/scscf/scscf_init.sh
