#!/bin/bash

images=$(ls -1 images/)

for img in $images
do
  if [ -e "images/${img}" ]; then
    # Push snapshots
    echo "Pushing ${REPO}:${img}"
    oras push ${REPO}:${img} images/${img}
  fi
done