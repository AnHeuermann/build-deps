# OpenModelica build-deps Docker Images

[![Build, Release & Publish][badge-build-img]][workflow-build]

The Docker images used to build and deploy
[OpenModelica][openmodelica] with
[Jenkins][jenkins].

Images are published to:

- `ghcr.io/openmodelica/build-deps` (GitHub Container Registry)
- `docker.openmodelica.org/build-deps` (Nexus)

## Structure of the Repository

Every image lives on `main`, keyed by **operating system and OS version** rather
than by OpenModelica version. Each image is a **base** plus optional, layered
**add-ons**, so the heavy common tooling is built once and reused.

```text
main
├── ubuntu/
│   └── Dockerfile          # multi-stage: ALL Ubuntu versions + add-ons
├── debian/Dockerfile       # placeholder (not implemented yet)
├── almalinux/Dockerfile    # placeholder (not implemented yet)
├── arch/Dockerfile         # placeholder (not implemented yet)
└── .ci/
    ├── matrix.yml          # source of truth: which images exist
    ├── matrix.py           # matrix.yml -> CI matrix / tag lookup
    └── publish.sh          # build + push one image (base + add-ons)
```

> **Status:** only the **Ubuntu** images are implemented. Debian, AlmaLinux and
> Arch are empty placeholders (an `<os>/Dockerfile` with a TODO header) and are
> intentionally left out of [.ci/matrix.yml][matrix-yml] until implemented,
> so CI does not try to build them.

- **Base image** — one per OS/OS-version. Contains everything needed to build
  OpenModelica (distro packages + common tooling: TeX, Qt, Python venv,
  ccache, …). This is what most CI jobs use.
- **Add-on image** — the base plus *one* thing the distro package manager can't
  provide or that needs a pinned version (e.g. CMake 4). Realised as an extra
  build **stage** (`FROM` the base stage) in the same Dockerfile, so shared
  layers are reused from cache.

Every OS uses a single **multi-stage** Dockerfile at `<os>/Dockerfile` covering
all of its versions (the Debian/AlmaLinux/Arch placeholders follow this too).
All Ubuntu versions build from [ubuntu/Dockerfile][ubuntu-dockerfile]:

- the FROM tag is set by the `UBUNTU_VERSION` build-arg, and the Qt package set
  is picked from the image's `VERSION_ID` at build time;
- the base image is the `full` stage (`--target full`);
- each add-on is a further stage (e.g. `--target cmake-4`).

Each image's `context`, `dockerfile`, `target`, `build_args` and `addons`
(add-on stage names) are declared in [.ci/matrix.yml][matrix-yml].

To add a new image, create or extend the OS's `<os>/Dockerfile` and list it in
[.ci/matrix.yml][matrix-yml] (a new version of an existing OS needs only a
matrix entry).

### Image naming & tags

One image repository per registry; OS, version and variant are encoded in the
**tag**:

| Tag | Mutable? | Meaning |
| --- | --- | --- |
| `ubuntu-24.04` | moving | Latest base image for Ubuntu 24.04 |
| `ubuntu-24.04-2.1.0` | immutable | Pinned base, `2.1.0` = this repo's semver |
| `ubuntu-24.04-cmake-4` | moving | Latest CMake 4 add-on on the 24.04 base |
| `ubuntu-24.04-cmake-4-2.1.0` | immutable | Pinned add-on |
| `arch-rolling-2026.06.01` | immutable | Date-stamped snapshot for the rolling distro |

The repo's own semver (`MAJOR.MINOR.PATCH`) versions the **recipe**, not
OpenModelica. Day-to-day CI uses the **moving** tag; when an OpenModelica
release needs a frozen environment it pins the **immutable** tag.

### Currently provided images

| OS / version | Base tag | Add-ons | Status | Source |
| --- | --- | --- | --- | --- |
| Ubuntu 26.04 | `ubuntu-26.04` | – | implemented | [ubuntu/Dockerfile][ubuntu-dockerfile] |
| Ubuntu 24.04 (Noble) | `ubuntu-24.04` | `cmake-4` | implemented | [ubuntu/Dockerfile][ubuntu-dockerfile] |
| Ubuntu 22.04 (Jammy) | `ubuntu-22.04` | – | implemented | [ubuntu/Dockerfile][ubuntu-dockerfile] |
| Debian 13 (Trixie) | `debian-13` | – | placeholder | [debian/Dockerfile][debian-dockerfile] |
| AlmaLinux 9 | `almalinux-9` | – | placeholder | [almalinux/Dockerfile][almalinux-dockerfile] |
| Arch Linux (rolling) | `arch-rolling` | – | placeholder | [arch/Dockerfile][arch-dockerfile] |

## Build locally

**Base image** — for Ubuntu, pick the version with `UBUNTU_VERSION` and build
the `full` stage:

```bash
docker build --pull --no-cache \
  --target full \
  --build-arg UBUNTU_VERSION=24.04 \
  --tag build-deps:ubuntu-24.04 \
  ubuntu

# Debian/AlmaLinux/Arch follow the same pattern once implemented, e.g.:
#   docker build --pull --target full --build-arg DEBIAN_VERSION=13 \
#     --tag build-deps:debian-13 debian
```

**Add-on image** — build the add-on's stage with `--target`. It reuses the
base's cached layers, so it only adds the extra step:

```bash
docker build --pull \
  --target cmake-4 \
  --build-arg UBUNTU_VERSION=24.04 \
  --tag build-deps:ubuntu-24.04-cmake-4 \
  ubuntu
```

> The values to pass (`context`, `--file`, `--target`, `--build-arg`) for any
> image are exactly its fields in [.ci/matrix.yml][matrix-yml].

## CI workflow

A single workflow, [build.yml][workflow-build-file], runs the whole pipeline so
that a release it creates can publish in the **same** run (a release created
with `GITHUB_TOKEN` cannot trigger a separate workflow):

```text
discover ─▶ build (all images, no push)
              └─▶ release (tag only) ─▶ publish-ghcr + publish-nexus
```

- **build** — on every push/PR to `main` (and as the gate before release),
  builds every base + add-on declared in `.ci/matrix.yml` (no push).
- **release** — on an image release tag, creates/updates the GitHub Release.
- **publish-ghcr / publish-nexus** — build, push (and on GHCR **sign**) the
  tagged image (base + add-ons) to GHCR and Nexus. Also runnable via
  `workflow_dispatch` with a `tag` input to re-publish without a new tag.

## Releasing a new image version

See **[RELEASING.md][releasing-md]** for the step-by-step process.

## License

The original Dockerfile was taken from
[OpenModelica/OpenModelicaBuildScripts][build-scripts].
See [LICENSE.md][license-md].

[badge-build-img]: https://github.com/OpenModelica/build-deps/actions/workflows/build.yml/badge.svg?branch=main
[workflow-build]: https://github.com/OpenModelica/build-deps/actions/workflows/build.yml
[openmodelica]: https://github.com/OpenModelica/OpenModelica
[jenkins]: https://test.openmodelica.org/jenkins/
[matrix-yml]: ./.ci/matrix.yml
[ubuntu-dockerfile]: ./ubuntu/Dockerfile
[debian-dockerfile]: ./debian/Dockerfile
[almalinux-dockerfile]: ./almalinux/Dockerfile
[arch-dockerfile]: ./arch/Dockerfile
[workflow-build-file]: ./.github/workflows/build.yml
[releasing-md]: ./RELEASING.md
[build-scripts]: https://github.com/OpenModelica/OpenModelicaBuildScripts
[license-md]: ./LICENSE.md
