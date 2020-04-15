FROM open5gs_kamailio

RUN apt-get install -y netcat
ADD kamailio_pcscf /etc/kamailio_pcscf/

# ims_ipsec_pcscf listens to ports 5060-5064
EXPOSE 5060-5064/tcp
EXPOSE 5060-5064/udp

# ipsec client/server
EXPOSE 5100/udp
EXPOSE 6100/udp
EXPOSE 5100/tcp
EXPOSE 6100/tcp

# Diameter
EXPOSE 3871/tcp
EXPOSE 3871/sctp

CMD /mnt/pcscf/pcscf_init.sh
