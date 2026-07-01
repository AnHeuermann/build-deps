#!/usr/bin/env python3
"""Prune stale versions of the build-deps container package on GHCR.

A moving tag (e.g. ubuntu-24.04) is keyed to an image *digest*. When it is
rebuilt the tag moves to a new digest, leaving the old digest as an untagged
manifest, and the cosign signature that was attached to it (a
`sha256-<digest>[.sig]` referrer artifact) now points at an image no tag
references. Over time these accumulate and clutter the package's versions page.

This script deletes, for the container package:
  * untagged manifests that no live tag references, and
  * cosign signature / referrer artifacts whose target image is gone.

It KEEPS every real, human-readable tag (ubuntu-24.04, ubuntu-24.04-clang-2.1.0,
...) and everything reachable from one: multi-arch child manifests, build
attestations, and signatures whose target is still tagged. Reachability is read
from the registry with `crane`, so live multi-arch / attestation children are
never mistaken for orphans.

Environment:
  GH_TOKEN  token with read+write:packages (used by `gh` and, via the docker
            config written by docker/login-action, by `crane`)
  ORG       GitHub org / owner              (default: OpenModelica)
  PACKAGE   container package name          (default: build-deps)
  REGISTRY  full image ref base             (default: ghcr.io/<org>/<package>)
  DRY_RUN   "true" -> only report, delete nothing
"""
import json
import os
import re
import subprocess
import sys

ORG = os.environ.get("ORG", "OpenModelica")
PACKAGE = os.environ.get("PACKAGE", "build-deps")
REGISTRY = os.environ.get("REGISTRY", f"ghcr.io/{ORG.lower()}/{PACKAGE}")
DRY_RUN = os.environ.get("DRY_RUN", "false").lower() == "true"

VERSIONS_API = f"/orgs/{ORG}/packages/container/{PACKAGE}/versions"
# A cosign signature / referrer fallback tag: sha256-<64 hex>[.sig|.att|.sbom].
REFERRER_RE = re.compile(r"^sha256-([0-9a-f]{64})(?:\.(?:sig|att|sbom))?$")


def gh_api(*args):
    return subprocess.run(
        ["gh", "api", *args], check=True, capture_output=True, text=True
    ).stdout


def list_versions():
    # --paginate --slurp returns a list of per-page arrays; flatten it.
    pages = json.loads(gh_api("--paginate", "--slurp", f"{VERSIONS_API}?per_page=100"))
    return [v for page in pages for v in page]


def tags_of(v):
    return v.get("metadata", {}).get("container", {}).get("tags") or []


def manifest(digest):
    """Parsed manifest for a digest, or {} if it can't be fetched."""
    try:
        raw = subprocess.run(
            ["crane", "manifest", f"{REGISTRY}@{digest}"],
            check=True, capture_output=True, text=True,
        ).stdout
    except subprocess.CalledProcessError:
        return {}
    return json.loads(raw) if raw.strip() else {}


def children(m):
    """Child digests of a manifest index (empty for a plain image manifest)."""
    return [x["digest"] for x in m.get("manifests", []) if "digest" in x]


def main():
    versions = list_versions()

    # 1. Everything reachable from a real (non-referrer) tag: the tag's target
    #    digest plus any index children (multi-arch platforms, attestations).
    live = set()
    for v in versions:
        if any(not REFERRER_RE.match(t) for t in tags_of(v)):
            digest = v["name"]
            live.add(digest)
            live.update(children(manifest(digest)))

    # 2. Decide what to prune.
    to_delete = []
    for v in versions:
        digest, tags = v["name"], tags_of(v)
        if digest in live:
            continue
        if any(not REFERRER_RE.match(t) for t in tags):
            continue  # has a real tag (defensive; should already be live)
        if tags:
            # Only referrer / signature tags: keep while their target is live.
            targets = {f"sha256:{REFERRER_RE.match(t).group(1)}" for t in tags}
            if targets & live:
                continue
            reason = f"orphaned signature for {', '.join(sorted(targets))}"
        else:
            # Untagged: could be an OCI 1.1 referrer whose subject is still live.
            subject = manifest(digest).get("subject", {}).get("digest")
            if subject and subject in live:
                continue
            reason = "untagged, unreferenced"
        to_delete.append((v, reason))

    if not to_delete:
        print("Nothing to prune.")
        return 0

    for v, reason in to_delete:
        label = ", ".join(tags_of(v)) or "<untagged>"
        action = "Would delete" if DRY_RUN else "Deleting"
        print(f"{action} {v['name']} [{label}] - {reason}")
        if not DRY_RUN:
            gh_api("--method", "DELETE", f"{VERSIONS_API}/{v['id']}")

    print(f"{'Would prune' if DRY_RUN else 'Pruned'} {len(to_delete)} version(s).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
