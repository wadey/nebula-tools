#!/usr/bin/env bash
#
# sign.sh lets you use any server you can SSH to as a remote CA server, which
# also keeps a directory of all certs that have been issued. Useful for personal
# networks.
#
# Example:
#
#   nebula-cert keygen -out-pub host.pub -out-key host.key
#   ssh remote nebula-tools/sign.sh my-host 10.255.255.1/24 my,groups <host.pub >host.crt

set -e -u -o pipefail

cd ~/nebula-tools

NAME="$1"
IP="$2"
CERT_GROUPS="$3"

cat >"hosts/$NAME.pub"

./nebula-cert sign -ca-crt ca.crt -ca-key ca.key -groups "$CERT_GROUPS" -name "$NAME" -out-crt "hosts/$NAME.crt" -in-pub "hosts/$NAME.pub" -ip "$IP"

cat "hosts/$NAME.crt"
