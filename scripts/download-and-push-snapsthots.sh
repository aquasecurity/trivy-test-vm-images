#!/bin/bash


if !(type "oras" > /dev/null 2>&1); then
  echo 'Please install "oras"'
  echo 'See. https://oras.land/cli'
  exit 1
fi

if !(type "coldsnap" > /dev/null 2>&1); then
  echo 'Please install "coldsnap"'
  echo 'See. https://github.com/awslabs/coldsnap'
  exit 1
fi


IDs=$(aws ec2 describe-snapshots --filters "Name=tag:Description,Values=created by packer" | jq -r ".Snapshots[].SnapshotId")
REPO=ghcr.io/masahiro331/test-vm
mkdir images
for ID in $IDs
do
  # Download snapshots
  NAME=$(aws ec2 describe-snapshots --snapshot-ids $ID | jq -r ".Snapshots[].Tags[] | .Value" | grep -v "created by packer")
  if [ ! -e "images/${NAME}.img" ]; then
    echo "Downloading images/${NAME}.img ..."
    coldsnap download $ID images/${NAME}.img
    gzip images/${NAME}.img
  fi

  # Push snapshots
  echo "Pushing ${REPO}:${NAME}.img.gz..."
  oras push ${REPO}:${NAME}.img.gz ${NAME}.img.gz
done