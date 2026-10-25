# TROUBLESHOOTING

Symptom-first runbook for `docker_open5gs`. Each section: what you see → ordered checks → fix. Maintainers: if a section answers a new issue, close it with a link here.

## 0. Before anything else

Do these for **every** problem — half of all issues are resolved by step 2:

```bash
# 1. Describe your setup: which machine runs what, RAN (srsRAN_4G /
#    srsRAN_Project / ueransim / commercial + version), SDR (B210/mini,
#    LibreSDR, ZMQ), UE (phone model + chipset / srsUE / sipp), band/EARFCN,
#    PLMN (MCC MNC), deploy yaml used.
# 2. Make sure you are current and clean:
cd docker_open5gs && git pull
docker compose -f <your>.yaml down
docker system prune -f          # kills stale containers holding 2152/38412
docker compose -f <your>.yaml up
# 3. If you upgraded the repo and base images pin upstream commits
#    (open5gs, srsRAN, kamailio, osmoMSC), rebuild the affected base images.
# 4. Revert accidental edits:  git diff   (see §11 if data stopped working)
# 5. Host firewall off:  sudo ufw disable
```

**Standard pcap procedure** (required for any call/IMS/media issue — *logs are never enough*):

```bash
# On the machine running docker_open5gs:
sudo tcpdump -ni any -w /tmp/pcap.pcap   # interface "any", NO filters apart from SSH or any sensitive traffic you want to exclude
# now: start docker, deploy core, start RAN, attach UE, perform the test
sudo kill <tcpdump>
```

- Take it on the **core machine**, not the phone or a second host.
- No capture filters. Enable **ESP decryption** in Wireshark to see the 2nd REGISTER / media.
- Useful display filter in Wireshark for 5G deployments: `pfcp || gtp || ngap || http2.data.data || http2.headers`.
- Useful display filter in Wireshark for 4G deployments: `s1ap || gtpv2 || diameter || sip`.
- Clean-setup order: stop everything → capture → deploy → RAN → UE → test.

---

## 1. UE never attaches (S1AP/NGAP never complete)

| Check | Fix |
|---|---|
| Stale containers: port 2152 (N3 UDP) or 38412/38413 (SCTP) "in use" | `docker system prune -f`, redeploy |
| RAN on another host, using container/bridge IPs | External RAN needs: `network_mode: host` (or published SCTP), `mme_addr`/`amf.addr` = **host** IP running the core, `gtp_bind_addr`/`s1c_bind_addr`/`bind_addr` = RAN host IP, `SGWU_ADVERTISE_IP` = core host IP |
| Baicells eNB | MME IP must be `DOCKER_HOST_IP`, not `MME_IP` from `.env`; uncomment MME+SGW-U port exposures |
| `libsctp` missing on host | install libsctp (`sudo apt-get install libsctp-dev`) / `sudo modprobe sctp`; verify `netstat -tupln \| grep 38412` |
| gNB started before AMF | deploy core first, wait ~10 s, then start gNB |
| eNB in a VM | move to bare metal; give the VM ≥2 CPUs if unavoidable |
| Radio: `L=` lates, `Could not transmit RAR within the window` | §10 (performance mode, BW reduction, GPSDO) |

## 2. Attached, but no internet / no data

1. `git diff` — did you change `.env`/yaml? For single-host, keep stock values; don't touch `SGWU_ADVERTISE_IP`/`UPF_ADVERTISE_IP`.
2. Wait for **SMF↔PCRF (Gx)** to connect after deploy (≈1 min) before attaching the UE.
3. Custom APN/DNN (e.g. `mcx`): add the DNN to **both** `smf.yaml` and `upf.yaml`; phone's APN name+type must match the HSS entry; APN type for internet is `default`.
4. Phone APN ≠ HSS APN → MME `Invalid APN[...]` errors.
5. eUPF on another host: `UPF_IP`/`UPF_ADVERTISE_IP` = that host's IP.
6. Radio lates breaking the link → §10.
7. Multi-host: check MTUs and that GTP-U advertise IPs are host IPs.

