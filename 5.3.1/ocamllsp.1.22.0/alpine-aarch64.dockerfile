FROM alpine:3.22.0 AS builder

RUN apk update && apk add \
    build-base \
    musl-dev \
    curl \
    wget \
    git \
    bash \
    opam \
    ;

# Install the OCaml compiler
ENV COMPILER_URL="https://s3.g.s4.mega.io/ycsnsngpe2elgjdd2uzbdpyj6s54q5itlvy6g/alice/tools/5.3.1/ocaml-5.3.1+relocatable-aarch64-linux-musl-static.tar.gz"
RUN wget $COMPILER_URL
RUN echo 661463be46580dd00285bef75b4d6311f2095c7deae8584667f9d76ed869276e  ocaml-5.3.1+relocatable-aarch64-linux-musl-static.tar.gz | sha256sum -c
RUN tar xf ocaml-5.3.1+relocatable-aarch64-linux-musl-static.tar.gz
RUN cp -r ocaml-5.3.1+relocatable-aarch64-linux-musl-static/* /usr

RUN adduser -D -G users -G wheel user
USER user
WORKDIR /home/user

RUN opam init --disable-sandbox --auto-setup --bare

RUN git clone --depth 1 --single-branch --branch 1.22.0-build-with-ocaml.5.3.1+relocatable https://github.com/alicecaml/ocaml-lsp
WORKDIR ocaml-lsp
COPY statically-link.diff statically-link.diff
RUN patch -p1 < statically-link.diff

# There's no Dune binary distro available for aarch64 linux, so install it with Opam instead.
RUN opam switch create . --empty
RUN opam repo add alice git+https://github.com/alicecaml/alice-opam-repo --all-switches
RUN opam update
RUN opam install -y ocaml-system.5.3.1+relocatable dune
RUN opam exec dune build

RUN cp -rvL _build/install/default ocamllsp-1.22.0-built-with-ocaml-5.3.1+relocatable-aarch64-linux-musl-static
RUN tar czf ocamllsp-1.22.0-built-with-ocaml-5.3.1+relocatable-aarch64-linux-musl-static.tar.gz ocamllsp-1.22.0-built-with-ocaml-5.3.1+relocatable-aarch64-linux-musl-static

FROM scratch
COPY --from=builder /home/user/ocaml-lsp/ocamllsp-1.22.0-built-with-ocaml-5.3.1+relocatable-aarch64-linux-musl-static.tar.gz .
