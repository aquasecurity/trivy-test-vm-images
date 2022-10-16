#!/bin/bash
set -e

export BUCKET_NAME=
export PREFIX=
export REPO=

if [ -e "images/" ]; then
  rm -f images/**
fi

if [ -e $REPO ]
then
  echo "REPO variable is empty"
  exit 1
fi

if [ -e $PREFIX ]
then
  echo "PREFIX variable is empty"
  exit 1
fi

if [ -e $BUCKET_NAME ]
then
  echo "BUCKET_NAME variable is empty"
  exit 1
fi

# ./scripts/create-images.sh
./scripts/create-and-download-vmdk.sh
./scripts/download-snapsthots.sh
./scripts/push-images.sh