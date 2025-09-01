## what is A pre-signed URL??
A pre-signed URL is a powerful and fundamental feature of Amazon S3 (and other AWS services) for granting temporary, secure access to a private object without requiring AWS credentials.

```bash
aws s3 presign s3://my-bucket/my-private-object.txt \
    --expires-in 300
```

 ## Anatomy of a Pre-Signed URL (Structured Breakdown)
## Base Object URL:
https://mybucket.s.amazonaws.com/myobject

This is the standard path to the object.

Authentication Query Parameters:
?X-Amz-Algorithm=AWS4-HMAC-SHA256

Specifies the AWS signature version 4 (SigV4) algorithm used to create the signature.

&X-Amz-Credential=YOUR_AWS_ACCESS_KEY%2F20231125%2Fus-east-1%2Fs3%2Faws4_request

The most important parameter for tracking.

Encodes the Access Key ID of the IAM entity that generated the URL.

Includes the scope of the signature: Date (20231125), Region (us-east-1), Service (s3), and termination string (aws4_request).

&X-Amz-Date=20231125T123456Z

The exact timestamp (in UTC) when the URL was signed.

&X-Amz-Expires=300

The number of seconds the URL is valid from the X-Amz-Date timestamp. In this case, 300 seconds (5 minutes).

&X-Amz-SignedHeaders=host

Lists which HTTP headers are included in the signature calculation. host is almost always the only one for basic pre-signed URLs.

&X-Amz-Signature=GENERATED_SIGNATURE

The cryptographic proof.

A complex hash generated using your AWS Secret Access Key, the request details, and the "string to sign." AWS recalculates this when the URL is used; if it matches, access is granted.

