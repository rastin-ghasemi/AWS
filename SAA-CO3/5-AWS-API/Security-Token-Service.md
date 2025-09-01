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

Returns temporary credentials for the same IAM user making the call.	

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