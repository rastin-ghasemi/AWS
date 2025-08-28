
## 📝 Amazon S3 Bucket Policies
With Amazon S3 bucket policies, you can secure access to objects in your buckets, so that only users with the appropriate permissions can access them. You can even prevent authenticated users without the appropriate permissions from accessing your Amazon S3 resources.
An S3 Bucket Policy is a resource-based policy that allows you to manage access at the bucket and object level.
It can grant permissions to:

**principles**
	
    •	AWS accounts
	
    •	IAM users
	
    •	IAM roles
	
    •	AWS services


Unlike IAM policies (which are identity-based), bucket policies are directly attached to the S3 bucket and control access to its resources.

⸻

## 🎯 Example 1: Allow a Specific Role to Access Objects with a Tag

**Json file**

```bash

{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Principal": {
        "AWS": "arn:aws:iam::123456789012:role/ProdTeam"
      },
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion"
      ],
      "Resource": "arn:aws:s3:::my-bucket/*",
      "Condition": {
        "StringEquals": {
          "s3:ExistingObjectTag/environment": "prod"
        }
      }
    }
  ]
}

```

✅ This policy:

	•	Grants read-only access (s3:GetObject)

	•	Only to the IAM role ProdTeam

	•	Only for objects tagged with environment=prod



## 🎯 Example 2: Restrict Access to a Specific IP Range

- jsdon

```bash
{
  "Version": "2012-10-17",
  "Id": "S3PolicyId1",
  "Statement": [
    {
      "Sid": "IPAllow",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:*",
      "Resource": [
        "arn:aws:s3:::my-bucket",
        "arn:aws:s3:::my-bucket/*"
      ],
      "Condition": {
        "NotIpAddress": {
          "aws:SourceIp": "192.0.2.0/24"
        }
      }
    }
  ]
}

```


**✅ This policy:**


	•	Explicitly denies all S3 actions (s3:*)

	•	For everyone (Principal: *)

	•	If the request does not come from 192.0.2.0/24 subnet


## ⚖️ Key Notes
	
    •	Bucket policies are evaluated together with IAM identity policies.
	
    
    •	Explicit Deny always overrides any Allow.
	
    •	Always use least privilege → only grant required actions to specific principals.
	
    •	Combine with Block Public Access for maximum security.


## 🚀 Best Practices
	
    1.	Use conditions (e.g., IP, tags, VPC endpoints) to narrow down access.
	
    2.	Avoid "Principal": "*" unless you’re explicitly creating a public bucket.
	
    3.	Use ARNs for precise targeting of users/roles.
	
    4.	Regularly audit policies with IAM Access Analyzer.

## 🎯 The Core Difference

**Bucket Policy: Attached to the S3 bucket (the resource)**

IAM Policy: Attached to IAM users, groups, or roles (the principal)*


## demo 

```bash
aws s3api put-bucket-policy --bucket name --policy file://local.json
```
This example allows all users to retrieve any object in amzn-s3-demo-bucket except those in the MySecretFolder. It also grants put and delete permission to the root user of the AWS account 1234-5678-9012:

```bash
aws s3api put-bucket-policy --bucket amzn-s3-demo-bucket --policy file://policy.json

policy.json:
{
   "Statement": [
      {
         "Effect": "Allow",
         "Principal": "*",
         "Action": "s3:GetObject",
         "Resource": "arn:aws:s3:::amzn-s3-demo-bucket/*"
      },
      {
         "Effect": "Deny",
         "Principal": "*",
         "Action": "s3:GetObject",
         "Resource": "arn:aws:s3:::amzn-s3-demo-bucket/MySecretFolder/*"
      },
      {
         "Effect": "Allow",
         "Principal": {
            "AWS": "arn:aws:iam::123456789012:root"
         },
         "Action": [
            "s3:DeleteObject",
            "s3:PutObject"
         ],
         "Resource": "arn:aws:s3:::amzn-s3-demo-bucket/*"
      }
   ]
}

```

## bucket policies vs IAM policies
both  control access to S3, but they work from different perspectives and have distinct use cases.

**🎯 The Core Difference**

Bucket Policy: Attached to the S3 bucket (the resource)

**"Who can access this data?"**

IAM Policy: Attached to IAM users, groups, or roles (the principal)
 
 **What can this user do?"**

**📋 Bucket Policies (Resource-Based)**
- Attached to: The S3 bucket itself

**When to Use:**

When you want to control access to a specific bucket

For cross-account access (allowing other AWS accounts)

For public access (though this should be done cautiously)

When you don't want to modify IAM policies for many users

**Example Bucket Policy:**

```bash
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::123456789012:user/alice"
            },
            "Action": [
                "s3:GetObject",
                "s3:PutObject"
            ],
            "Resource": "arn:aws:s3:::my-bucket/*"
        }
    ]
}
```

- Key Characteristics:
Defines "Who" can access "This Bucket"

Can allow/deny specific AWS accounts, IAM users, or public access

Useful for data sharing between accounts

## 👤 IAM Policies (Identity-Based)
- Attached to: IAM users, groups, or roles

**When to Use:**
When you want to control what specific users/roles can do across AWS

For fine-grained access control based on user identity

When users need access to multiple buckets

For temporary credentials (via IAM Roles)

**Example IAM Policy:**

1. **First we create IAM Policy**
```bash
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:PutObject"
            ],
            "Resource": [
                "arn:aws:s3:::bucket-a/*",
                "arn:aws:s3:::bucket-b/*"
            ]
        }
    ]
}
```
then:
```bash
aws iam create-policy \
    --policy-name S3BucketAccessPolicy \
    --policy-document file://policy.json
```
2. **Who Gets Access(3 type)?**

1. Attached to an IAM User:
```bash
# User "alice" gets access to bucket-a and bucket-b
aws iam attach-user-policy \
    --user-name alice \
    --policy-arn arn:aws:iam::123456789012:policy/S3BucketAccessPolicy
```

2. Attached to an IAM Role:
```bash
# Any entity that assumes this role gets the access
aws iam attach-role-policy \
    --role-name MyAppRole \
    --policy-arn arn:aws:iam::123456789012:policy/S3BucketAccessPolicy
```
3. Attached to an IAM Group:
```bash
# All users in "Developers" group get access
aws iam attach-group-policy \
    --group-name Developers \
    --policy-arn arn:aws:iam::123456789012:policy/S3BucketAccessPolicy
```