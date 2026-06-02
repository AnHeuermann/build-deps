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

# Install OpenModelica GPG key
RUN apt-get update                                                             \
  && apt-get upgrade -qy                                                       \
  && apt-get dist-upgrade -qy                                                  \
  && apt-get install -qy                                                       \
    ca-certificates                                                            \
    curl                                                                       \
    gnupg                                                                      \
    lsb-release                                                                \
  && KEYRING=/usr/share/keyrings/openmodelica-keyring.gpg                      \
  && ARCH=$(dpkg --print-architecture)                                         \
  && REPO="https://build.openmodelica.org/apt"                                 \
  && curl -fsSL ${REPO}/openmodelica.asc                                       \
    | gpg --dearmor -o ${KEYRING}                                              \
  && echo "deb [arch=${ARCH} signed-by=${KEYRING}] ${REPO} trixie nightly"     \
    | tee /etc/apt/sources.list.d/openmodelica.list                            \
  && echo "deb-src [arch=${ARCH} signed-by=${KEYRING}] ${REPO} trixie nightly" \
    | tee -a /etc/apt/sources.list.d/openmodelica.list                         \
  && apt-get update

# Install Debian build dependencies
# From https://github.com/OpenModelica/OpenModelicaBuildScripts/blob/37b564c1674023a5afb7517e408ffd9bd174a59c/debian/control
# Qt5 dependencies skipped
RUN apt-get install -qy                                                        \
  autoconf                                                                     \
  automake                                                                     \
  build-essential                                                              \
  clang                                                                        \
  cmake                                                                        \
  debhelper                                                                    \
  default-jdk                                                                  \
  devscripts                                                                   \
  equivs                                                                       \
  gfortran                                                                     \
  libboost-all-dev                                                             \
  libboost-dev                                                                 \
  libboost-filesystem-dev                                                      \
  libboost-program-options-dev                                                 \
  libboost-serialization-dev                                                   \
  libboost-system-dev                                                          \
  libcurl4-gnutls-dev                                                          \
  libexpat1-dev                                                                \
  libexpat1-dev                                                                \
  libffi-dev                                                                   \
  libhdf5-serial-dev                                                           \
  libhwloc-dev                                                                 \
  liblapack-dev                                                                \
  liblapack-dev                                                                \
  liblpsolve55-dev                                                             \
  libncurses5-dev                                                              \
  libomniorb4-dev                                                              \
  libomp-dev                                                                   \
  libopengl-dev                                                                \
  libopenscenegraph-dev                                                        \
  libreadline-dev                                                              \
  libsqlite3-dev                                                               \
  libtool                                                                      \
  libxcursor-dev                                                               \
  libxi-dev                                                                    \
  libxinerama-dev                                                              \
  libxrandr2                                                                   \
  omniidl                                                                      \
  openscenegraph                                                               \
  pkg-config                                                                   \
  unzip                                                                        \
  uuid-dev                                                                     \
  wget                                                                         \
  zip

# Install additional dependencies:
#   - Tools for the User's Guide
RUN apt-get install -qy                                                        \
  aspell                                                                       \
  bibtex2html                                                                  \
  bison                                                                        \
  ccache                                                                       \
  clang-tools                                                                  \
  docker.io                                                                    \
  doxygen                                                                      \
  flex                                                                         \
  git                                                                          \
  gnuplot-nox                                                                  \
  inkscape                                                                     \
  latexmk                                                                      \
  libmldbm-perl                                                                \
  libsaxonb-java                                                               \
  ocl-icd-opencl-dev                                                           \
  opencl-headers                                                               \
  pandoc                                                                       \
  pocl-opencl-icd                                                              \
  poppler-utils                                                                \
  python3-pip                                                                  \
  python3.13-venv                                                              \
  subversion                                                                   \
  texlive-base                                                                 \
  texlive-bibtex-extra                                                         \
  texlive-lang-greek                                                           \
  texlive-latex-extra                                                          \
  xsltproc                                                                     \
  xvfb

# Install Qt6 tools
RUN apt-get install -qy                                                        \
  libqt6concurrent6                                                            \
  libqt6core5compat6                                                           \
  libqt6core5compat6-dev                                                       \
  libqt6core6                                                                  \
  libqt6dbus6                                                                  \
  libqt6designer6                                                              \
  libqt6designercomponents6                                                    \
  libqt6gui6                                                                   \
  libqt6help6                                                                  \
  libqt6network6                                                               \
  libqt6opengl6                                                                \
  libqt6opengl6-dev                                                            \
  libqt6openglwidgets6                                                         \
  libqt6pdf6                                                                   \
  libqt6pdfquick6                                                              \
  libqt6pdfwidgets6                                                            \
  libqt6positioning6                                                           \
  libqt6positioning6-plugins                                                   \
  libqt6positioningquick6                                                      \
  libqt6printsupport6                                                          \
  libqt6qml6                                                                   \
  libqt6qmlmodels6                                                             \
  libqt6qmlworkerscript6                                                       \
  libqt6quick6                                                                 \
  libqt6quickcontrols2-6                                                       \
  libqt6quickshapes6                                                           \
  libqt6quicktemplates2-6                                                      \
  libqt6quicktest6                                                             \
  libqt6quickwidgets6                                                          \
  libqt6serialport6                                                            \
  libqt6sql6                                                                   \
  libqt6sql6-sqlite                                                            \
  libqt6svg6                                                                   \
  libqt6svg6-dev                                                               \
  libqt6svgwidgets6                                                            \
  libqt6test6                                                                  \
  libqt6uitools6                                                               \
  libqt6waylandclient6                                                         \
  libqt6waylandcompositor6                                                     \
  libqt6webchannel6                                                            \
  libqt6webengine6-data                                                        \
  libqt6webenginecore6                                                         \
  libqt6webenginecore6-bin                                                     \
  libqt6webenginequick6                                                        \
  libqt6webenginewidgets6                                                      \
  libqt6webview6                                                               \
  libqt6widgets6                                                               \
  libqt6wlshellintegration6                                                    \
  libqt6xml6                                                                   \
  qt6-5compat-dev                                                              \
  qt6-base-dev                                                                 \
  qt6-base-dev-tools                                                           \
  qt6-declarative-dev                                                          \
  qt6-declarative-dev-tools                                                    \
  qt6-httpserver-dev                                                           \
  qt6-l10n-tools                                                               \
  qt6-svg-dev                                                                  \
  qt6-tools-dev                                                                \
  qt6-tools-dev-tools                                                          \
  qt6-translations-l10n                                                        \
  qt6-webengine-dev                                                            \
  qt6-webengine-dev-tools                                                      \
  qt6-websockets-dev                                                           \
  qt6-webview-dev                                                              \
  qt6-webview-plugins

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
