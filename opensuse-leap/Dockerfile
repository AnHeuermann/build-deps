# PLACEHOLDER — OpenModelica build-deps image for openSUSE Leap.
#
# Not implemented yet. Use the same layout as ../ubuntu/Dockerfile: a single
# multi-stage Dockerfile covering ALL openSUSE Leap versions, with these stages:
#   base     OpenModelica build dependencies only
#   python   Python virtualenv at /opt/venv, built in isolation and copied later
#   full     the published base image (build-deps:opensuse-leap-<ver>)
#   <addon>  optional add-on stages (FROM full)
#
# The Leap version is selected with a build-arg, e.g.:
#   ARG LEAP_VERSION=15.6
#   FROM opensuse/leap:${LEAP_VERSION} AS base
#
# To implement:
#   1. Replace this file with a real multi-stage Dockerfile (see
#      ../ubuntu/Dockerfile and RELEASING.md).
#   2. Uncomment the opensuse-leap entries in .ci/matrix.yml
#      (context: opensuse-leap, dockerfile: opensuse-leap/Dockerfile,
#       target: full, build_args: { LEAP_VERSION: "<ver>" }).
#   3. Open a PR; build.yml will build it.
#
# Until then openSUSE Leap is intentionally absent from .ci/matrix.yml, so CI
# does not try to build it.
