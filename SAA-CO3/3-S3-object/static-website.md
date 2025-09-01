## S3 Static Website Hosting
Amazon S3 Static Website Hosting allows you to host static websites (HTML, CSS, JavaScript, images, fonts) directly from an S3 bucket. It is a simple, cost-effective solution for serving content that does not require server-side processing.

## Key Features & Endpoints:
**Website Endpoint:** When you enable static website hosting, S3 provides a unique public URL (endpoint) for your website. This is different from the standard S3 REST API endpoint.

- Format: http://<bucket-name>.s3-website-<Region>.amazonaws.com

or 
- http://<bucket-name>.s3-website.<Region>.amazonaws.com (note the period instead of a hyphen)

**Example: http://my-website.s3-website-us-east-1.amazonaws.com**

**Index and Error Documents:** You must specify an index document (e.g., index.html) and can optionally specify an error document (e.g., error.html).

## Critical Security Note: HTTPS
- The S3 website endpoint itself does NOT support HTTPS.

- To serve your website securely over HTTPS, you must use Amazon CloudFront in front of your S3 bucket origin. CloudFront provides free SSL/TLS certificates via AWS Certificate Manager (ACM).

## Hosting Types:
1. Host a static website: The standard method for serving your website's files.

2. Redirect requests: Configure the entire bucket to redirect all requests to another domain name (e.g., redirect www.example.com to example.com).

## Important Limitations:
- Requester Pays: Buckets with Requester Pays enabled cannot be used for static website hosting. The website endpoint does not support the required authentication.

- Server-Side Scripting: S3 only hosts static content. It cannot run server-side code like PHP, Ruby, or Node.js. For dynamic websites, use services like AWS Amplify, Elastic Beanstalk, or EC2.