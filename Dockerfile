#
# Usage: docker build . -t act
# To run: docker run -it -v`pwd`:/work act
#

FROM ubuntu:20.04

# Install tools needed for development
RUN apt update && \
    apt upgrade --yes && \
    apt install --yes build-essential m4 libedit-dev zlib1g-dev libboost-dev git

ENV VLSI_TOOLS_SRC=/work
ENV ACT_HOME=/usr/local/cad
ENV PATH=$PATH:$ACT_HOME/bin

WORKDIR $VLSI_TOOLS_SRC
COPY . $VLSI_TOOLS_SRC
RUN mkdir -p $ACT_HOME && \
    ./configure $ACT_HOME && \
    ./build && \
    make install

# TODO: Can add Dali: https://docs.nvidia.com/deeplearning/dali/user-guide/docs/compilation.html

RUN git clone https://github.com/asyncvlsi/interact.git && \
    git clone --branch sdtcore https://github.com/asyncvlsi/chp2prs.git && \
    git clone https://github.com/asyncvlsi/dflowmap.git && \
    for p in interact chp2prs dflowmap; do \
      cd $p && (./configure || true) && make depend && make && make install && cd .. \
    ; done && echo "$ACT_HOME/lib" > /etc/ld.so.conf.d/act.conf
 
# Cleanup all we can to keep container as lean as possible
RUN apt remove --yes build-essential git && \
    apt autoremove --yes && \
    rm -rf /work /tmp/* /var/lib/apt/lists/*

CMD ["/bin/bash"]
