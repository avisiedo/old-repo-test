#!/bin/bash

set -e
set -x

if ! grep -F "Dockerfile.$dockerfile" <( echo "$BUILD_DOCKERFILES" ) ; then
	echo "Skipping, Dockerfile.$dockerfile not modified."
	exit
fi

docker build -t local/freeipa-server -f Dockerfile.$dockerfile .
docker run $privileged -h ipa.example.test \
	--sysctl net.ipv6.conf.all.disable_ipv6=0 \
	--tmpfs /run --tmpfs /tmp -v /dev/urandom:/dev/random:ro -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
	-e PASSWORD=Secret123 local/freeipa-server \
	exit-on-finished -U -r EXAMPLE.TEST --setup-dns --no-forwarders --no-ntp