## 3. No `ims` APN attach / no SIP REGISTER ("VoLTE not working")

**First check in the pcap: is there a PDN Connectivity Request / PDU session request for APN `ims`?** If not, the problem is on the phone, not the core:

1. **VoLTE is not actually enabled on the handset.**
 - Samsung (Android ≥10): not possible without root/vendor system app; CoIMS does **not** work.
 - MediaTek: CoIMS alone is not enough — open the MTK IMS menu via secret code, set `voice_support=1`, check `pcscf_home_policy_list` and `mncmcc check`.
 - Qualcomm: vendor MBN files must allow IMS; CoIMS only covers the Android level.
 - Sysmocom SIM: use the CoIMS method (CoIMS_Wiki). Pixel: run CoIMS once.
 - iPhone: on by default; **do not add an ims APN entry**.
 - Check the toggle: Settings → Cellular → SIM → Voice & Data → VoLTE.
2. **Never hand-select `ims` as the phone's active APN** — `internet` must be active; the phone attaches `ims` on its own. Hand-selecting makes IMS the default/internet APN and breaks everything.
3. **PLMN mismatch = roaming = VoLTE off.** Align network PLMN with the SIM (should not see "R" in the status bar). Use **00101**; private PLMNs (99970, US CBRS 315-010, etc.) have IMS disabled on phones — Apple treats 315-010 as a data-only private network (see §12).
4. Phone APN list: `internet` first (type `default`), then `ims` (type `ims`, nothing else in its fields).
5. IMS domain mismatch: phone uses `ims.mncXXX.mccXXX.3gppnetwork.org` from the SIM's MCC/MNC; SIM/ISIM must match the core's PLMN. Custom IMS domains need ISIM.
6. Phone gave up after failed attempts → **reboot the phone**.

If `ims` attach **does** happen but no REGISTER → §4.

## 4. IMS registration fails (401 / 403 / 408 / 503 / HSS User Unknown)

