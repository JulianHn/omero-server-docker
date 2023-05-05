#!/bin/bash

set -eu

omero=/opt/omero/server/venv3/bin/omero
omego=/opt/omero/server/venv3/bin/omego

DH2048File="/OMERO/certs/dhkey_2048bit.pem"
IceDHConfig="/OMERO/certs/iceDHconfig.DER"

mkdir -p "/OMERO/certs"

if ! [[ -f $DH2048File ]]; then
  openssl dhparam -outform PEM -out $DH2048File 2048
fi

if ! [[ -f $IceDHConfig ]]; then
  openssl dhparam -outform DER -out $IceDHConfig 2048
fi


omero config set omero.glacier2.IceSSL.DH.2048 $DH2048File
omero config set omero.glacier2.IceSSL.DHParams $IceDHConfig



