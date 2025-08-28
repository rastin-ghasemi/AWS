
Configuring ACLs for S3 buckets requires careful consideration as AWS is moving away from bucket ACLs. Here's the best approach:

⚠️ Important Note: Avoid Bucket ACLs When Possible
AWS recommends using bucket policies and IAM policies instead of bucket ACLs for better security and management.

- Recommended Approach: Bucket Policies + IAM

## Create New Bucket


```bash
aws s3api create-bucket --bucket name --region us-east-1
```

## Turn off Block Public Access

```bash
aws s3api put-public-access-block \
    --bucket your-bucket-name \
    --public-access-block-configuration \
    BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=true,RestrictPublicBuckets=true
```
**What Those Settings Mean**
- When all are set to true:

1. **BlockPublicAcls=true:**

 The S3 system will reject and ignore any API command (like put-object-acl or put-bucket-acl) that tries to set a public ACL (e.g., public-read, public-read-write) on the bucket or any object within it.

2. **IgnorePublicAcls=true:**

 Even if a public ACL somehow already exists on an object (e.g., from before you enabled this setting), S3 will completely ignore it and treat the object as private.

3. **BlockPublicPolicy=true:**

 The S3 system will reject any bucket policy that contains a statement granting public access.

4. **RestrictPublicBuckets=true:**

 Even if a bucket policy exists that grants public access, S3 will ignore the public parts of that policy. Only users with explicit IAM permissions will be granted access.

## Check it

```bash

aws s3api get-public-access-block --bucket name-of-bucket
```

## change bucket ownership (for enable the ACL)

```bash
aws s3api put-bucket-ownership-controls \
--bucket name \
--ownership-controls="Rules=[{ObjectOwner=BucketOwnerPreferred}]"
```

## What private ACL Means
private is the default and most secure ACL (Access Control List) setting for Amazon S3 buckets and objects.

**When you set an ACL to private, it means:**

1. **Ownership and Access:**
Only the bucket owner (the AWS account that created the bucket) has full control over the object/bucket

2. **No public access**
 anonymous users cannot access the object

3. No other AWS accounts can access the object unless explicitly granted permission through other means

## Get the Canonical User ID
First, you need to find the canonical user ID for the target AWS account:

```bash
# For a user in your own account, they can find their canonical ID with:
aws s3api list-buckets --query Owner.ID --output text

# For another account, you need to ask them for their canonical user ID
# It typically looks like: 79a59df900b949e55d96a1e698fbacedfd6e09d98eacf8f8d5218e7cd47ef2be
```
**Grant Read Access via ACL**
- Using AWS CLI:
```bash
aws s3api put-object-acl \
    --bucket your-bucket-name \
    --key path/to/object.txt \
    --grant-read id="79a59df900b949e55d96a1e698fbacedfd6e09d98eacf8f8d5218e7cd47ef2be" \
    --acl private
```
- Using a Predefined ACL Grant:
```bash
aws s3api put-object-acl \
    --bucket your-bucket-name \
    --key path/to/object.txt \
    --grant-read uri="http://acs.amazonaws.com/groups/global/AuthenticatedUsers" \
    --acl private
```
**Full ACL Configuration Example**
For more complex ACL grants, you can use a JSON structure:

```bash
{
    "Grants": [
        {
            "Grantee": {
                "Type": "CanonicalUser",
                "ID": "79a59df900b949e55d96a1e698fbacedfd6e09d98eacf8f8d5218e7cd47ef2be"
            },
            "Permission": "READ"
        },
        {
            "Grantee": {
                "Type": "CanonicalUser",
                "ID": "your-own-canonical-id"  # Keep owner access
            },
            "Permission": "FULL_CONTROL"
        }
    ],
    "Owner": {
        "ID": "your-own-canonical-id"
    }
}
```
Save this as acl.json and apply it:

```bash
aws s3api put-object-acl \
    --bucket your-bucket-name \
    --key path/to/object.txt \
    --access-control-policy file://acl.json
```
