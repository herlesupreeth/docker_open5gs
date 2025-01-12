## Deployment description

This custom deployment uses eUPF (https://github.com/edgecomllc/eupf) rather than open5gs UPF for 5G SA network deployment

## Additional steps

Most of the steps to be followed are similar to the steps mentioned in the [README in the root folder](../../README.md). However, additional steps mentioned below must be taken into account while deploying this custom deployment scenario.

### Build docker images for eUPF

eUPF docker image needs to be built before deploying

```
cd ../../eupf
docker build --no-cache --force-rm -t docker_eupf .
```

### Loading environmental variables for custom deployment

**Warning**
For custom deployments, you must modify/use only the [**.custom_env**](.custom_env) file rather than the [**.env** in the root folder](../../.env).

```
set -a
source .custom_env
set +a
```
