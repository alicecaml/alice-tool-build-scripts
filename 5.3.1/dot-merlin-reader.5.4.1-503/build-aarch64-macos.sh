#!/bin/sh

# Build dot-merlin-reader with the relocatable compiler. This script is mostly
# hermetic however currently it requires "dune" be in your PATH when the script
# is run.

set -ex

COMPILER_URL="https://github.com/alicecaml/alice-tools/releases/download/5.3.1+relocatable/ocaml-5.3.1+relocatable-aarch64-macos.tar.gz"

TMP=$(mktemp -d -t alice)
trap 'rm -rf $TMP' EXIT

ORIGINAL_DIR="$PWD"
cd "$TMP"

wget "$COMPILER_URL"
echo 4e9b683dc39867dcd5452e25a154c2964cd02a992ca4d3da33a46a24b6cb2187  ocaml-5.3.1+relocatable-aarch64-macos.tar.gz | sha256sum -c -
tar xf ocaml-5.3.1+relocatable-aarch64-macos.tar.gz
export PATH=$PWD/ocaml-5.3.1+relocatable-aarch64-macos/bin:$PATH

which ocamlc
which dune

git clone --depth 1 --single-branch --branch 5.4.1-503-build-with-ocaml.5.3.1+relocatable https://github.com/alicecaml/dot-merlin-reader
cd dot-merlin-reader
export DUNE_CONFIG__PORTABLE_LOCK_DIR=enabled
dune build
cd ..
mkdir dot-merlin-reader-5.4.1-503-built-with-ocaml-5.3.1+relocatable-aarch64-macos
for dir in bin doc lib; do
    cp -rvL dot-merlin-reader/_build/install/default/$dir dot-merlin-reader-5.4.1-503-built-with-ocaml-5.3.1+relocatable-aarch64-macos
done
mkdir -p dot-merlin-reader-5.4.1-503-built-with-ocaml-5.3.1+relocatable-aarch64-macos/doc

tar czf dot-merlin-reader-5.4.1-503-built-with-ocaml-5.3.1+relocatable-aarch64-macos.tar.gz dot-merlin-reader-5.4.1-503-built-with-ocaml-5.3.1+relocatable-aarch64-macos
cp dot-merlin-reader-5.4.1-503-built-with-ocaml-5.3.1+relocatable-aarch64-macos.tar.gz "$ORIGINAL_DIR/"
