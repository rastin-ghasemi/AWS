## What is object storage (Object-based Storage)?
object storage is a data storage architecture that manage data as objects,as opposed to other storage architectures.

 
- S3 provides you with unlimited storage.
- you dont need to think about underlying infrastructure.
- The S3 console provides an interface for you to upload and access your data.

## S3 Object 
obects contain your data.they are like files.
object may consist of:
- Key : This is the name of object.
- value : the data itself made up of a sequence of bytes.
- version ID : when versioning enable, the version of object
- Metadata additional information attached to the object 

## S3 Bucket 
bucket hold objects. buckers can also have folders which in turn hold objects.

S3 is a universal namespace so bucket names must be unique (think like having a domain name)

-you can store  an individual object from 0 bytes to 5 terabytes in size.


## command 

```bash
# high level s3 command
aws s3 
```
and 
```bash
# Amazon simple storege service (much more command )
aws s3api

```
## # high level s3 command
1. **All avalible command**
```bash
rgh@machine:~/Work/Main/AWS/SAA-CO3/2-S3$ aws s3
> aws s3
          ls       
          website  
          cp       
          mv       
          rm       
          sync     
          mb       
          rb       
          presign  
──────────────────────
```
- If you want to learn more just google it.(Make sure useing version 2)

## cp command
1. **Example 2: Copying a local file to S3**
```bash
aws s3 cp test.txt s3://amzn-s3-demo-bucket/test2.txt
```

2. **Example 2: Copying a local file to S3 with an expiration date**
```bash
aws s3 cp test.txt s3://amzn-s3-demo-bucket/test2.txt \
    --expires 2014-10-01T20:30:00Z
```
3. **Example 1: Copying a file from S3 to S3**
```bash
aws s3 cp s3://amzn-s3-demo-bucket/test.txt s3://amzn-s3-demo-bucket/test2.txt
```
## ls
1. **Example 1: Listing all user owned buckets**
```bash
aws s3 ls
```

2. **Example 2: Listing all prefixes and objects in a bucket**
```bash
aws s3 ls s3://amzn-s3-demo-bucket
```
## rm
1. **Example 1: Delete an S3 object**
```bash
aws s3 rm s3://amzn-s3-demo-bucket/test2.txt
```
2. **Example 2: Delete all contents in a bucket**
```bash
aws s3 rm s3://amzn-s3-demo-bucket \
    --recursive
```
3. **Example 3: Delete all contents in a bucket, except ``.jpg`` files**
```bash
aws s3 rm s3://amzn-s3-demo-bucket/ \
    --recursive \
    --exclude "*.jpg"
```
## rb remove bucket (bucket should be empty)
1. **Example 1: Delete a bucket**
```bash
aws s3 rb s3://amzn-s3-demo-bucket
```

2. **Example 2: Force delete a bucket**
The following rb command uses the --force parameter to first remove all of the objects in the bucket and then remove the bucket itself. In this example, the user’s bucket is amzn-s3-demo-bucket and the objects in amzn-s3-demo-bucket are test1.txt and test2.txt:
```bash
aws s3 rb s3://amzn-s3-demo-bucket \
    --force
```

## Amazon simple storege service (aws S3api)
Important note: go to Example of commands
## create-bucket
1. **Example 1: To create a bucket**
The following create-bucket example creates a bucket named amzn-s3-demo-bucket:
```bash
aws s3api create-bucket \
    --bucket amzn-s3-demo-bucket \
    --region us-east-1
```

2. **Example 2: To create a bucket outside of the ``us-east-1`` region**
The following create-bucket example creates a bucket named amzn-s3-demo-bucket in the eu-west-1 region. Regions outside of us-east-1 require the appropriate LocationConstraint to be specified in order to create the bucket in the desired region.
```bash
aws s3api create-bucket \
    --bucket amzn-s3-demo-bucket \
    --region eu-west-1 \
    --create-bucket-configuration LocationConstraint=eu-west-1
```

## list-buckets
```bash
aws s3api list-buckets --query "Buckets[].Name"
```
query .Name just get name of buckets

```bash
aws s3api list-buckets --query "Buckets[].Name" --output table
```

2. **Example 2: get info about specific bucket**
```bash
 aws s3api list-buckets --query "Buckets[?Name == 'name-of-bucket']"
 ```

 ## get-object (download file)
 ```bash
 aws s3api get-object --bucket name --key name-of-object(file) name-of-dowanloded-file
 ```
 ## put-object (upload)
 1. **Example 1: Upload an object to Amazon S3**
 ```bash
 aws s3api put-object \
    --bucket amzn-s3-demo-bucket \
    --key my-dir/MySampleImage.png \
    --body MySampleImage.png


Take the local file ./MySampleImage.png

Upload it to the bucket named amzn-s3-demo-bucket

Store it there under the "directory" my-dir with the name MySampleImage.png
```
2. **Example 2: Upload a video file to Amazon S3**
```bash
The following put-object command example uploads a video file.

aws s3api put-object \
    --bucket amzn-s3-demo-bucket \
    --key my-dir/big-video-file.mp4 \
    --body /media/videos/f-sharp-3-data-services.mp4
```

## list-objects-v2

The following list-objects-v2 example lists the objects in the specified bucket.
```bash
aws s3api list-objects-v2 \
    --bucket amzn-s3-demo-bucket
```



## Best Practice Commands with Key Features
- Security Best Practices:
1. **Always block public access unless specifically required**

2. **Enable versioning for data protection and recovery**

3. **Enable encryption (SSE-S3 is AWS-managed, free)**

4. **Use IAM policies for fine-grained access control**

5. **Enable access logging for audit trails**

6. **Use lifecycle policies for cost optimization**

## Create Bucket with Versioning Enabled
```bash
aws s3api create-bucket \
    --bucket your-bucket-name \
    --region us-west-2 \
    --create-bucket-configuration LocationConstraint=us-west-2

# Enable versioning
aws s3api put-bucket-versioning \
    --bucket your-bucket-name \
    --versioning-configuration Status=Enabled
```
## Create Bucket with Block Public Access (Recommended)
```bash
aws s3api create-bucket \
    --bucket your-bucket-name \
    --region eu-west-1

# Block all public access (security best practice)
aws s3api put-public-access-block \
    --bucket your-bucket-name \
    --public-access-block-configuration \
    BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
```

## Create Bucket with Encryption Enabled
```bash
aws s3api create-bucket \
    --bucket your-bucket-name \
    --region us-east-1

# Enable default encryption (SSE-S3)
aws s3api put-bucket-encryption \
    --bucket your-bucket-name \
    --server-side-encryption-configuration '{
        "Rules": [
            {
                "ApplyServerSideEncryptionByDefault": {
                    "SSEAlgorithm": "AES256"
                }
            }
        ]
    }'
```
## Create Bucket with Lifecycle Policy
```bash
aws s3api create-bucket \
    --bucket your-bucket-name \
    --region ap-southeast-1

# Add lifecycle configuration
aws s3api put-bucket-lifecycle-configuration \
    --bucket your-bucket-name \
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
```