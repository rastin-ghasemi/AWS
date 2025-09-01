## Lifecycle
Amazon S3 Lifecycle Configuration is a powerful set of rules that automate moving your objects between different storage classes or expiring (deleting) them after a defined period of time. This is a core tool for cost optimization and data management.

## Why Use Lifecycle Rules?
1. **Save Money:** Automatically move data to cheaper storage tiers when it becomes less frequently accessed.

2. **Compliance:** Enforce data retention policies by automatically deleting objects after a specific period.

3. **Operational Efficiency:** Remove the manual effort of managing object lifecycles.

## Key Concepts: Storage Class Transitions
S3 offers storage classes with different prices and access patterns. Lifecycle rules manage the movement between them.

## Types of Lifecycle Actions
There are two fundamental types of actions in a lifecycle rule:

1. **Transition Actions**

 **Purpose:** Move objects to a different storage class.

**Example:** "Move objects to S3 Standard-IA 30 days after creation."

You can have multiple transition actions in a single rule (e.g., move to IA after 30 days, then to Glacier after 90 days).

2. **Expiration Actions**

**Purpose:** Permanently delete objects.

Example: "Delete old log files 365 days after creation."

**Special Case:** Expire current versions of objects and Permanently delete previous versions are crucial for versioned buckets.

## Demo
creating a backup bucket with best practices and the lifecycle policy you specified.

Step 1: Create the S3 Bucket

First, choose a globally unique bucket name and create the bucket. We'll enable versioning and block public access by default, which are critical best practices for backups.

```bash
# Create the bucket (replace 'my-unique-backup-bucket-name' with your name)
aws s3api create-bucket \
    --bucket my-unique-backup-bucket-name \
    --region us-east-1  # Change your region if needed

# Enable Versioning (protects against accidental deletion/overwrite)
aws s3api put-bucket-versioning \
    --bucket my-unique-backup-bucket-name \
    --versioning-configuration Status=Enabled

# Confirm Block Public Access is ON (It should be by default, but let's verify/set it)
aws s3api put-public-access-block \
    --bucket my-unique-backup-bucket-name \
    --public-access-block-configuration \
    "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
```
Step 2: Create the Lifecycle Policy JSON File

Create a file named lifecycle-policy.json on your local machine with the following content. This policy does exactly what you asked for:

1. Transitions objects to the STANDARD_IA storage class after 15 days.

2. Expires (permanently deletes) object versions after 3 months (90 days).

File: lifecycle-policy.json

```bash
{
  "Rules": [
    {
      "ID": "BackupRetentionRule",
      "Status": "Enabled",
      "Filter": {
        "Prefix": "" 
      },
      "Transitions": [
        {
          "Days": 15,
          "StorageClass": "STANDARD_IA"
        }
      ],
      "Expirations": {
        "Days": 90
      }
    }
  ]
}
```

Step 3: Apply the Lifecycle Policy to Your Bucket

```bash
aws s3api put-bucket-lifecycle-configuration \
    --bucket my-unique-backup-bucket-name \
    --lifecycle-configuration file://lifecycle-policy.json
```
Step 4: Verify the Configuration

Check the lifecycle policy:
```bash
aws s3api get-bucket-lifecycle-configuration --bucket my-unique-backup-bucket-name
```

## When Should You Use Transfer Acceleration?
Transfer Acceleration is ideal for:

**Global Clients:** You have users around the world uploading to a central S3 bucket in a single region.

**Large Files:** You regularly transfer files that are hundreds of megabytes or gigabytes in size.

**Unstable Networks:** Clients are on unreliable or congested internet connections.

**Maxed-out Connections:** You are already maxing out the available TCP bandwidth on a direct connection and need higher throughput.

**Note:** For clients already in the same region as the S3 bucket, the performance gain is usually minimal or may even be slower, as the data takes a detour to the edge. It's designed for long-haul transfers.

20 Min to acctivate.

## How to Enable and Use It (Step-by-Step)
**Step 1:** Enable Transfer Acceleration on Your S3 Bucket
```bash
# Enable Transfer Acceleration for a bucket
aws s3api put-bucket-accelerate-configuration \
    --bucket YOUR-BUCKET-NAME \
    --accelerate-configuration Status=Enabled
```
## What is Virtual-Hosted Style?
Virtual-Hosted Style is one of the two main ways to structure the URL to access an object in an Amazon S3 bucket. It is the modern and recommended method by AWS.

In this style, the bucket name is placed in the hostname (domain) part of the URL, making it a subdomain of s3.amazonaws.com or a regional endpoint.

The general format is:
```bash
https://BUCKET_NAME.S3_ENDPOINT_DOMAIN/OBJECT_KEY
```
**Step 2:** (Optional) Configure CLI for Virtual-Hosted Style
This is a good global setting, but it's not strictly necessary for the one-time command if you use the correct endpoint in the next step.

```bash
aws configure set default.s3.addressing_style virtual
```
**Step 3:** Use the CORRECT Virtual-Hosted Style Endpoint for Upload/Download
```bash
aws s3 cp file.txt s3://mybucket/keyname \
    --endpoint-url https://mybucket.s3-accelerate.dualstack.amazonaws.com
```
Note: The --region parameter is redundant and unnecessary in this command because the accelerate endpoint is global. The CLI will figure it out. You can remove it.

```bash
# 1. Enable Acceleration for the bucket
aws s3api put-bucket-accelerate-configuration \
    --bucket my-website-assets \
    --accelerate-configuration Status=Enabled

# 2. Upload a large file using the correct accelerate endpoint
aws s3 cp ./large-video.mp4 s3://my-website-assets/videos/large-video.mp4 \
    --endpoint-url https://my-website-assets.s3-accelerate.dualstack.amazonaws.com

# 3. Download a file using the same endpoint
aws s3 cp s3://my-website-assets/videos/large-video.mp4 ./downloaded-video.mp4 \
    --endpoint-url https://my-website-assets.s3-accelerate.dualstack.amazonaws.com
```