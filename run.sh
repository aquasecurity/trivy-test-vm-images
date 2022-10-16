#!/bin/bash
set -e

export BUCKET_NAME=a
export PREFIX=a
export REPO=a

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

ret=$(aws ec2 describe-images --filters "Name=tag:Description,Values=created by packer" | jq -r ".Images[].ImageId")
if [ -z "$ret" ]; then
  ./scripts/create-images.sh
fi

if [ -e "images/" ]; then
  rm -f images/**
fi

./scripts/create-and-download-vmdk.sh
./scripts/download-snapsthots.sh
./scripts/push-images.sh