FROM open5gs_kamailio

ADD kamailio_scscf /etc/kamailio_scscf/

EXPOSE 6060/tcp
EXPOSE 6060/udp
EXPOSE 3870/tcp
EXPOSE 3870/sctp

COPY ./init.d/kamailio_scscf /etc/init.d/kamailio_scscf
COPY ./default/kamailio_scscf /etc/default/kamailio_scscf

CMD /mnt/scscf/scscf_init.sh
