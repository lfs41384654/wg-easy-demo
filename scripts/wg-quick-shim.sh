#!/bin/bash
# wg-quick shim for wg-easy on a container whose netns is the host's.
# The host already brings wg0 up (wg-quick up wg0 on the runner host).
# Inside the container wg-easy only needs to push peer config, which
# `wg syncconf` does without ever calling `ip`.
ACT="${1:-}"
IFACE="${2:-}"
REAL=/usr/bin/wg-quick.real

case "$ACT" in
  up)
    if [ ! -e "/sys/class/net/$IFACE" ]; then
      echo "[shim] interface $IFACE missing - host did not bring it up" >&2
      exit 1
    fi
    if /usr/bin/wg syncconf "$IFACE" <("$REAL" strip "$IFACE"); then
      echo "[shim] syncconf $IFACE ok"
      exit 0
    fi
    echo "[shim] syncconf $IFACE failed" >&2
    exit 1
    ;;
  down)
    echo "[shim] down requested for $IFACE - keeping interface alive"
    exit 0
    ;;
  *)
    exec "$REAL" "$@"
    ;;
esac