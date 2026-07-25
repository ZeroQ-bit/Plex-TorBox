#!/bin/sh
set -eu

role="${TORBOX_ROLE:-gateway}"

case "${role}" in
  gateway)
    mkdir -p \
      /data/torbox \
      /tmp/nginx/client \
      /tmp/nginx/fastcgi \
      /tmp/nginx/proxy \
      /tmp/nginx/scgi \
      /tmp/nginx/uwsgi
    touch /tmp/nginx/error.log
    chown -R torbox:torbox /data/torbox /tmp/nginx
    su-exec torbox tail -n 0 -f /tmp/nginx/error.log >&2 &
    nginx_log_pid="$!"
    su-exec torbox python3 -m torbox.service &
    api_pid="$!"
    cleanup() {
      kill "${api_pid}" "${nginx_log_pid}" 2>/dev/null || true
      wait "${api_pid}" "${nginx_log_pid}" 2>/dev/null || true
    }
    trap cleanup EXIT INT TERM
    su-exec torbox nginx -e /tmp/nginx/error.log -g "daemon off;"
    ;;
  mount)
    exec python3 -m torbox.mount
    ;;
  *)
    echo "Unsupported TORBOX_ROLE: ${role}" >&2
    exit 64
    ;;
esac
