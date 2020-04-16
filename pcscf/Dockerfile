FROM open5gs_kamailio

ADD kamailio_pcscf /etc/kamailio_pcscf/

# ims_ipsec_pcscf listens to ports 5060-5064
EXPOSE 5060/tcp
EXPOSE 5060/udp
EXPOSE 5062/tcp
EXPOSE 5062/udp
EXPOSE 5063/tcp
EXPOSE 5063/udp

# ipsec client/server
EXPOSE 5100-5109/tcp
EXPOSE 5100-5109/udp
EXPOSE 6100-6109/tcp
EXPOSE 6100-6109/udp

# Diameter
EXPOSE 3871/tcp
EXPOSE 3871/sctp

COPY ./init.d/kamailio_pcscf /etc/init.d/kamailio_pcscf
COPY ./default/kamailio_pcscf /etc/default/kamailio_pcscf

CMD /mnt/pcscf/pcscf_init.sh
