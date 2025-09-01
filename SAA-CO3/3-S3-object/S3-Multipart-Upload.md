## Amazon S3 Multipart Upload

Multipart Upload is an API designed for uploading large objects in parts. It is recommended for objects larger than 100 MB and is required for objects between 5 GB and 5 TB. Its primary benefits are improved throughput, faster recovery from network failures, and the ability to pause and resume uploads.

## The 3-Step Process:

1. **Initiate the Upload**
This command starts the process and returns a unique Upload ID, which is required for all subsequent operations.

```bash
aws s3api create-multipart-upload \
    --bucket my-bucket \
    --key 'my-large-file.zip'
# Response includes a crucial "UploadId"
```


## 2. Upload Parts
2. Upload Parts
Upload the object in individual parts. Each part is a contiguous portion of the object's data. Parts can be uploaded in any order and in parallel for significant performance gains.

- Parts are numbered from 1 to 10,000.

- Except for the last part, each part must be at least 5 MB in size.

- You must record the ETag and PartNumber for each successfully uploaded part.

```bash
aws s3api upload-part \
    --bucket my-bucket \
    --key 'my-large-file.zip' \
    --part-number 1 \ # Part numbers from 1 to 10000
    --body part01.file \ # The local file for this part
    --upload-id "dfRtDYU0WMCCCH43C..." # From the initiation step
# Response includes an "ETag" for this part
```
## 3. Complete the Upload
After all parts are uploaded, you must provide S3 with a list of part numbers and their corresponding ETags. S3 then assembles the parts into a single object.

```bash
aws s3api complete-multipart-upload \
    --bucket my-bucket \
    --key 'my-large-file.zip' \
    --multipart-upload file://parts.json \ # File mapping parts to ETags
    --upload-id "dfRtDYU0WMCCCH43
```