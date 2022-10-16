#!/bin/bash
set -e

# Ref. https://docs.aws.amazon.com/vm-import/latest/userguide/vmexport_image.html
export BUCKET_NAME=
export PREFIX=

# GHCR url
export REPO=

if [ -e $REPO ]; then
  echo "REPO variable is empty"
  exit 1
fi

if [ -e $PREFIX ]; then
  echo "PREFIX variable is empty"
  exit 1
fi

if [ -e $BUCKET_NAME ]; then
  echo "BUCKET_NAME variable is empty"
  exit 1
fi

if [ -e "images/" ]; then
  rm -f images/**
fi

./scripts/create-images.sh
./scripts/create-and-download-vmdk.sh
./scripts/download-snapsthots.sh
./scripts/push-images.sh