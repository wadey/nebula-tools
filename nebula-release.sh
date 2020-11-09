#!/bin/bash
set -e

case "$(uname -m)" in
    aarch64) ARCH="arm64" ;;
    x86_64)  ARCH="amd64" ;;
esac

FILE="nebula-$(uname | tr '[:upper:]' '[:lower:]')-$ARCH.tar.gz"
BINDIR="/usr/local/bin"

if [ -f "$BINDIR/nebula" ]
then
    CURRENT="v$($BINDIR/nebula -version | cut -d' ' -f2)"
else
    CURRENT=""
fi

TEMPDIR="$(mktemp -d)"
trap 'rm -rf "$TEMPDIR"' exit
cd "$TEMPDIR"

curl -s "https://api.github.com/repos/slackhq/nebula/releases/latest" >latest.json
LATEST="$(jq -r .tag_name latest.json)"

if [ "$CURRENT" = "$LATEST" ]
then
    echo "Already on latest release: $LATEST"
    exit 0
fi

if [ -z "$CURRENT" ]
then
    echo "Installing $LATEST"
else
    echo "Upgrading from $CURRENT -> $LATEST"
fi

URL="$(jq -r '.assets[] | select(.name == "'"$FILE"'").browser_download_url' latest.json)"

curl -L -o "$FILE" "$URL"
tar -zxf "$FILE"

sudo install nebula nebula-cert "$BINDIR"

"$BINDIR/nebula" -version
