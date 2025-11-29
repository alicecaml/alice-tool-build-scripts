FROM ubuntu:noble-20250529 AS builder

RUN apt-get update -y && apt-get upgrade -y && apt-get install -y \
    build-essential \
    curl \
    wget \
    git \
    bash \
    ;

# Install the OCaml compiler
ENV COMPILER_URL="https://github.com/alicecaml/alice-tools/releases/download/5.3.1+relocatable/ocaml-5.3.1+relocatable-x86_64-linux-gnu.tar.gz"
RUN wget $COMPILER_URL
RUN echo 3a7d69e8a8650f4527382081f0cfece9edf7ae7e12f3eb38fbb3880549b2ca90  ocaml-5.3.1+relocatable-x86_64-linux-gnu.tar.gz | sha256sum -c
RUN tar xf ocaml-5.3.1+relocatable-x86_64-linux-gnu.tar.gz
RUN cp -r ocaml-5.3.1+relocatable-x86_64-linux-gnu/* /usr

# Install Dune
RUN curl -fsSL https://github.com/ocaml-dune/dune-bin-install/releases/download/v3/install.sh | sh -s 3.20.2 --install-root /usr --no-update-shell-config

RUN useradd --create-home --gid users user
USER user
WORKDIR /home/user

RUN git clone --depth 1 --single-branch --branch 5.4.1-503-build-with-ocaml.5.3.1+relocatable https://github.com/alicecaml/dot-merlin-reader
WORKDIR dot-merlin-reader
RUN dune build
RUN cp -rvL _build/install/default dot-merlin-reader-5.4.1-503-built-with-ocaml.5.3.1+relocatable-x86_64-linux-gnu
RUN tar czf dot-merlin-reader-5.4.1-503-built-with-ocaml.5.3.1+relocatable-x86_64-linux-gnu.tar.gz dot-merlin-reader-5.4.1-503-built-with-ocaml.5.3.1+relocatable-x86_64-linux-gnu

FROM scratch
COPY --from=builder /home/user/dot-merlin-reader/dot-merlin-reader-5.4.1-503-built-with-ocaml.5.3.1+relocatable-x86_64-linux-gnu.tar.gz .
