# Multi-stage, shared image for all supported Ubuntu versions.
#
# The FROM tag is the only per-version difference besides a handful of Qt
# packages, so every Ubuntu image (and its add-ons) builds from this one file.
#
# Stages / build targets:
#   base     OpenModelica build dependencies only (apt build-dep openmodelica)
#   python   Python virtualenv at /opt/venv, built in isolation and copied later
#   full     the published BASE image: base + User's Guide toolchain + Qt + python
#   cmake-4  ADD-ON: full + CMake 4 from the official Kitware release
#   debug    ADD-ON: full + GDB, Valgrind, and other debugging tools
#
# Build the base image (the `full` target):
#   docker build --target full --build-arg UBUNTU_VERSION=24.04 \
#     --tag build-deps:ubuntu-24.04 ubuntu
#
# Build the CMake 4 add-on image (the `cmake-4` target):
#   docker build --target cmake-4 --build-arg UBUNTU_VERSION=24.04 \
#     --tag build-deps:ubuntu-24.04-cmake-4 ubuntu
#
# Build the debug add-on image (the `debug` target):
#   docker build --target debug --build-arg UBUNTU_VERSION=24.04 \
#     --tag build-deps:ubuntu-24.04-debug ubuntu
#
# CI passes UBUNTU_VERSION and the --target per image from .ci/matrix.yml.

ARG UBUNTU_VERSION=24.04

# ── base: OpenModelica build dependencies only ────────────────────────────────
FROM ubuntu:${UBUNTU_VERSION} AS base

# Image / OCI metadata (inherited by the stages built FROM this one)
LABEL maintainer="AnHeuermann"
LABEL description="OpenModelica build-deps Docker Image"
LABEL organization="OpenModelica"

LABEL org.opencontainers.image.vendor="OpenModelica"
LABEL org.opencontainers.image.authors="AnHeuermann"
LABEL org.opencontainers.image.description="OpenModelica build-deps base image (Ubuntu)"
LABEL org.opencontainers.image.source="https://github.com/OpenModelica/build-deps"
LABEL org.opencontainers.image.license="MIT"

ENV SHELL=/bin/bash
# Set locale (inherited by later stages)
ENV LANGUAGE=en_US:en
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Ensure DEBIAN_FRONTEND is only set during build
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
  && apt-get upgrade -qy \
  && apt-get dist-upgrade -qy \
  && apt-get install -qy \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
  && curl -fsSL https://build.openmodelica.org/apt/openmodelica.asc | gpg --dearmor -o /usr/share/keyrings/openmodelica-keyring.gpg \
  && echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/openmodelica-keyring.gpg] https://build.openmodelica.org/apt \
    $(cat /etc/os-release | grep "\(UBUNTU\\|DEBIAN\\|VERSION\)_CODENAME" | sort | cut -d= -f 2 | head -1) \
    nightly" | tee /etc/apt/sources.list.d/openmodelica.list > /dev/null \
  && echo \
    "deb-src [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/openmodelica-keyring.gpg] https://build.openmodelica.org/apt \
    $(cat /etc/os-release | grep "\(UBUNTU\\|DEBIAN\\|VERSION\)_CODENAME" | sort | cut -d= -f 2 | head -1) \
    nightly" | tee -a /etc/apt/sources.list.d/openmodelica.list > /dev/null \
  && apt-get update \
  && apt-get build-dep -qy openmodelica \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# ── venv: Python tooling, isolated so it caches independently ─────────────────
