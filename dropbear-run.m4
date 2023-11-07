#!/bin/sh
exec 2>&1
ROOT="$(dirname $0)"
exec dropbear \
    -r $ROOT/dropbear_rsa_host_key \
    -r $ROOT/dropbear_ecdsa_host_key \
    -r $ROOT/dropbear_ed25519_host_key \
    -E -p SSHPORT -P $ROOT/dropbear.PID
