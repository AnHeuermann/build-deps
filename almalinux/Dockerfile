# PLACEHOLDER — OpenModelica build-deps image for AlmaLinux.
#
# Not implemented yet. Use the same layout as ../ubuntu/Dockerfile: a single
# multi-stage Dockerfile covering ALL AlmaLinux versions, with these stages:
#   base     OpenModelica build dependencies only
#   venv     Python virtualenv at /opt/venv, built in isolation and copied later
#   full     the published base image (build-deps:almalinux-<ver>)
#   <addon>  optional add-on stages (FROM full)
#
# The AlmaLinux version is selected with a build-arg, e.g.:
#   ARG ALMALINUX_VERSION=9
#   FROM almalinux:${ALMALINUX_VERSION} AS base
#
# Note: AlmaLinux is RPM-based (dnf) and there is no OpenModelica apt repo —
# install the build dependencies directly with dnf.
#
# To implement:
#   1. Replace this file with a real multi-stage Dockerfile (see
#      ../ubuntu/Dockerfile and RELEASING.md).
#   2. Add the almalinux entries to .ci/matrix.yml
#      (context: almalinux, dockerfile: almalinux/Dockerfile, target: full,
#       build_args: { ALMALINUX_VERSION: "<ver>" }).
#   3. Open a PR; build.yml will build it.
#
# Until then AlmaLinux is intentionally absent from .ci/matrix.yml, so CI does
# not try to build it.
