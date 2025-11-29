#!/bin/sh
set -ex

docker buildx build --output type=local,dest=./out -f ubuntu-x86_64.dockerfile .
mv out/dot-merlin-reader-5.4.1-503-build-with-ocaml.5.3.1+relocatable-x86_64-linux-gnu.tar.gz .
rm -rf out
