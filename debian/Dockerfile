# PLACEHOLDER — OpenModelica build-deps image for Debian.
#
# Not implemented yet. Use the same layout as ../ubuntu/Dockerfile: a single
# multi-stage Dockerfile covering ALL Debian versions, with these stages:
#   base     OpenModelica build dependencies only
#   venv     Python virtualenv at /opt/venv, built in isolation and copied later
#   full     the published base image (build-deps:debian-<ver>)
#   <addon>  optional add-on stages (FROM full)
#
# The Debian version is selected with a build-arg, e.g.:
#   ARG DEBIAN_VERSION=13
#   FROM debian:${DEBIAN_VERSION} AS base
#
# To implement:
#   1. Replace this file with a real multi-stage Dockerfile (see
#      ../ubuntu/Dockerfile and RELEASING.md). A starting point exists on the
#      old Debian branches / PR #36
#      (https://github.com/OpenModelica/build-deps/pull/36).
#   2. Add the debian entries to .ci/matrix.yml
#      (context: debian, dockerfile: debian/Dockerfile, target: full,
#       build_args: { DEBIAN_VERSION: "<ver>" }).
#   3. Open a PR; build.yml will build it.
#
# Until then Debian is intentionally absent from .ci/matrix.yml, so CI does not
# try to build it.
