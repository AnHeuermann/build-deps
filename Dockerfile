FROM ubuntu:bionic

ARG OCL=16.1.2_x64_rh_6.4.0.37
# Ensure DEBIAN_FRONTEND is only set during build
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get upgrade -qy && apt-get dist-upgrade -qy
RUN apt-get install -qy \
      gnupg wget ca-certificates apt-transport-https
RUN apt-get install -qy \
      devscripts equivs python3-pip python-pip libmldbm-perl \
      docker.io sudo git subversion texlive-base texlive-latex-extra latexmk gnuplot-nox doxygen \
      poppler-utils flex libgfortran3 aspell bibtex2html zip unzip ocl-icd-opencl-dev cpio xsltproc inkscape \
      g++-4.8 g++-5 g++-6 g++-7 texlive-lang-greek xvfb libcurl4-gnutls-dev

# Pandoc
RUN (test "`pandoc --version | head -1`" == "pandoc 2.2.3.2" || (wget https://github.com/jgm/pandoc/releases/download/2.2.3.2/pandoc-2.2.3.2-1-amd64.deb && dpkg -i pandoc-2.2.3.2-1-amd64.deb && apt-get install -qyf))

# OpenCL
RUN test -e /opt/intel/opencl || ( \
      wget http://registrationcenter-download.intel.com/akdlm/irc_nas/12556/opencl_runtime_${OCL}.tgz \
      && tar xzvf opencl_runtime_${OCL}.tgz \
      && sed -i -e s/=decline/=accept/ -e s/=RPM/=NONRPM/ opencl_runtime_${OCL}/silent.cfg \
      && (cd opencl_runtime_16.1.2_x64_rh_6.4.0.37 && ./install.sh -s silent.cfg) \
      && rm -rf opencl_runtime_* \
    )
RUN wget https://raw.githubusercontent.com/OpenModelica/OpenModelicaBuildScripts/master/debian/control \
    && mk-build-deps --install -t 'apt-get --force-yes -y' control

# Python packages
RUN wget https://raw.githubusercontent.com/OpenModelica/OpenModelica-doc/master/UsersGuide/source/requirements.txt \
    && pip2 install --no-cache-dir --upgrade -r requirements.txt \
    && pip3 install --no-cache-dir --upgrade -r requirements.txt \
    && pip3 install --no-cache-dir --upgrade junit_xml simplejson svgwrite # ComplianceSuite

# Install cmake 3.17.2.
RUN wget cmake.org/files/v3.17/cmake-3.17.2-Linux-x86_64.sh \
    && mkdir -p /opt/cmake-3.17.2 \
    && sh cmake-3.17.2-Linux-x86_64.sh --prefix=/opt/cmake-3.17.2 --skip-license \
    && rm cmake-3.17.2-Linux-x86_64.sh

# Clean
RUN rm -rf /var/lib/apt/lists/* \
    && apt-get clean \
    && rm -f control requirements.txt *.deb
