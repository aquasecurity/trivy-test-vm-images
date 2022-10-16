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
  name=$(cat $template | jq -r ".builders[].ami_name")
  ret=$(aws ec2 describe-images \
    --owners self \
    --filters "Name=name,Values=$name" | jq ".Images[]")
  if [ -z "$ret" ]; then
    packer build ${template}
  else
    echo "Skip build $name"
  fi
done