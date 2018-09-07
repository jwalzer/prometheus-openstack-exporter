#!/bin/bash

echo "starting prometheus-openstack-exporter Image: $DOCKER_IMAGE_VERSION"

[[ -r /TrustLetsEncryptStagingFakeRootCertificate ]] && cat <<EOT

ATTENTION!
===========

This container probably trusts the Lets-Encrypt Staging RootCA!

There is no strong security on that!

EOT

#shellcheck disable=SC1091
. /etc/openstack/admin-openrc.sh

mkdir -p "$PROMOE_CACHEDIR"

[[ "nowait" == "$1" ]] || sleep "$((RANDOM % SLEEP_SPREAD ))" # try to spread multiple different instances in time

prometheus-openstack-exporter /etc/prometheus-openstack-exporter/prometheus-openstack-exporter.yaml