1. **SIM keys.** Ki and the Operator Key must match the SIM — and the WebUI "Operator Key (OPc/OP)" value must match the selected type (OPc is derived from Ki+OP; pasting the OP value under "OPc" is the #1 mistake, and this repo ships `UE1_OP` in `.env` → select **OP**). IMS auth is AKAv1-MD5 (needs the SIM's IMPI/OPc; SIP clients must support AKAv1-MD5). Ki/OPc/OP triples can be generated with https://github.com/herlesupreeth/kiopcgenerator.
2. `HSS User Unknown` in IMS → IMPU/IMPI not provisioned — add them in the HSS you use (open5gs WebUI: subscriber → IMS section; or the pyHSS WebUI). If the IMPU differs from the IMPI, the IMPU must **also** be added to the implicit set.
3. `503 Service Unavailable` / "select next S-CSCF" → S-CSCF down or no service profile; check `docker logs scscf` and HSS subscription.
4. `+` in MSISDN → 404s/wrong Request-URI. Store and dial MSISDN without `+`; avoid leading zeros in MSISDN.
5. REGISTER Request-URI must be `sip:ims.mncXXX.mccXXX.3gppnetwork.org`. SCSCF URI in HSS must be exactly `sip:scscf.ims.mnc001.mcc001.3gppnetwork.org:6060` (3-digit MNC).
6. Both UEs must be registered before you can call/SMS each other — 404 on INVITE to an unregistered party is expected IMS behaviour.
7. P-CSCF↔PCRF (Diameter **over TCP**) not connected → Rx fails. `STATE_SUSPECT` PCRF = stale duplicate P-CSCF from old containers → `docker system prune -f`. Note: `sa-vonr-deploy` intentionally disables the P-CSCF Rx interface (`DEPLOY_MODE=5G`) as N5 interface is used.
8. Stuck at 401 with a SIP client (not phone): client must support AKAv1-MD5; with pyHSS, the SIP password goes in the `Ki` field per pyHSS docs.
9. Debug: enable in `pcscf.cfg` by changing `##!define WITH_DEBUG` to `#!define WITH_DEBUG` (exactly one `#` before `!define`), then re-deploy.
10. **Softphones / SIP clients** (Zoiper, Linphone, Baresip, sipp): in pyHSS, username = IMSI, password = the `Ki` value; P-CSCF address = FQDN `sip:ims.mncXXX.mccXXX.3gppnetwork.org` (never a hardcoded IP); MNC is zero-padded to 3 digits (01 → `mnc001`); no `+` on MSISDN; for pure softphone calling, disable `WITH_RX` in pcscf.cfg (no QoS — calls to COTS UEs may still fail because UEs require QoS); IMS ignores the MSISDN programmed on the SIM — the HSS supplies it.

## 5. Call fails / drops / one-way audio

Work the list in order — each row is a distinct root cause:

1. **Dedicated bearer for the call?** In the pcap, after INVITE: create bearer (4G) / QoS flow with **QCI-1 / 5QI-1** (QCI-2 for video). Missing ⇒ QoS not provisioned: Rx path active (see §4 item 7) **and** QCI 1 (and 2 for video, ARP 4) present in WebUI for **both** subscribers. The dedicated bearer is created **during** the call, never before — no bearer while registered is normal.
2. **Radio instability** (lates/underflow in eNB/gNB, UE released mid-call, then CS-fallback detach): §10.
3. **IPSec/NAT**: SIP works but no ESP after the 401 → kamailio's `ims_ipsec_pcscf` has **no NAT traversal**: with NAT, P-CSCF builds the SA against the docker-host IP while the UE builds it against its own IP ⇒ ESP never matches. This is a limitation in kamailio's IMS implementation.
4. **Called party not registered in IMS** → 404.
5. **iPhone call quirks**: no INVITE sent → set `tcp_connection_lifetime 1` in `kamailio_pcscf.cfg`; 486 Busy Here or odd mid-call behaviour → try disabling NATPING (`##!define WITH_NATPING`).
6. **Bitrates**: GBR/MBR in the E-RAB = SDP `AS` value × 2 (open5gs behaviour). Change via WebUI QCI 1/2 PCC rules, or `rs_default_bandwidth`/`rr_default_bandwidth` in pcscf (ims_qos), or the AS value in the phone's IMS menu. GBR/MBR must be set to real values ("unlimited" won't create the dedicated bearer).
7. **Video calls**: supported on latest commits (added 2026) — pull + rebuild `ims_base` if yours is old. Pixel/Xiaomi may route "video call" to Google Meet/Dialer; iPhone↔iPhone uses FaceTime, not ViLTE.

## 6. SMS

- **Which path?** 4G: SMS over SGs (osmoHLR+osmoMSC — only in 4G deploy files) + SMS over IMS is supported. 5G: SMS over IMS (no osmoMSC in sa-vonr — by design).
- Dial the **MSISDN exactly as stored in HSS** (no `+`); **both** UEs must be IMS-registered first.
- No SMS to an unregistered recipient: 2 retries then dropped — by design, no buffering.
- MO-SMS carries the SMSC number (`tel:+7…`) in the Request-URI — normal; routing uses the MSISDN in the payload.
- Long/concatenated SMS: not supported (no UDH).
- SGs: verify UE registration with `show subscriber cache` in osmoMSC telnet. STP log noise is harmless.

## 7. VoWiFi / ePDG / SWu

