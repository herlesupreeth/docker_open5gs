FROM open5gs_kamailio

RUN apt-get install -y netcat
ADD kamailio_pcscf /etc/kamailio_pcscf/

EXPOSE 5060/tcp
EXPOSE 5060/udp
EXPOSE 3871/tcp
EXPOSE 3871/sctp

CMD /mnt/pcscf/pcscf_init.sh
