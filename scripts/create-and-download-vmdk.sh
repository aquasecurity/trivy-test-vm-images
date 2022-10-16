#!/bin/bash
set -e

# Create vmdk

if !(type "aws" > /dev/null 2>&1); then
  echo 'Please install "aws"'
  echo 'See. https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html'
  exit 1
fi


IMAGE_IDs=$(aws ec2 describe-images \
  --owner self \
  --filters "Name=tag:Description,Values=created by packer" \
  | jq -r ".Images[].ImageId")

taskIds=()
for IMAGE_ID in $IMAGE_IDs
do
  echo "Run export task (image_id: $IMAGE_ID)"
  taskId=$(aws ec2 export-image --image-id $IMAGE_ID \
    --disk-image-format VMDK \
    --tag-specifications "ResourceType=export-image-task,Tags=[{Key=AMI,Value=${IMAGE_ID}}]" \
    --s3-export-location S3Bucket=${BUCKET_NAME},S3Prefix=${PREFIX} \
    | jq -r ".ExportImageTaskId")

  echo "Exporting image (task_id: ${taskId})..."
  taskIds+=($taskId)
done

completeTaskIds=()
for taskId in ${taskIds[@]}
do
  # Timeout 15 min
  for i in $(seq 0 15)
  do
    echo "Waiting tasks..."
    taskStatus=$(aws ec2 describe-export-image-tasks \
      --export-image-task-ids $taskId \
      | jq -r ".ExportImageTasks[].Status")
    if [ ! "active" == "${taskStatus}" ]; then
      if [ "completed" == "${taskStatus}" ]; then
        echo "Completed ${taskId}"
	completeTaskIds+=($taskId)
      else
        echo "Failed ${taskId} (status: ${taskStatus})"
      fi
      break
    fi
    sleep 60
  done
done

for completeTaskId in ${completeTaskIds[@]}
do

  value=$(aws ec2 describe-export-image-tasks \
    --export-image-task-ids \
    $completeTaskId \
    | jq -r ".ExportImageTasks[].Tags[].Value")

  name=$(aws ec2 describe-images --image-ids $value \
    | jq -r ".Images[].Tags[] | .Value" \
    | grep -v "created by packer")

  mkdir -p images/
  aws s3 cp s3://${BUCKET_NAME}/${PREFIX}${completeTaskId}.vmdk images/${name}.vmdk.img
  gzip images/${name}.vmdk.img
done