#!/bin/bash

if !(type "packer" > /dev/null 2>&1); then
  echo 'Please install "packer"'
  echo 'See. https://github.com/hashicorp/packer'
  exit 1
fi

# Create Image
TEMPLATES=$(ls -1  templates/*.json)
for template in $TEMPLATES
do
  packer build ${template}
done