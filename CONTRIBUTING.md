# Contributing

Contributions are welcome when they preserve Plex TorBox's privacy and mount
safety guarantees.

Before opening a pull request:

1. Do not include Plex binaries, Plex Web bundles, credentials, signed URLs,
   magnets, info hashes, user databases, server logs, or media.
2. Keep Plex and TorBox credentials server-side.
3. Preserve compatibility for `/vortexo/api`, `VORTEXO_*`, persistent data
   paths, and the existing mount ownership marker.
4. Run:

   ```sh
   python3 -m unittest discover -s tests -v
   python3 -m compileall -q vortexo
   node --check web/plex-vortexo.js
   sh -n entrypoint.sh
   ```

5. Explain user impact, upgrade behavior, and security implications in the pull
   request.

Changes that weaken foreign-mount refusal, secret redaction, owner
authentication, or non-destructive library behavior will not be accepted.
