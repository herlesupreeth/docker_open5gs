---
name: Bug report
about: Something does not work in a docker_open5gs deployment
labels: bug
---

**First check [TROUBLESHOOTING.md](https://github.com/herlesupreeth/docker_open5gs/blob/master/TROUBLESHOOTING.md)** — most reported
problems are answered there (setup-dependent phone/PLMN issues, harmless
logs, unsupported features). If you find your symptom, follow its checklist
before opening this issue.

## What happened
<!-- One paragraph: what you expected vs what you see. Name the exact error
     text/log line if there is one. -->

## What did NOT work (tick)
- [ ] UE attach (S1AP/NGAP)
- [ ] Internet/data after attach
- [ ] `ims` APN attach / SIP REGISTER (VoLTE)
- [ ] IMS registration (401/403/408/503)
- [ ] Call setup / call drop / one-way audio
- [ ] VoNR (5G SA calling)
- [ ] SMS
- [ ] VoWiFi/ePDG
- [ ] RAN ↔ core connectivity (multi-host)
- [ ] Build/deploy/images
- [ ] Other: ____

## Setup
<!-- §0 of TROUBLESHOOTING.md. Every item matters. -->
- Deploy file used: (4g-volte-deploy.yaml / sa-vonr-deploy.yaml / deploy-all.yaml / other: ___)
- Hosts: how many, what runs where (core / RAN / UE)
- RAN: (srsRAN_4G eNB / srsRAN_Project gNB / ueransim / commercial + vendor+version)
- SDR/radio: (B210 / B210mini / LibreSDR / ZMQ+Gnuradio / none)
- Band + EARFCN:
- PLMN (MCC MNC), network + SIM aligned? (R/roaming visible on phone?)
- UE: phone model + chipset (or srsUE / sipp / swu_client)
- CPU performance mode enabled on RAN host? (yes/no)

## Repo & environment state
```
git log -1 --format='%H %ci'
git diff --stat        # paste output — unmodified = clean
docker --version && docker compose version
```
- Base images rebuilt after `git pull` (open5gs / kamailio / srsRAN / osmoMSC): yes / no / n-a
- `docker system prune -f` + clean redeploy tried? (this alone fixes a large share — say yes/no)

## Subscriber provisioning (only for attach/IMS/call issues)
- Ki/OP set in WebUI/pyHSS match the SIM? (WebUI "Operator Key" value must
  match the OPc/OP radio — don't paste the OP value under "OPc")
- IMSI/MSISDN (last 4 digits only) / APNs present in HSS (internet + ims) with QCI 1+2?

## Captures
- **Unfiltered pcap on interface `any`**, taken on the core machine, using
  the clean-setup procedure from TROUBLESHOOTING.md §0 (stop all →
  `tcpdump -ni any -w /tmp/pcap.pcap` → deploy → RAN → UE → test → stop).
  Attach it here. Logs alone are not debuggable.
- Container logs (`docker logs <nf>`) for the components involved:

## Steps to reproduce
1.
2.
3.
