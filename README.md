# Plex TorBox

Plex TorBox is an unofficial, self-hosted Plex Web and Umbrel companion for
private TorBox streaming, Plex Watchlist acquisition, and safe library
handoff.

It proxies an existing Plex Web installation and injects local JavaScript and
CSS into `/web/index.html`. It does not distribute or modify Plex Media Server
or Plex's hashed web bundles. Completed media is linked into ordinary Plex
libraries, so it remains available to stock Plex clients.

> Plex TorBox is not affiliated with or endorsed by Plex, TorBox, or Umbrel.
> Plex is a trademark of Plex, Inc.

## Roles

- `VORTEXO_ROLE=gateway` starts the owner-authenticated API on loopback and an
  unprivileged Nginx gateway on port `32500`. Nginx proxies Plex on `32400` and
  injects the local JavaScript and CSS only into `/web/index.html`.
- `VORTEXO_ROLE=mount` starts the privileged rclone supervisor on loopback port
  `32501`. The gateway API uses loopback port `32502`. The supervisor mounts
  TorBox WebDAV read-only at `/downloads/.vortexo-source` and refuses any mount
  it did not create.

Settings, signed playback URLs, resume progress, and library jobs live in the
private SQLite data directory. Browser responses never contain the TorBox key,
Plex token, magnet, info hash, manifest request headers, or raw signed URL.

## API

The owner session is established by `PUT /vortexo/api/session`. The gateway
accepts the Plex Web token only when Plex confirms it belongs to the same
account as the owner token in `Preferences.xml`, then sets an HTTP-only cookie.

- `GET /vortexo/api/status`
- `GET|PUT /vortexo/api/settings`
- `GET /vortexo/api/watchlist`
- `POST /vortexo/api/watchlist/sync`
- `GET /vortexo/api/discover/{id}`
- `GET /vortexo/api/discover/{id}/episodes`
- `POST /vortexo/api/streams`
- `POST /vortexo/api/play`
- `POST /vortexo/api/progress`
- `POST /vortexo/api/library-jobs`
- `GET /vortexo/api/library-jobs/{id}`

## Native Plex clients

The optional Plex Watchlist coordinator runs entirely on the server. It reads
the owner's universal Watchlist at a configurable interval, skips titles
already present in a local Plex library or an active job, and selects a cached
addable release using the saved Best, 4K, or 1080p profile and maximum-size
limit. Movies are acquired directly. A newly requested TV show safely starts
with its first regular episode rather than silently acquiring an entire series.

Every selected release uses the same persistent library-job state machine as
the manual Add to Plex action. Completed media is ordinary Plex library media,
so it appears in native Plex clients without modifying those clients. Removing
a title from the Plex Watchlist never deletes an existing file or Plex item.

## Compatibility

The `/vortexo/api` routes, `VORTEXO_*` environment variables, persistent data
paths, and existing mount ownership marker intentionally keep their original
names. Renaming them would break upgrades from Plex (Vortexo) installations.
They are implementation details, not the current project name.

## Umbrel

The `umbrel/zeroq-plex` directory contains the companion Umbrel package
definition. The app ID remains `zeroq-plex` so existing installations can
upgrade without losing their Plex database or settings. The canonical
community-store manifest continues to live in
[ZeroQ-bit/Umbrel-Store](https://github.com/ZeroQ-bit/Umbrel-Store).

## Verification

Run:

```sh
python3 -m unittest discover -s tests -v
python3 -m compileall -q vortexo
node --check web/plex-vortexo.js
sh -n entrypoint.sh
```

The image workflow publishes `main` and commit-SHA tags to
`ghcr.io/zeroq-bit/plex-torbox`. The Umbrel Store updater must resolve the
published `main` tag to an immutable digest before a store release.

## Live handoff

Do not overlap this mount with Orbit. Stop Orbit's mount role first, prove
`.vortexo-source` is no longer a mountpoint and is empty, and only then start
Plex TorBox. The pre-start hook and mount supervisor repeat these checks and
will not detach a foreign mount.

Keep the previous Plex package and the stopped Orbit installation available
until cached playback and an Add to Plex job both pass through Plex
confirmation. Port `32400` remains the unchanged native-client fallback.

## Security and privacy

- TorBox and Plex credentials remain server-side.
- Browser responses redact signed URLs, request headers, magnets, info hashes,
  and account tokens.
- The mount supervisor refuses mounts it does not own.
- No Plex binaries, Plex Web bundles, credentials, databases, or user media are
  included in this repository.

Please report vulnerabilities privately as described in
[SECURITY.md](SECURITY.md).

## Responsible use

Use Plex TorBox only with media and services you are legally authorized to
access. You are responsible for complying with the terms of Plex, TorBox,
stream-manifest providers, and applicable law.

## License

Plex TorBox is licensed under the
[GNU Affero General Public License v3.0](LICENSE).