- Deploy with the VoWiFi files; test with `swu_client.yaml`. README has the VoWiFi test section.
- **ePDG auth failures** (latest strongswan-epdg forces EAP-AKA): COTS UE → CoIMS Expert Mode, set the ePDG FAP/FQDN and `epdg_authentication_method_int` (try 0, then 1). "Configured EAP-only authentication but peer doesn't support it" = phone-side setting.
- **Decrypting the IKEv2 exchange**: the ePDG dumps IPSec keys to `/wireshark_keys` in the container → keys for Wireshark.
- **PCC rules must also be provisioned under the `internet` APN** (same set as `ims`) — required for VoWiFi calling.
- Known limitation: osmo-epdg uses the Linux-kernel GTP module = **one GTP-U tunnel per UE IP** → dedicated bearer for the call is not possible; calling works over the default bearer via `fix_vowifi_qos_provisioning` branch.
- OP/OPc: same rule as §4 item 1 — the Operator Key value must match the selected OPc/OP type.

## 8. RAN can't reach the core (multi-host)

See §1 table. The recurring recipe:

| Value | Must be |
|---|---|
| `mme_addr` / `amf.addr` (in RAN cfg) | **host** IP running docker_open5gs |
| `gtp_bind_addr`, `s1c_bind_addr`, `bind_addr` | RAN host's IP |
| `SGWU_ADVERTISE_IP` / `UPF_ADVERTISE_IP` (core) | core host's IP |
| docker networking for RAN (external) | `network_mode: host` or published SCTP/GTP ports |
| gNB in docker on machine 2 | don't — run bare metal ("mess with NATing") |

Two docker-ce installs (snap+apt) break things — keep one.

## 9. Deploy / build / image problems

1. Latest commits + clean redeploy (§0 step 2) fixes most of it.
2. **DB schema drift** after `git pull`: `docker volume rm docker_open5gs_dbdata` (shared by pyHSS + Kamailio) or `drop database ims_hss_db; drop database pcscf;` then redeploy. For OpenSIPS: drop `opensips_pcscf`.
3. Base images pin upstream commits: rebuild them when the pins moved — e.g. `ims_base`: `cd ims_base && docker build --no-cache --force-rm -t docker_kamailio .` (same for the srsRAN/open5gs/osmoMSC images; build commands in the README).
4. `open5gs-dbctl` or the WebUI for adding subscribers; pyHSS WebUI otherwise.
5. WebUI address: `http://127.0.0.1:9999` (not 127.0.1.1).
6. YAML errors after hand-editing compose files — re-check indentation.
7. OAI RAN images: not actively maintained; `docker_oai_ue` never had a Dockerfile.
8. `xt_RTPENGINE missing` warning = harmless (userspace forwarding fallback).

## 10. SDR / radio instability (lates, under/overflow, repeat attach)

1. **CPU performance mode** on the RAN host (the single most common fix):
 - AMD: `sudo cpupower frequency-set -g performance`
 - Intel: `GOVERNOR="performance"` in `/etc/default/cpufrequtils`; BIOS: disable C-states/P-states/hyperthreading; kernel args `intel_pstate=disable processor.max_cstate=1 intel_idle.max_cstate=0 idle=poll`; blacklist `intel_powerclamp`; verify with `i7z` (constant frequency, C0 only).
