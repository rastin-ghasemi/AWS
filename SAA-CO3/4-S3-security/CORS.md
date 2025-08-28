## AWS S3 Cross-Origin Resource Sharing (CORS)

AWS S3 Cross-Origin Resource Sharing (CORS) is a mechanism that allows web applications running in one domain to access resources from a different domain (origin). This is essential for modern web applications that serve static assets from S3 while the application itself runs on a different domain.
## 🎯 What is CORS?

**CORS enables:**

JavaScript AJAX calls to S3 from different domains

Web fonts loading from S3

Canvas images loaded from S3

CSS shapes from external resources

## 📝 S3 CORS Configuration

Basic CORS Configuration JSON:

```bash
{
  "CORSRules": [
    {
      "AllowedHeaders": [
        "*"
      ],
      "AllowedMethods": [
        "GET",
        "PUT",
        "POST",
        "DELETE",
        "HEAD"
      ],
      "AllowedOrigins": [
        "https://www.example.com",
        "http://localhost:3000"
      ],
      #  these headers are being exposed to the browser:
      "ExposeHeaders": [                   
        "x-amz-server-side-encryption", # Indicates the encryption status of the object
        "x-amz-request-id", # Unique identifier for the S3 request (for debugging)
        "x-amz-id-2" # Additional request identifier used internally by AWS
      ],
      "MaxAgeSeconds": 3000 # The browser can cache this CORS configuration for 3000 seconds (50 minutes)
    }
  ]
}
```
- two domain **"https://www.example.com", "http://localhost:3000"** can acess our bucket. 
# Apply CORS configuration
```bash
aws s3api put-bucket-cors \
    --bucket your-bucket-name \
    --cors-configuration file://cors-config.json
```
## ⚠️ Security Best Practices
1. Avoid "*" for AllowedOrigins in production

2. Be specific with AllowedHeaders

3. Use minimal AllowedMethods

4. Set appropriate MaxAgeSeconds

## 🔍 Troubleshooting CORS Issues

**Check Current CORS Configuration:**
```bash
aws s3api get-bucket-cors --bucket your-bucket-name
```

**Common CORS Errors:**

No 'Access-Control-Allow-Origin' header: CORS not configured

Origin not allowed: Origin not in AllowedOrigins

Method not allowed: HTTP method not in AllowedMethods

## Debugging with curl:
```bash
curl -H "Origin: https://www.example.com" \
     -H "Access-Control-Request-Method: GET" \
     -H "Access-Control-Request-Headers: Content-Type" \
     -X OPTIONS --verbose \
     https://your-bucket.s3.amazonaws.com/your-object
```

##   Advanced CORS Configuration
Multiple Rules with Different Permissions:
```bash
{
  "CORSRules": [
    {
      "AllowedOrigins": ["https://www.example.com"],
      "AllowedMethods": ["GET", "HEAD", "PUT", "POST", "DELETE"],
      "AllowedHeaders": ["*"],
      "MaxAgeSeconds": 3000
    },
    {
      "AllowedOrigins": ["https://cdn.example.com"],
      "AllowedMethods": ["GET", "HEAD"],
      "AllowedHeaders": ["Authorization"],
      "MaxAgeSeconds": 3600
    }
  ]
}
```


## demo  Step-by-Step Complete Setup
Step 1: Create the S3 Bucket
```bash
# Create a unique bucket name (must be globally unique)
BUCKET_NAME="my-domain-bucket-$(date +%s)"
echo "Creating bucket: $BUCKET_NAME"

# Create the bucket
aws s3api create-bucket \
    --bucket $BUCKET_NAME \
    --region us-east-1 \
    --acl private
```

Step 2: Enable Public Access Block (Security First!)
```bash
aws s3api put-public-access-block \
    --bucket $BUCKET_NAME \
    --public-access-block-configuration \
    BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=false
```
Note: We set RestrictPublicBuckets=false to allow our bucket policy to work

Step 3: Create CORS Configuration
```bash
# Create CORS config file
cat > cors-config.json << EOL
{
  "CORSRules": [
    {
      "AllowedHeaders": ["*"],
      "AllowedMethods": ["GET", "PUT", "POST", "DELETE", "HEAD"],
      "AllowedOrigins": [
        "https://www.example.com",
        "http://localhost:3000",
        "https://example.com"
      ],
      "ExposeHeaders": [
        "x-amz-server-side-encryption",
        "x-amz-request-id",
        "x-amz-id-2"
      ],
      "MaxAgeSeconds": 3000
    }
  ]
}
EOL

# Apply CORS configuration
aws s3api put-bucket-cors \
    --bucket $BUCKET_NAME \
    --cors-configuration file://cors-config.json
```

Step 4: Create Bucket Policy
```bash
# Create bucket policy file
cat > bucket-policy.json << EOL
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowDomainAccess",
      "Effect": "Allow",
      "Principal": "*",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject"
      ],
      "Resource": "arn:aws:s3:::$BUCKET_NAME/*",
      "Condition": {
        "StringLike": {
          "aws:Referer": [
            "https://www.example.com/*",
            "https://example.com/*",
            "http://localhost:3000/*"
          ]
        }
      }
    },
    {
      "Sid": "AllowDomainListBucket",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::$BUCKET_NAME",
      "Condition": {
        "StringLike": {
          "aws:Referer": [
            "https://www.example.com/*",
            "https://example.com/*",
            "http://localhost:3000/*"
          ]
        }
      }
    }
  ]
}
EOL

# Apply bucket policy
aws s3api put-bucket-policy \
    --bucket $BUCKET_NAME \
    --policy file://bucket-policy.json
```

Step 5: Enable Static Website Hosting (Optional but Recommended)
```bash
aws s3 website s3://$BUCKET_NAME/ --index-document index.html --error-document error.html
```