# Built once and copied into `full`. Uses the same python3 as `full` (same
# Ubuntu base), so the relocated /opt/venv works there unchanged.
FROM base AS venv
RUN apt-get update \
  && apt-get install -qy python3-pip python3-venv \
  && rm -rf /var/lib/apt/lists/*
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
# Use permalink for doc/UsersGuide/source/requirements.txt to keep builds
# deterministic.
RUN pip install --no-cache-dir \
    junit_xml \
    lxml \
    ompython==3.6.0 \
    PyGithub \
    simplejson \
    svgwrite \
  && pip install --no-cache-dir -r \
    https://raw.githubusercontent.com/OpenModelica/OpenModelica/9c0dc9a8ab50ba652109584cb3fecaef86640b66/doc/UsersGuide/source/requirements.txt

# ── full: the published base image ────────────────────────────────────────────
#   - tools to build the User's Guide (common to all Ubuntu versions)
#   - Qt5/Qt6 packages (version-specific: Jammy ships an older Qt6 that lacks
#     some packages available on 24.04+, so the set is chosen from VERSION_ID)
FROM base AS full
ARG DEBIAN_FRONTEND=noninteractive

# Package lists as build-args, so they are easy to read and to override:
#   - COMMON_PKGS   : tools common to all Ubuntu versions (User's Guide, …)
#   - QT_PKGS_22_04 : Qt set for Jammy (older Qt6, lacks some 24.04+ packages)
#   - QT_PKGS       : Qt set for 24.04+ (the default)
ARG COMMON_PKGS="\
    aspell \
    bibtex2html \
    bison \
    ccache \
    clang-tools \
    devscripts \
    docker.io \
    doxygen \
    equivs \
    flex \
    git \
    gnuplot-nox \
    inkscape \
    intel-opencl-icd \
    latexmk \
    libcurl4-gnutls-dev \
    libmldbm-perl \
    locales \
    ocl-icd-opencl-dev \
    opencl-headers \
    pandoc \
    pocl-opencl-icd \
    poppler-utils \
    python3-pip \
    python3-venv \
    subversion \
    texlive-base \
    texlive-bibtex-extra \
    texlive-lang-greek \
    texlive-latex-extra \
    unzip \
    wget \
    xsltproc \
    xvfb \
    zip"
ARG QT_PKGS_22_04="\
    qt6-base-dev \
    qt6-tools-dev \
    qt6-tools-dev-tools \
    qttools5-dev \
    qtwebengine5-dev"
ARG QT_PKGS="\
    libqt6core5compat6-dev \
    libqt6opengl6-dev \
    libqt6openglwidgets6 \
    libqt6svg6-dev \
    qt6-base-dev \
    qt6-httpserver-dev \
    qt6-scxml-dev \
    qt6-tools-dev \
    qt6-tools-dev-tools \
    qt6-webengine-dev \
    qt6-websockets-dev \
    qtwebengine5-dev"
RUN apt-get update \
  && . /etc/os-release \
  && case "${VERSION_ID}" in \
       22.04) qt="${QT_PKGS_22_04}" ;; \
       *)     qt="${QT_PKGS}" ;; \
     esac \
  && apt-get install -qy ${COMMON_PKGS} ${qt} \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Pull in the venv built in its own stage instead of rebuilding it here.
COPY --from=venv /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# ── cmake-4 add-on: full + CMake 4 from the official Kitware release ──────────
# Overrides any apt-provided cmake. Built with `--target cmake-4`.
FROM full AS cmake-4
LABEL org.opencontainers.image.description="OpenModelica build-deps (Ubuntu) with CMake 4"
ARG CMAKE_VERSION=4.2.3
RUN curl -fsSL "https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-linux-$(uname -m).sh" \
      -o /tmp/cmake-install.sh \
  && chmod +x /tmp/cmake-install.sh \
  && /tmp/cmake-install.sh --skip-license --prefix=/usr/local \
  && rm /tmp/cmake-install.sh

# ── debug add-on: full + GDB, Valgrind, and other debugging tools ─────────────
# Overrides nothing in full; adds debuggers and profilers on top.
# Built with `--target debug`.
FROM full AS debug
LABEL org.opencontainers.image.description="OpenModelica build-deps (Ubuntu) with debug tools"
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
  && apt-get install -qy \
    gdb \
    linux-tools-generic \
    valgrind \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*