2. **Reduce BW** for weak CPUs: `n_prb = 25` (5 MHz) in enb.conf; srate = 11.52 × (BW/10) MHz — 30 MHz ⇒ 34.56 (PRACH errors: try 46.08); note most phones don't support 30 MHz TDD.
3. **Clock drift** → repeat attach/detach, flaky RF: external GPSDO (Leo Bodnar) into the 10 MHz ref; `clock=external` in enb.conf (USRP) or the SoapySDR equivalent (BladeRF). B210's internal GPSDO is *not* the same thing.
4. **Band**: avoid locally congested LTE bands (B3/B4); band 7 (`dl_earfcn 3350`) for LTE; owner uses `dl_arfcn 650000` (n78) for 5G. Xiaomi SA toggle: `*#*#726633#*#*`. Force 5G: `*#*#4636#*#*` → "NR only".
5. B210mini: max ~50 MHz BW; a Ryzen 5825U runs it fine.
6. B210 power: USB3 supply is sufficient; no external PSU needed.
7. iPhone + 5G SA: SIM needs the private-5G files (`sim/iphone-private-5g.script`, ADM key) + AMF NAS encryption order + gNB user-plane encryption (`cu_cp security --nea_pref_list=nea2,nea1,nea3,nea0`); private-PLMN iPhones are restricted to private NR bands (US: band 41). Blacklist bypass: attach once with the SIM on 99970, then reprogram the SIM to 00101 and the network accepts it.
8. ZMQ lab setup (gNB↔Gnuradio↔UE): ZMQ ports 5000/6001/6000/5001, run the Gnuradio flowgraph on the host, start core → gNB → UE; the port diff needs no image rebuild.
9. **Throughput tuning (5G)**: 20 MHz ≈ 50 Mbps DL / 14 Mbps UL on B210; `max_ue_mcs` caps UL; DL-optimised TDD `nof_dl_symbols: 7, nof_dl_slots: 7, nof_ul_slots: 2`; MIMO (`mimo_usrp.yml`) + `qam256` for more; low latency (`low_latency.yml`) ≈ 15 ms E2E; check the phone's supported BW in the UE Capabilities packet.
10. **Modems as UEs** (Quectel RM520N-GL works; AG521/AG566N flaky): manage with `mmcli` (`-L`, `--3gpp-scan`, `--simple-connect="apn=internet"`); check RAT modes; GPSDO + `clock`/`sync` in gNB cfg; B210 gains tx 80 / rx 40; 20 MHz BW; `minicom` AT fallback; if the modem requests APN `default`, add a `default` APN in the WebUI.

## 11. Harmless — do NOT chase these

| Log | Why it's fine |
|---|---|
| `clean_sa(): Error sending delete SAs command via netlink: No data available` / `ipsec_cleanall()` at startup | No SAs exist yet at boot |
| `nghttp2... Could not read private key file` | TLS-in-nghttp2 module, unused here |
| `Unknown PCO ID (0x23)` | Warning only; attach proceeds |
| `Unknown UE by SUCI`, `UE Context Release` after inactivity | UE went IDLE — normal; traffic wakes it |
| `Invalid packet [IP version:6...]` | Router Solicitation from an IPv4v6 address; restrict to IPv4-only if noisy |
| RRC Release with no traffic | IDLE transition, power saving |
| `xt_RTPENGINE` missing | Userspace forwarding fallback |
| osmoMSC STP warnings | Noise |
| osmo-epdg QoS errors | Observed, did not affect calling |

## 12. Not supported / by design (answer at intake)

