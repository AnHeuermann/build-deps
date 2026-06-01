# OpenModelica build-deps Docker Image

[![Build Docker Image](https://github.com/OpenModelica/build-deps/actions/workflows/build.yml/badge.svg?branch=main)](https://github.com/OpenModelica/build-deps/actions/workflows/build.yml)
[![Publish Docker Image](https://github.com/OpenModelica/build-deps/actions/workflows/publish.yml/badge.svg)](https://github.com/OpenModelica/build-deps/actions/workflows/publish.yml)

The Docker images used to build and deploy
[OpenModelica](https://github.com/OpenModelica/OpenModelica) with
[Jenkins](https://test.openmodelica.org/jenkins/).

## Structure of the Repository

Each minor version of the Dockerfile corresponds to a OpenModelica minor version
and has its own branch. Each branch has tags for each patch version.

When creating a release form a tag the
[workflow](./.github/workflows/publish.yml) will publish the Docker image to
[GitHub Container registry](https://github.com/OpenModelica/openmodelica-build-deps/pkgs/container/build-deps).

### Ubuntu based Images

- 24.04 Noble:
  - [releases/v1.26](https://github.com/OpenModelica/build-deps/tree/releases/v1.26)
  - [releases/v1.26-cmake4](https://github.com/OpenModelica/build-deps/tree/releases/v1.26-cmake4)
- 22.04 Jammy:
  - [releases/v1.22](https://github.com/OpenModelica/build-deps/tree/releases/v1.22)
  - [releases/v1.22-qtwebengine](https://github.com/OpenModelica/build-deps/tree/releases/v1.22-qtwebengine), replaced by [releases/v1.22](https://github.com/OpenModelica/build-deps/tree/releases/v1.22) v1.22.3 or higher
  - [releases/v1.24-qt5qt6](https://github.com/OpenModelica/build-deps/tree/releases/v1.22-qtwebengine), replaced by [releases/v1.22](https://github.com/OpenModelica/build-deps/tree/releases/v1.22) v1.22.3 or higher
- 20.04 Focal: [releases/v1.21](https://github.com/OpenModelica/build-deps/tree/releases/v1.21)
- 18.04 Bionic + cmake: [releases/v1.16-cmake](https://github.com/OpenModelica/build-deps/tree/releases/v1.16-cmake)
- 18.04 Bionic: [releases/v1.16](https://github.com/OpenModelica/build-deps/tree/releases/v1.16)

### Debian based Images

- 13 Trixie
  - [releases/debian/trixie/nightly](https://github.com/OpenModelica/build-deps/tree/releases/debian/trixie/nightly)

### CentOS based Images

- CentOS7

## Build

```bash
export TAG=trixie.nightly.amd64
docker build --pull --no-cache --tag build-deps:$TAG .
```

## Upload

The [publish.yml](./.github/workflows/publish.yml) workflow will build, sign and
upload the Docker image to
[GitHub Container registry](https://github.com/OpenModelica/openmodelica-build-deps/pkgs/container/build-deps)
for each release.
The [publish-nexus](./.github/workflows/publish-nexus.yml) workflow will build and upload the Docker image to [docker.openmodelica.org](https://nexus.openmodelica.org/#browse/browse:openmodelica:v2%2Fbuild-deps)

## License

The original Dockerfile was taken from
[OpenModelica/OpenModelicaBuildScripts](https://github.com/OpenModelica/OpenModelicaBuildScripts).
See [LICENSE.md](./LICENSE.md).
