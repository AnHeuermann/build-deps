FROM debian:trixie

# Image / OCI metadata
LABEL maintainer="AnHeuermann"
LABEL description="OpenModelica build-deps Docker Image for Debian Trixie"
LABEL organization="OpenModelica"

LABEL org.opencontainers.image.vendor="OpenModelica"
LABEL org.opencontainers.image.authors="AnHeuermann"
LABEL org.opencontainers.image.version="trixie.nightly.amd64"
LABEL org.opencontainers.image.description="OpenModelica build-deps Docker Image for Debian Trixie"
LABEL org.opencontainers.image.source="https://github.com/OpenModelica/build-deps/tree/releases/trixie/v1.27"
LABEL org.opencontainers.image.license="MIT"

ENV SHELL=/bin/bash

# Ensure DEBIAN_FRONTEND is only set during build
ARG DEBIAN_FRONTEND=noninteractive

# Install OpenModelica GPG key and
RUN apt-get update                                                                                                                                               \
  && apt-get upgrade -qy                                                                                                                                         \
  && apt-get dist-upgrade -qy                                                                                                                                    \
  && apt-get install -qy                                                                                                                                         \
    ca-certificates                                                                                                                                              \
    curl                                                                                                                                                         \
    gnupg                                                                                                                                                        \
    lsb-release                                                                                                                                                  \
  && curl -fsSL https://build.openmodelica.org/apt/openmodelica.asc | gpg --dearmor -o /usr/share/keyrings/openmodelica-keyring.gpg                              \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/openmodelica-keyring.gpg] https://build.openmodelica.org/apt trixie nightly"     \
    | tee /etc/apt/sources.list.d/openmodelica.list > /dev/null                                                                                                  \
  && echo "deb-src [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/openmodelica-keyring.gpg] https://build.openmodelica.org/apt trixie nightly" \
    | tee -a /etc/apt/sources.list.d/openmodelica.list > /dev/null                                                                                               \
  && apt-get update

# Install:
#   - Packages from OpenModelica build dependencies
#   - tools to build the User's Guide
#   - Qt6 packages
RUN apt-get install -qy                                                        \
  aspell                                                                       \
  autoconf                                                                     \
  automake                                                                     \
  bibtex2html                                                                  \
  bison                                                                        \
  build-essential                                                              \
  ccache                                                                       \
  clang                                                                        \
  clang-tools                                                                  \
  cmake                                                                        \
  debhelper                                                                    \
  default-jdk                                                                  \
  devscripts                                                                   \
  docker.io                                                                    \
  doxygen                                                                      \
  equivs                                                                       \
  flex                                                                         \
  gfortran                                                                     \
  git                                                                          \
  gnuplot-nox                                                                  \
  inkscape                                                                     \
  latexmk                                                                      \
  libboost-all-dev                                                             \
  libcurl4-gnutls-dev                                                          \
  libexpat1-dev                                                                \
  libffi-dev                                                                   \
  libhdf5-dev                                                                  \
  libhwloc-dev                                                                 \
  liblapack-dev                                                                \
  liblpsolve55-dev                                                             \
  libmldbm-perl                                                                \
  libncurses-dev                                                               \
  libomniorb4-dev                                                              \
  libomp-dev                                                                   \
  libopenscenegraph-dev                                                        \
  libqt6opengl6-dev                                                            \
  libqt6openglwidgets6                                                         \
  libreadline-dev                                                              \
  libsqlite3-dev                                                               \
  libtool                                                                      \
  libxcursor-dev                                                               \
  libxi-dev                                                                    \
  libxinerama-dev                                                              \
  libxrandr2                                                                   \
  locales                                                                      \
  lsb-release                                                                  \
  ocl-icd-opencl-dev                                                           \
  omniidl                                                                      \
  opencl-headers                                                               \
  pandoc                                                                       \
  pkg-config                                                                   \
  pocl-opencl-icd                                                              \
  poppler-utils                                                                \
  python3-pip                                                                  \
  python3-venv                                                                 \
  qt6-5compat-dev                                                              \
  qt6-base-dev                                                                 \
  qt6-base-dev-tools                                                           \
  qt6-httpserver-dev                                                           \
  qt6-l10n-tools                                                               \
  qt6-scxml-dev                                                                \
  qt6-svg-dev                                                                  \
  qt6-tools-dev                                                                \
  qt6-tools-dev-tools                                                          \
  qt6-translations-l10n                                                        \
  qt6-webengine-dev                                                            \
  qt6-webengine-dev-tools                                                      \
  qt6-websockets-dev                                                           \
  subversion                                                                   \
  texlive-base                                                                 \
  texlive-bibtex-extra                                                         \
  texlive-lang-greek                                                           \
  texlive-latex-extra                                                          \
  unzip                                                                        \
  uuid-dev                                                                     \
  wget                                                                         \
  xsltproc                                                                     \
  xvfb                                                                         \
  zip

# Install Python packages in a default virtual environment
# Use permalink for doc/UsersGuide/source/requirements.txt to keep builds
# deterministic.
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
RUN pip install --no-cache-dir                                                 \
    junit_xml                                                                  \
    lxml                                                                       \
    ompython==3.6.0                                                            \
    PyGithub                                                                   \
    simplejson                                                                 \
    svgwrite                                                                   \
  && pip install --no-cache-dir -r                                             \
    https://raw.githubusercontent.com/OpenModelica/OpenModelica/9c0dc9a8ab50ba652109584cb3fecaef86640b66/doc/UsersGuide/source/requirements.txt

# Set locale
ENV LANGUAGE=en_US:en
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Clean
RUN apt-get clean \
  && rm -rf /var/lib/apt/lists/*
