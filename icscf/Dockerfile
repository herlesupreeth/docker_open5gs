FROM open5gs_kamailio

ADD kamailio_icscf /etc/kamailio_icscf/

EXPOSE 4060/tcp
EXPOSE 4060/udp
EXPOSE 3869/tcp
EXPOSE 3869/sctp

COPY ./init.d/kamailio_icscf /etc/init.d/kamailio_icscf
COPY ./default/kamailio_icscf /etc/default/kamailio_icscf

CMD /mnt/icscf/icscf_init.sh
