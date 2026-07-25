FROM node:22-alpine AS web-assets

WORKDIR /build
COPY web/package.json web/pnpm-lock.yaml ./
RUN npm install --global pnpm@11.9.0 --no-audit --no-fund \
    && pnpm install --prod --frozen-lockfile

FROM alpine:3.22

RUN apk add --no-cache \
      ca-certificates \
      curl \
      ffmpeg \
      fuse3 \
      nginx \
      python3 \
      rclone \
      shadow \
      su-exec \
      tini \
      util-linux \
    && addgroup -g 1000 -S torbox \
    && adduser -u 1000 -S -D -H -G torbox torbox

WORKDIR /opt/torbox
COPY torbox ./torbox
COPY web/plex-torbox.js web/plex-torbox.css ./web/
COPY --from=web-assets /build/node_modules/hls.js/dist/hls.min.js ./web/hls.min.js
COPY nginx.conf /etc/nginx/nginx.conf
COPY entrypoint.sh /usr/local/bin/plex-torbox

RUN chmod 0755 /usr/local/bin/plex-torbox \
    && mkdir -p \
      /data/torbox \
      /tmp/nginx/client \
      /tmp/nginx/fastcgi \
      /tmp/nginx/proxy \
      /tmp/nginx/scgi \
      /tmp/nginx/uwsgi \
    && chown -R torbox:torbox /data/torbox /tmp/nginx

ENV PYTHONPATH=/opt/torbox \
    TORBOX_DATA_DIR=/data/torbox

ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/plex-torbox"]
