FROM ubuntu:latest

RUN apt-get update && \
    apt-get install -y git wget make python3 xz-utils lbzip2

# Grabbing Emscripten. 
RUN git clone https://github.com/emscripten-core/emsdk.git && \
    cd emsdk && \
    ./emsdk install 3.1.68 && \
    ./emsdk activate 3.1.68

# Grabbing CMake.
RUN wget https://github.com/Kitware/CMake/releases/download/v3.30.4/cmake-3.30.4-linux-x86_64.sh -O cmake_install.sh && \
    mkdir cmake && \
    bash cmake_install.sh --prefix=cmake --skip-license && \
    rm cmake_install.sh

ENV PATH="/emsdk:/emsdk/upstream/emscripten:/cmake/bin:${PATH}"
