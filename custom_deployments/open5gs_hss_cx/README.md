## Deployment description

This custom deployment showcases using of open5gs HSS for Cx interface (towards ICSCF/SCSCF) rather than using pyHSS.

## Limitation

In order to change the iFCs or any other IMS service related provisioning information one need to modify the code and re-compile open5gs i.e. no way to configure them via GUI as we have with pyHSS.

## Additional steps

Most of the steps to be followed are similar to the steps mentioned in the [README in the root folder](../../README.md). However, additional steps mentioned below must be taken into account while deploying this custom deployment scenario.

### Loading environmental variables for custom deployment

**Warning**
For custom deployments, you must modify/use only the [**.custom_env**](.custom_env) file rather than the [**.env** in the root folder](../../.env).

```
set -a
source .custom_env
set +a
```

### Scenario deployment

Deploy the 4G EPC + IMS.

```
cd custom_deployments/open5gs_hss_cx
docker compose -f 4g-volte-deploy.yaml up
```

Deploy srsRAN eNB using SDR (OTA)

```
docker compose -f srsenb.yaml up -d && docker container attach srsenb
```
