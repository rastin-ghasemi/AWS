## Amazon S3 Select

Amazon S3 Select is a feature that enables applications to retrieve only a subset of data from an object by using simple SQL clauses (e.g., SELECT, WHERE). Instead of retrieving and parsing the entire object, S3 Select filters and returns only the relevant data, dramatically improving performance and reducing cost for applications that need to access small parts of large files.

## Supported Formats & Encodings:
S3 Select works on objects stored in these formats:

    Structured Formats: CSV, JSON, or Apache Parquet.

    Compression: Supports GZIP or BZIP2 compression (for CSV and JSON objects only). Parquet files can use columnar compression like SNAPPY.

    
    Encryption: Works on server-side encrypted objects (SSE-S3, SSE-KMS).


## Output Options:
You can specify the format for the results returned by your query:

    - JSON

    - CSV

## Example AWS CLI Usage:
```bash
aws s3api select-object-content \
    --bucket my-bucket \
    --key my-data-file.csv \
    --expression "SELECT * FROM s3object WHERE temperature > 50 LIMIT 100" \
    --expression-type 'SQL' \
    --input-serialization '{"CSV": {"FileHeaderInfo": "USE"}, "CompressionType": "NONE"}' \
    --output-serialization '{"CSV": {}}' \
    output.csv
```

## Critical: Supported Storage Classes
S3 Select only works on objects in frequently accessed, standard storage tiers. It does not work on objects in archival storage classes unless they have been restored to a standard tier.

- ✅ SUPPORTED:

        S3 Standard

        S3 Standard-Infrequent Access (Standard-IA)

        S3 One Zone-Infrequent Access (One Zone-IA)

        S3 Intelligent-Tiering (only the Frequent and Infrequent Access tiers)

        S3 Glacier Instant Retrieval (This is the exception—it is supported because it provides millisecond retrieval.)