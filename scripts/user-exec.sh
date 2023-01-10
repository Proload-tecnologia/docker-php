#!/bin/sh
if [ $(id -u) -eq 0 ]; then
    su-exec "${USER_ID}:${GROUP_ID}" "$@"
else
    exec "$@"
fi
