FROM open5gs_kamailio

RUN apt-get install -y netcat
ADD kamailio_pcscf /etc/kamailio_pcscf/

# ims_ipsec_pcscf listens to ports 5060-5064
EXPOSE 5060-5064/tcp
EXPOSE 5060-5064/udp

# Diameter
EXPOSE 3871/tcp
EXPOSE 3871/sctp

CMD /mnt/pcscf/pcscf_init.sh
