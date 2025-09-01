## S3 Batch Operations
S3 Batch Operations is a powerful service for performing large-scale, repetitive actions on billions of S3 objects containing exabytes of data with a single request. It eliminates the need to write custom scripts or manage complex workflows.

## How It Works:
1. **Create a Manifest:** You provide a list of objects to process. This list is called a manifest.

2. **Choose an Operation:** Select the action you want to perform on every object in the manifest.

3. **Run the Job:** S3 Batch Operations processes the objects. You can choose to run the job automatically or preview the results first.

4. **Review the Report:** Upon completion, Batch Operations generates a detailed report showing the success or failure of each operation.

## Supported Operation Types:

**Copy Object:** Copy objects to another bucket or prefix.

**Invoke AWS Lambda Function:** Run a custom Lambda function to perform any transformation or action on each object.

**Replace Tags:** Replace all existing tags on an object with a new set.

**Modify Access Control List (ACL):** Replace the ACL for each object.

**Restore Objects:** Initiate restores for objects archived in S3 Glacier Flexible Retrieval or Deep Archive.

**Set Object Lock Retention:** Apply a retention date to protect objects from deletion for a fixed period.

**Set Object Lock Legal Hold:** Apply a legal hold to protect objects from deletion indefinitely until the hold is removed.

## Manifest Formats:
You must provide a list of objects to process. This can be done using:

- S3 Inventory Report: The recommended method. You can specify your pre-existing S3 Inventory report as the manifest.

- CSV File: A custom CSV file with a specific format. The standard format includes:

        bucket (The name of the bucket)

        key (The object key, i.e., its path and name)

        versionId (Optional, if versioning is enabled)

Completion Report:

You can configure the job to generate a completion report that is written to a bucket of your choice. This report details the outcome (success or failure) for every object in the manifest, which is essential for auditing and troubleshooting.