#!/bin/bash

# Function to ask yes/no question
ask_yes_no() {
    local prompt="$1 (y/n): " # local makes the variable only accessible within this function
    local response
    
    while true; do
        read -p "$prompt" response
        case $response in #  The case statement compares the value of $response against different patterns
            [Yy]* ) return 0;; # [Yy]* matches any response starting with 'Y', 'y', or any variation like "yes", "Yes", "YES", "y", "Y"
            [Nn]* ) return 1;;
            * ) echo "Please answer yes or no.";;
        esac #  esac is "case" spelled backwards, which is how bash ends a case block
    done
}
# Get user input
echo "=== AWS S3 Bucket Creation with Best Practices ==="
read -p "Enter bucket name (leave empty for auto-generated name): " BUCKET_NAME
read -p "Enter AWS region (default: us-east-1): " REGION

# Set defaults if empty
if [ -z "$REGION" ]; then
    REGION="us-east-1"
fi

# Confirm settings
echo ""
echo "Bucket configuration:"
echo "  Name: $BUCKET_NAME"
echo "  Region: $REGION"
echo ""


if ! ask_yes_no "Continue with these settings?"; then
    echo "Aborting bucket creation."
    exit 1
fi
# Explanation:

# if starts a conditional statement

# ! is the logical NOT operator - it inverts the result (true becomes false, false becomes true)

# ask_yes_no "Continue with these settings?" calls our function with this prompt text

# ; then indicates the start of the code block to execute if the condition is true

# How it works:

# If user answers "yes" → function returns 0 (success) → ! makes this false → condition fails → skips the then block

# If user answers "no" → function returns 1 (failure) → ! makes this true → condition passes → executes the then block

# Create the bucket
echo ""
echo "Creating bucket..."
if [ "$REGION" = "us-east-1" ]; then
    aws s3api create-bucket --bucket "$BUCKET_NAME" --region "$REGION"
else
    aws s3api create-bucket --bucket "$BUCKET_NAME" --region "$REGION" \  # if region is not in us-east-1 we should create-bucket-configuration
        --create-bucket-configuration LocationConstraint="$REGION"
fi
# Check if bucket creation was successful
if [ $? -ne 0 ]; then
    echo "Error: Failed to create bucket. Please check your AWS credentials and try again."
    exit 1
fi

echo "Bucket $BUCKET_NAME created successfully!"

# Ask about additional features
echo ""
echo "=== Additional Configuration Options ==="

# Versioning
if ask_yes_no "Enable versioning?"; then
    echo "Enabling versioning..."
    aws s3api put-bucket-versioning --bucket "$BUCKET_NAME" --versioning-configuration Status=Enabled
fi

# Block Public Access
if ask_yes_no "Block all public access (recommended)?"; then
    echo "Blocking public access..."
    aws s3api put-public-access-block --bucket "$BUCKET_NAME" \
        --public-access-block-configuration \
        BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
fi

# Default Encryption
if ask_yes_no "Enable default encryption (SSE-S3)?"; then
    echo "Enabling default encryption..."
    aws s3api put-bucket-encryption --bucket "$BUCKET_NAME" \
        --server-side-encryption-configuration '{
            "Rules": [
                {
                    "ApplyServerSideEncryptionByDefault": {
                        "SSEAlgorithm": "AES256"
                    }
                }
            ]
        }'
fi

# Lifecycle Policy
if ask_yes_no "Configure lifecycle policy?"; then
    echo "Configuring lifecycle policy..."
    aws s3api put-bucket-lifecycle-configuration --bucket "$BUCKET_NAME" \
        --lifecycle-configuration '{
            "Rules": [
                {
                    "ID": "MoveToGlacierAfter30Days",
                    "Status": "Enabled",
                    "Filter": {},
                    "Transitions": [
                        {
                            "Days": 30,
                            "StorageClass": "GLACIER"
                        }
                    ]
                }
            ]
        }'
fi

# Server Access Logging
if ask_yes_no "Enable server access logging?"; then
    read -p "Enter target bucket for logs: " LOG_BUCKET
    if [ -n "$LOG_BUCKET" ]; then
        echo "Enabling server access logging..."
        aws s3api put-bucket-logging --bucket "$BUCKET_NAME" \
            --bucket-logging-status "{
                \"LoggingEnabled\": {
                    \"TargetBucket\": \"$LOG_BUCKET\",
                    \"TargetPrefix\": \"logs/$BUCKET_NAME/\"
                }
            }"
    else
        echo "No log bucket specified, skipping access logging."
    fi
fi

# Display final configuration
echo ""
echo "=== Final Bucket Configuration ==="
echo "Bucket: $BUCKET_NAME"
echo "Region: $REGION"
echo "Versioning: $(aws s3api get-bucket-versioning --bucket "$BUCKET_NAME" --query Status --output text || echo "Disabled")"
echo "Public Access Block: Enabled"
echo "Default Encryption: $(aws s3api get-bucket-encryption --bucket "$BUCKET_NAME" --query 'ServerSideEncryptionConfiguration.Rules[0].ApplyServerSideEncryptionByDefault.SSEAlgorithm' --output text 2>/dev/null || echo "Not configured")"

echo ""
echo "Bucket creation and configuration complete!"
echo "You can access your bucket at: https://s3.console.aws.amazon.com/s3/buckets/$BUCKET_NAME"