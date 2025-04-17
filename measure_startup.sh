#!/usr/bin/env bash
set -e

# === Configuration ===
AMI_ID="ami-0abcdef1234567890"     # replace with your preferred AMI
INSTANCE_TYPE="t3.small"
KEY_NAME="my-key-pair"             # must exist in your AWS account
SECURITY_GROUP="sg-0123456789abcdef0"

echo "Recording start time..."
t0=$(date +%s.%N)

echo "Launching instance..."
run_out=$(aws ec2 run-instances \
  --image-id "$AMI_ID" \
  --instance-type "$INSTANCE_TYPE" \
  --key-name "$KEY_NAME" \
  --security-group-ids "$SECURITY_GROUP" \
  --query 'Instances[0].InstanceId' \
  --output text)

INSTANCE_ID=$(echo "$run_out" | tr -d '"')
echo "Instance ID: $INSTANCE_ID"

echo "Waiting for instance to enter 'running' state..."
aws ec2 wait instance-running --instance-ids "$INSTANCE_ID"

echo "Recording end time..."
t1=$(date +%s.%N)

elapsed=$(echo "$t1 - $t0" | bc)
printf "Startup time: %.2f seconds\n" "$elapsed"

# Optional: tag and then terminate
aws ec2 create-tags --resources "$INSTANCE_ID" --tags Key=Name,Value=demo-instance
# aws ec2 terminate-instances --instance-ids "$INSTANCE_ID"