| Ask | Answer |
|---|---|
| NSA mode | Not supported by open5gs |
| USSD over IMS | Needs XCAP; kamailio's insufficient; not supported |
| SMS buffering for unregistered UE | No; 2 retries then drop |
| SMS concatenation (UDH) | Not supported |
| VoLTE on Samsung without root | Not possible; CoIMS doesn't work |
| VoLTE with ZMQ srsUE | srsUE has no SIP stack; data only, at best VoIP via a separate SIP client |
| IPv6 in Docker | Not supported (README) |
| OpenSIPS IMS | Basic only; no video calls; 5G path broken |
| OAI RAN images | Not actively maintained |
| Per-slice access restriction at the UPF | Not configurable; code change or iptables |
| Device-to-device VoNR calls | N5 merged to master; verified on iPhone 13 Pro + Xiaomi 11T |
| VoNR / VoLTE / voice on private PLMNs (99970, US CBRS 315-010) | Not possible — Apple treats these as data-only private networks ([Apple docs](https://support.apple.com/guide/deployment/support-for-private-5g-and-lte-networks-depac6747317/web)); voice must go via a dual-SIM public carrier or Wi-Fi Calling. VoLTE on iPhone works with the 00101 test PLMN |
| VoWiFi with dedicated bearer | Blocked on osmo-epdg kernel-GTP limitation |
| IMS conferencing | Not in kamailio IMS; use FreeSWITCH as AS or IBCF+trunk for PSTN (5G) |
| Emergency calling | Not supported (no open5gs + IMS logic) |
| Multi-PLMN with IMS | One PLMN per IMS instance; core-only multi-PLMN = add PLMN to mme.yaml/nrf.yaml/amf.yaml |
| N26 / EPS fallback (4G↔5G interworking) | Not in open5gs |
| Kubernetes | No plans |
| RAN on macOS | Not possible (no kernel SCTP); 5GC only via usrsctp fork |
| eNB on RPi | PoC only; osmoMSC broken on RPi (VoLTE works without it) |
| Issues about non-docker_open5gs setups | Open in the right repo |

## 13. Provisioning reference

- **Keys**: the WebUI has one "Operator Key (OPc/OP)" field — the value entered must match the selected type (OPc = MILENAGE derivation from Ki+OP, not a free choice; pasting the OP value under "OPc" is the #1 cause of MAC/EAP-AKA failures). This repo ships `UE1_OP=1111…` in `.env` → select **OP**; the README provisioning example uses the derived OPc → select **OPc**. Either works as long as value and type agree. Reference triple used in most threads: `Ki=8baf473f2f8fd09487cccbd7097c6862`, `OP=11111111111111111111111111111111`, `OPc=8E27B6AF0E692E750F32667A3B14605D`. After any key change: reprogram SIM **and** update WebUI **and** redeploy.
- **Canonical SIM programming** (Sysmocom, PLMN 00101) — adapt ICCID/ADM keys from your Sysmocom sheet:
 ```
./pySim-prog.py -p 0 -x 001 -y 01 -s <ICCID> -i <IMSI> \
 -k <Ki> --op <OP> -o <OPc> -a <ADM> -n exp.zii \
 --msisdn <MSISDN-no-plus> \
 --epdgid epdg.epc.mnc001.mcc001.pub.3gppnetwork.org \
 --pcscf pcscf.ims.mnc001.mcc001.3gppnetwork.org \
 --ims-hdomain ims.mnc001.mcc001.3gppnetwork.org \
 --impi <IMSI>@ims.mnc001.mcc001.3gppnetwork.org \
 --impu sip:<IMSI>@ims.mnc001.mcc001.3gppnetwork.org
 ```
 MSISDN without `+`; the SIM MSISDN is ignored by IMS anyway (HSS supplies it on the fly). iPhone: EF.SUCI_Calc_Info + UST 124 on / 125-126 off (private PLMN), or the repo's `sim/iphone-private-5g.script`.
- **SIM programming**: the pySim-prog.py command must include the IMPI/IMPU/PCSCF/EPDG fields (see the canonical command above). Sysmocom SIMs: disabling the SQN check is not required.
- **WebUI**: select the **OP** radio (repo default); QCI 1 (voice, ARP 1) + QCI 2 (video, ARP 4) under **both** APNs for every calling subscriber; MSISDN without `+` and no leading zero; SCSCF URI `sip:scscf.ims.mnc001.mcc001.3gppnetwork.org:6060`.
- **PLMN**: 00101 (network + SIM aligned). IMS APN type exactly `ims`.
- **SLA/AMBR**: keep the WebUI defaults unless testing QoS specifically.
- **OCS**: provision the same IMSI+MSISDN in the OCS and associate a product; DIAMETER_USER_UNKNOWN (5030) = missing there.
- **UE subnets**: `UE_IPV4_INTERNET` / `UE_IPV4_IMS` in `.env` (then `source .env` + redeploy); avoid overlap with your LAN / docker subnet.
- **MAX_NUM_UE**: core-side only (default 1024; ~2000 UEs in field use); raise `IPSEC_MAX_CONN` in pcscf for more concurrent IPSec sessions.

## 14. Component-specific quick hits

- **MME/AMF**: `Unknown UE by SUCI` after IDLE = normal; `esm ERROR Invalid APN[ia]` = phone APN mismatch.
- **SMF**: IP allocation is SMF's job, not UPF's — DNN + IP pool in smf.yaml must match; multi-slice: remove TAI from `info:` in smf.yaml, mind AMF/SMF bring-up order; Pre-Release-10 modems: `no_ipv4v6_local_addr_in_packet_filter: true`.
- **P-CSCF**: `DEPLOY_MODE=5G` disables Rx.
- **OCS/SigScale**: OCS advertising Gx+Gy confused the SMF — fixed; use `4g-volte-ocs-deploy.yaml`.
- **srsUE / srslte**: ping from the UE may not wake it from IDLE (srsUE bug); wake from CN side. srsRAN_4G (srslte) ≠ srsRAN_Project (gNB) — don't cross configs. SIP clients inside a srsUE container must bind `tun_srsue` (`ping -I tun_srsue`, iperf `-B`), and ZMQ "VoLTE" is VoIP at best — no dedicated bearer.
- **Ping/iperf from the core**: `docker exec -ti upf bash` → `ping -I ogstun <UE_IP>` (internet APN), `ping -I ogstun2 <UE_IP>` (ims APN); run iperf inside the upf and UE containers.
- **Monitoring**: Prometheus/Grafana for the open5gs NFs at `http://localhost:9090`; gNB KPIs via the srsRAN wiki, separately.
- **eUPF / TAP**: for high throughput use eUPF (`custom_deployments/`) or a TAP interface on the UPF.
- **MME log `Extended service request`**: the UE's IMS call failed and it fell back to circuit-switched — debug the IMS path, not the core.
- **SCP-less 5GC**: remove `scp` under `sbi.client` in every NF yaml (except NRF/SCP) + SCP from compose; `discovery: delegated: no` only changes discovery.
- **4G custom DNN**: edit `smf/smf_4g.yaml` (not smf.yaml) + upf.yaml + upf_init.sh (new ogstunN).
- **External RAN env values**: `SRS_ENB_IP`/`SRS_GNB_IP` = the **RAN host** IP, not a docker-bridge IP; don't bother with usrsctp builds — freeDiameter still needs kernel libsctp.

## 15. FAQ (recurring Discussion questions)

| Question | Answer |
|---|---|
| Can I test without a phone? | RF-simulated: UERANSIM (5G) or srsRAN ZMQ (4G+5G). VoLTE itself needs a COTS UE (or IMSDroid/sipp for registration) |
| Multiple UEs? | UERANSIM: `ue count` increments IMSI (+rebuild image if you change the script); srs setup: separate containers with different IPs; 5G routers: internet APN only (no IMS) |
| How do I change frequencies/BW? | Edit `srsran/gnb.yml` / `srslte/enb.conf` (not AMF_IP/SRS_GNB_IP) + redeploy; no rebuild needed |
| Custom UE IP ranges? | `UE_IPV4_INTERNET` / `UE_IPV4_IMS` in `.env` + `source .env` + redeploy |
| Custom UPF advertise IP? | `UPF_ADVERTISE_IP` in `.env` + `source .env` + redeploy |
| Change MSISDN after provisioning? | pyHSS REST API; avoid while the UE is registered |
| Different date format in NF logs? | No — requires open5gs code change |
| Where is the eNB log? | `srslte/` folder on the host (not in the container) |
| rtpproxy instead of rtpengine? | No — rtpproxy can't be used with this P-CSCF |
| Why does my phone show "R" with an ims APN attached? | Roaming (SIM PLMN ≠ network PLMN) or the SIM does not have the network PLMN configured in its EHPLMN → VoLTE disabled by the UE |
| Can two docker_open5gs sites talk? | No call handover between IMS instances; IBCF exists for PSTN trunking (5G) |
| Where do the QoS values come from? | UE+IMS negotiate SDP → P-CSCF asks PCRF/PCF (Rx) → your WebUI PCC rules authorise/deny it |
| OAI 5GC + this IMS? | Needs N5 on the OAI PCF + SMF advertising the P-CSCF IP in NAS |
| pyHSS as HSS+PCRF? | Possible; but PCRF functionality is not tested/supported in this repo |
