# Build stage
FROM ubuntu:22.04 AS builder

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install build dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    bison \
    flex \
    libsasl2-dev \
    libevent-dev \
    libtbb-dev \
    libssl-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Clone and build libmemcached
WORKDIR /src
RUN git clone https://github.com/awesomized/libmemcached.git
RUN mkdir build-libmemcached
WORKDIR /src/build-libmemcached
RUN cmake ../libmemcached \
    -DENABLE_SASL=ON \
    -DENABLE_MEMASLAP=ON \
    -DBUILD_TESTING=OFF
RUN make -j$(nproc)
RUN make install
RUN ldconfig

# Runtime stage
FROM ubuntu:22.04

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    libsasl2-2 \
    libevent-2.1-7 \
    libtbb12 \
    && rm -rf /var/lib/apt/lists/*

# Copy ALL shared libraries from the build stage
COPY --from=builder /usr/local/lib/lib*.so* /usr/local/lib/

# Copy binaries from builder stage
COPY --from=builder /usr/local/bin/mem* /usr/local/bin/

# Update shared library cache
RUN ldconfig

# Set the library path
ENV LD_LIBRARY_PATH=/usr/local/lib

# Default command
CMD ["memaslap", "--version"]
