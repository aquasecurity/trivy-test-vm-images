#!/bin/bash
set -e

export BUCKET_NAME=export-aws-images-masahiro331
export PREFIX=images/
export REPO=ghcr.io/masahiro331/test-vm

if [ -e "images/" ]; then
  rm -f images/**
fi

# ./scripts/create-images.sh
./scripts/create-and-download-vmdk.sh
./scripts/download-snapsthots.sh
./scripts/push-images.sh