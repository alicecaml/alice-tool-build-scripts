FROM ubuntu:noble-20250529 AS builder

RUN apt-get update -y && apt-get upgrade -y && apt-get install -y \
    build-essential \
    curl \
    wget \
    git \
    bash \
    unzip \
    ;

# Install Opam. Don't use the apt package because it would interfere with alice's OCaml binary distribution.
RUN curl -fsSL https://opam.ocaml.org/install.sh > install_opam.sh && yes '' | sh install_opam.sh

# Install the OCaml compiler
ENV COMPILER_URL="https://s3.g.s4.mega.io/ycsnsngpe2elgjdd2uzbdpyj6s54q5itlvy6g/alice/tools/5.3.1/ocaml-5.3.1+relocatable-aarch64-linux-gnu.tar.gz"
RUN wget $COMPILER_URL
RUN echo c89f1fc2a34222a95984a05e823a032f5c5e7d6917444685d88e837b6744491a ocaml-5.3.1+relocatable-aarch64-linux-gnu.tar.gz | sha256sum -c
RUN tar xf ocaml-5.3.1+relocatable-aarch64-linux-gnu.tar.gz
RUN cp -r ocaml-5.3.1+relocatable-aarch64-linux-gnu/* /usr

RUN useradd --create-home --gid users user
USER user
WORKDIR /home/user

RUN opam init --disable-sandbox --auto-setup --bare

RUN git clone --depth 1 --single-branch --branch 0.27.0-build-with-ocaml.5.3.1+relocatable https://github.com/alicecaml/ocamlformat
WORKDIR ocamlformat

# There's no Dune binary distro available for aarch64 linux, so install it with Opam instead.
RUN opam switch create . --empty
RUN opam repo add alice git+https://github.com/alicecaml/alice-opam-repo --all-switches
RUN opam update
RUN opam install -y ocaml-system.5.3.1+relocatable dune
RUN opam exec dune build

RUN cp -rvL _build/install/default ocamlformat-0.27.0-built-with-ocaml-5.3.1+relocatable-aarch64-linux-gnu
RUN tar czf ocamlformat-0.27.0-built-with-ocaml-5.3.1+relocatable-aarch64-linux-gnu.tar.gz ocamlformat-0.27.0-built-with-ocaml-5.3.1+relocatable-aarch64-linux-gnu

FROM scratch
COPY --from=builder /home/user/ocamlformat/ocamlformat-0.27.0-built-with-ocaml-5.3.1+relocatable-aarch64-linux-gnu.tar.gz .
