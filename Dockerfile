# Use a relatively old/stable distro here to maximize the supported platforms
# and avoid depending on more recent version of, say, libc.
# Here we choose Bionic 18.04.
FROM ubuntu:bionic

# We want to use the same UID/GID of the external user to avoid permission
# issues. See the user setup at the end of the file.
ARG UID=1000
ARG GID=1000

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
  ccache \
  curl \
  ca-certificates \
  build-essential \
  clang \
  python3 \
  git \
  ninja-build \
  gcc-aarch64-linux-gnu \
  g++-aarch64-linux-gnu \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN curl -sSLO https://github.com/Kitware/CMake/releases/download/v3.25.1/cmake-3.25.1-linux-x86_64.tar.gz \
  && tar xf cmake-3.25.1-linux-x86_64.tar.gz \
  && rm cmake-3.25.1-linux-x86_64.tar.gz \
  && mkdir -p /opt \
  && mv cmake-3.25.1-linux-x86_64 /opt/cmake
ENV PATH /opt/cmake/bin:$PATH

ENV RUSTUP_HOME=/rust/rustup CARGO_HOME=/rust/cargo PATH=$PATH:/rust/cargo/bin
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | \
  sh -s -- -y --profile=minimal && \
  chmod -R a+w /rust && \
  rustup target add aarch64-unknown-linux-gnu

RUN groupadd -g ${GID} builder && \
  useradd --create-home --uid ${UID} --gid ${GID} builder
USER builder
WORKDIR /workspace
