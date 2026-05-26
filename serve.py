#!/usr/bin/env python3
"""Local static server for `docs/` — same layout GitHub Pages will host.

Usage:  python3 serve.py [PORT]    (default 8090)

COOP/COEP headers (required for SharedArrayBuffer) are injected client-side
by `docs/coi-serviceworker.min.js`, so no special headers are needed here.
"""
import http.server
import sys
from functools import partial
from pathlib import Path

PORT = int(sys.argv[1]) if len(sys.argv) > 1 else 8090
DIRECTORY = Path(__file__).resolve().parent / "docs"

handler = partial(http.server.SimpleHTTPRequestHandler, directory=str(DIRECTORY))
with http.server.ThreadingHTTPServer(("", PORT), handler) as httpd:
    print(f"Serving {DIRECTORY} at http://localhost:{PORT}")
    httpd.serve_forever()
