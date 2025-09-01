# S3 – Requester Pays

The Requester Pays feature is a bucket-level setting that allows the bucket owner to shift the cost of data transfer and requests to the entity (the "requester") downloading the data. The bucket owner still pays for all storage costs.

## What the Requester Pays For:
- When Requester Pays is enabled on a bucket, the requester is charged for:

    - Data Transfer Costs (cost to download data from S3 to the internet).

    - Request Costs (cost of GET, LIST, or other requests they make).

## What the Bucket Owner Always Pays For:
The bucket owner is still responsible for:

    - Data Storage Costs (the monthly cost of storing the objects).

    - Data Transfer IN (cost to upload data into S3).

    - Management feature costs (e.g., S3 Inventory, Storage Class Analysis).

## How It Works (Technically):
The requester must explicitly indicate they agree to pay the charges in their request. This is done by including the header x-amz-request-payer with a value of requester in any API call (e.g., using the AWS CLI, SDK, or even a signed URL).

Example AWS CLI command for a requester:

```bash
aws s3 cp s3://requester-pays-bucket-name/large-file.zip . --request-payer
``` 

## Corrected IAM Policy Example:
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
            "Resource": "arn:aws:s3:::bucket-name/*",
            "Condition": {
                "StringEquals": {
                    "s3:RequestPayer": "requester"
                }
            }
        }
    ]
}
```

## Common Causes of 403 Errors:
1. **Missing Request Payer Header:** The requester did not include the required x-amz-request-payer: requester parameter in their request. This is the most common cause.

2. **Authentication Failure:** The request lacks valid AWS credentials, or the IAM user/role making the request does not have the necessary permissions in its policy (e.g., missing the s3:RequestPayer condition).

3. **Anonymous Request:** The request is not signed with AWS credentials. Anonymous access is explicitly prohibited for Requester Pays buckets.

4. **SOAP Protocol:** The request was made using the legacy SOAP API. SOAP requests are not supported for Requester Pays buckets; you must use the REST API, CLI, or SDK.