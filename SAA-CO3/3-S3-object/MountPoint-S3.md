## Mountpoint for Amazon S3
Mountpoint for Amazon S3 is an open-source file client that allows you to mount an Amazon S3 bucket to a Linux file system, enabling applications to access S3 objects using standard file operations (read, write) with high throughput.

## Key Characteristics & Limitations:
Mountpoint is designed for specific use cases, primarily write-new and read-heavy workloads. It is not a full-featured POSIX file system.

## What Mountpoint CAN Do	
1. Read existing objects with high throughput.	

2. List directory contents

3. Create new files and write data to them.	

4. Support sequential writes for large files (e.g., big data, ML).	

## What Mountpoint CANNOT Do (Key Limitations)

1. Modify existing files. You can only create new files or overwrite existing ones entirely.

2. Delete directories.

3. Use symbolic (soft) or hard links.

4. Provide file locking (risk of data overwrite in concurrent scenarios).

5. Support random writes (appending to files is not possible).

## Supported Storage Classes
Mountpoint can be used with all S3 Storage Classes, including:

- S3 Standard

- S3 Intelligent-Tiering

- S3 Standard-Infrequent Access (Standard-IA)

- S3 One Zone-Infrequent Access (One Zone-IA)

- S3 Glacier Instant Retrieval

- S3 Glacier Flexible Retrieval

- S3 Glacier Deep Archive

**Important Note:** For Glacier Flexible Retrieval and Deep Archive, the object must first be restored to a readable state before Mountpoint can access it. Mountpoint itself does not initiate restores.


## Installation Guide: Mountpoint for Amazon S3 on Debian

Step 1: Download the Latest .deb Package

Go to the Mountpoint for Amazon S3 GitHub Releases page. Find the latest release and copy the link to the .deb package for x86_64 (most common).

Use wget to download it directly to your server. (Check the link for the latest version!)

```bash
# Example for v1.0.2. Always check for the latest version URL.
wget https://github.com/awslabs/mountpoint-s3/releases/download/v1.0.2/mount-s3_1.0.2_amd64.deb
```


Step 2: Install the Downloaded Package
```bash
sudo dpkg -i ./mount-s3_1.0.2_amd64.deb
sudo apt-get install -f
mount-s3 --version
```

Step 5: Mount Your S3 Bucket

Use the mount-s3 command to mount your bucket to the directory you just created. Replace your-bucket-name with your actual bucket name.

```bash
mount-s3 your-bucket-name ~/my-s3-bucket
```


This command will run in the foreground. It will use the AWS credentials configured in your AWS CLI.


## Example IAM Policy for Your AWS CLI User/Role
Your AWS credentials need permissions. Here is a basic IAM policy that allows mounting and read/write access to a specific bucket. Attach it to the IAM user or role your AWS CLI is using.

```bash
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject"
            ],
            "Resource": [
                "arn:aws:s3:::your-bucket-name",
                "arn:aws:s3:::your-bucket-name/*"
            ]
        }
    ]
}

```