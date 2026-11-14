## Deployment description

This custom deployment adds [Open Exposure NEF](https://gitlab.eurecom.fr/open-exposure/nef/as-session-with-qos)
to the Open5GS 5G SA core. It exposes the AS Session with QoS API and connects
directly to the PCF over HTTP/2.

Follow the [root README](../../README.md) to prepare the Open5GS image and
configure the host. The additional steps are listed below.

### Build the Open Exposure NEF image

From the repository root:

```sh
docker build --no-cache --force-rm -t openexposure_nef ./openexposure_nef
cd custom_deployments/openexposure_nef
```

### Configure and deploy

Use this directory's [`.custom_env`](.custom_env) for the core and NEF addresses.
The API is available at `127.0.0.1:8089` by default. Change `NEF_BIND_IP` and
`NEF_BIND_PORT` for remote access. CAPIF is disabled in this configuration.

The QoS profiles are defined in
[`asSessionWithQos.yaml`](../../openexposure_nef/asSessionWithQos.yaml).

```sh
docker compose --env-file .custom_env -f sa-deploy.yaml up -d
docker compose --env-file .custom_env -f sa-deploy.yaml logs -f openexposure_nef pcf
```

To run only NEF and its PCF dependencies, append `openexposure_nef` to the
`up` command. Stop the deployment with:

```sh
docker compose --env-file .custom_env -f sa-deploy.yaml down
```

See [validation](VALIDATION.md) for the sample request and RAN compatibility.
