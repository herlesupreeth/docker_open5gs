FROM open5gs_kamailio

ADD kamailio_icscf /etc/kamailio_icscf/

EXPOSE 4060/tcp
EXPOSE 4060/udp
EXPOSE 3869/tcp
EXPOSE 3869/sctp

CMD /mnt/icscf/icscf_init.sh
