#!/bin/bash

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