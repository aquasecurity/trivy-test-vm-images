#!/bin/bash

# Create Image
TEMPLATES=$(ls -1  templates/*.json)
for template in $TEMPLATES
do
  packer build ${template}
done