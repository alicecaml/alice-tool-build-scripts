#!/bin/sh
set -ex

docker buildx build --output type=local,dest=./out -f ubuntu-aarch64.dockerfile .
mv out/dot-merlin-reader-5.4.1-503-built-with-ocaml-5.3.1+relocatable-aarch64-linux-gnu.tar.gz .
rm -rf out
