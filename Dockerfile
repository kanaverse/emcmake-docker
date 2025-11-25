FROM ubuntu:latest

RUN apt-get update && \
    apt-get install -y git wget make python3 xz-utils lbzip2 libatomic1

# Grabbing Emscripten along with its latest supported version of Node.
RUN git clone https://github.com/emscripten-core/emsdk.git && \
    cd emsdk && \
    ./emsdk install 4.0.20 && \
    ./emsdk activate 4.0.20 && \
    ./emsdk install node-24.7.0-64bit && \
    ./emsdk activate node-24.7.0-64bit

# Grabbing CMake.
RUN wget https://github.com/Kitware/CMake/releases/download/v4.2.0/cmake-4.2.0-linux-x86_64.sh -O cmake_install.sh && \
    mkdir cmake && \
    bash cmake_install.sh --prefix=cmake --skip-license && \
    rm cmake_install.sh

ENV PATH="/emsdk:/emsdk/upstream/emscripten:/cmake/bin:${PATH}"

# Prebuilding system libraries so that we don't have to do it again in each use case.
RUN mkdir test-bar && \
    touch test-bar/foo.c && \
    touch test-bar/foo.cpp && \
    cd test-bar && \
    /emsdk/upstream/emscripten/emcc --use-port=zlib -pthread --bind foo.c -o bar && \
    /emsdk/upstream/emscripten/emcc --use-port=zlib -pthread --bind -O3 foo.c -o bar && \
    /emsdk/upstream/emscripten/emcc --use-port=zlib -pthread -sMEMORY64 --bind foo.c -o bar && \
    /emsdk/upstream/emscripten/emcc --use-port=zlib -pthread -sMEMORY64 --bind -O3 foo.c -o bar && \
    /emsdk/upstream/emscripten/em++ --use-port=zlib -pthread --bind foo.cpp -o bar && \
    /emsdk/upstream/emscripten/em++ --use-port=zlib -pthread --bind -O3 foo.cpp -o bar && \
    /emsdk/upstream/emscripten/em++ --use-port=zlib -pthread -sMEMORY64 --bind foo.cpp -o bar && \
    /emsdk/upstream/emscripten/em++ --use-port=zlib -pthread -sMEMORY64 --bind -O3 foo.cpp -o bar && \
    cd ../ && \
    rm -rf test-bar
