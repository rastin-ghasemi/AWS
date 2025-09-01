## Security Token Service (STS)

AWS STS is a service that creates temporary security credentials for authenticating against AWS services. These credentials are short-lived (from 15 minutes to 36 hours) and are a secure alternative to using long-term access keys (access key ID and secret access key).

## Key Features & Benefits:
**Temporary:** Credentials expire automatically, reducing the security risk of compromised keys.

**Limited Privilege:** You can request credentials that are more restricted than the original user's permissions.

**Federation:** Allows users from external systems (like your corporate directory or identity providers like Facebook, Google, etc.) to access AWS resources without needing an IAM user.

**No Additional Cost:** There is no charge for using AWS STS.

## Common STS API Actions (Use Cases)

These are the core functions you'll use STS for:(API Action	)

**AssumeRole**  : The most common action. Returns temporary credentials for an IAM Role.	

**AssumeRoleWithWebIdentity** : Returns credentials for users authenticated by a public identity provider (IdP) like Amazon Cognito, Facebook, Google, or any OpenID Connect (OIDC) compatible IdP.

**AssumeRoleWithSAML** : 
Returns credentials for users authenticated by a SAML 2.0 compliant identity provider (like Active Directory Federation Services - ADFS, Okta, Auth0).	

**GetSessionToken** : 

Returns temporary credentials for the same IAM user making the call.Temporary elevation of own access


**GetFederationToken** : Returns temporary credentials for a federated user (a user not defined in IAM). Less common than the AssumeRole actions.	

## How Temporary Credentials Work:
Temporary credentials consist of three parts:

1. Access Key ID (e.g., ASIA...)

2. Secret Access Key

3. Session Token

You must include all three components in your API calls or CLI configuration to use them. The session token is what differentiates them from long-term credentials.

## Example CLI Usage for AssumeRole:
```bash
# Assume a role and store the temporary credentials in environment variables
aws sts assume-role \
    --role-arn "arn:aws:iam::123456789012:role/ExampleRole" \
    --role-session-name "ExampleSession"

# The response will contain Credentials: AccessKeyId, SecretAccessKey, SessionToken
export AWS_ACCESS_KEY_ID=ASIA...
export AWS_SECRET_ACCESS_KEY=...
export AWS_SESSION_TOKEN=...
```

## demo
## Step 1: Create the IAM Role (If Needed)
1.1 Create Role with Trust Policy
```bash
# Create role trust policy file (trust-policy.json)
# who can use this role.
cat > trust-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::YOUR-ACCOUNT-ID:root"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

# Create the role
aws iam create-role \
  --role-name CrossAccountRole \
  --assume-role-policy-document file://trust-policy.json
```
## Trust Policy in AWS IAM: The "Who Can Assume This Role" Rule
A trust policy (also called assume-role policy) is an IAM policy that defines which principals (users, accounts, services) are allowed to assume an IAM role. It's the gatekeeper that says "who can use this role."

- Think of it like a club bouncer:

    - The role is the club

    - The trust policy is the bouncer who checks IDs

    - Only people on the list (specified in the policy) can enter

So in 1.1 We create a role and say who can assume role.
## Step 2: Attach S3 Access Policy to the Role
2.1 Create Policy for "privet" Bucket Access
```bash
cat > s3-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::privet",
        "arn:aws:s3:::privet/*"
      ]
    }
  ]
}
EOF
```
Explanation: This policy allows listing, reading, and writing to the "privet" bucket.


2.2 Attach Policy to Role
```bash
aws iam put-role-policy \
  --role-name S3PrivetAccessRole \
  --policy-name S3PrivetAccessPolicy \
  --policy-document file://s3-policy.json
```
```bash
## Step 3: Assume the Role for 4 Hours

# Default: 1 hour (3600 seconds)
aws sts assume-role \
  --role-arn arn:aws:iam::123456789012:role/MyRole \
  --role-session-name MySession #  custom name you make up to identify this specific role
```
```bash
# Assume role for 4 hours (14400 seconds)
ASSUMED_CREDS=$(aws sts assume-role \
  --role-arn "arn:aws:iam::YOUR-ACCOUNT-ID:role/S3PrivetAccessRole" \
  --role-session-name "privet-access-$(date +%Y%m%d-%H%M)" \
  --duration-seconds 14400)  # 4 hours = 14400 seconds

# Check for errors
if [ $? -ne 0 ]; then
  echo "Failed to assume role. Check if role exists and you have permission."
  exit 1
fi
```
3.2 Extract Temporary Credentials

```bash
export AWS_ACCESS_KEY_ID=$(echo $ASSUMED_CREDS | jq -r .Credentials.AccessKeyId)
export AWS_SECRET_ACCESS_KEY=$(echo $ASSUMED_CREDS | jq -r .Credentials.SecretAccessKey)
export AWS_SESSION_TOKEN=$(echo $ASSUMED_CREDS | jq -r .Credentials.SessionToken)
export AWS_SESSION_EXPIRATION=$(echo $ASSUMED_CREDS | jq -r .Credentials.Expiration)

echo "Session valid until: $AWS_SESSION_EXPIRATION"
```


## Demp 2
When an imaginary user like "Ali" needs access, you give him permission to assume the role rather than giving him direct permissions.

## Step 1: Create Role (WHAT can be done)
```bash
# Create role that has S3 access to "privet" bucket
aws iam create-role \
  --role-name S3PrivetAccessRole \
  --assume-role-policy-document file://trust-policy.json

# Attach S3 permissions to the role
aws iam attach-role-policy \
  --role-name S3PrivetAccessRole \
  --policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess
```
## Step 2: Allow "Ali" to Assume the Role (WHO can do it)
```bash
# Update trust policy to allow ONLY Ali
cat > trust-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::YOUR-ACCOUNT-ID:user/ali"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

# Update the role's trust policy
aws iam update-assume-role-policy \
  --role-name S3PrivetAccessRole \
  --policy-document file://trust-policy.json
```
```bash
# Ali runs this command to get temporary access
ASSUMED_CREDS=$(aws sts assume-role \
  --role-arn arn:aws:iam::YOUR-ACCOUNT-ID:role/S3PrivetAccessRole \
  --role-session-name "ali-access")

# Ali uses the temporary credentials
export AWS_ACCESS_KEY_ID=$(echo $ASSUMED_CREDS | jq -r .Credentials.AccessKeyId)
export AWS_SECRET_ACCESS_KEY=$(echo $ASSUMED_CREDS | jq -r .Credentials.SecretAccessKey)
export AWS_SESSION_TOKEN=$(echo $ASSUMED_CREDS | jq -r .Credentials.SessionToken)

# Now Ali can access the privet bucket
aws s3 ls s3://privet/
```