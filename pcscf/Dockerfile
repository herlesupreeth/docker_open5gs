FROM open5gs_kamailio

ADD kamailio_pcscf /etc/kamailio_pcscf/

EXPOSE 5060/tcp
EXPOSE 5060/udp
EXPOSE 3871/tcp

CMD /mnt/pcscf/pcscf_init.sh
