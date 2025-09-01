## Encryption in transit
It means encrypting your data while it's being transmitted over a network to prevent eavesdropping, interception, or manipulation. This is separate from encryption at rest (which protects data stored on disk).

## Encryption-At-Rest

**Client-Side Encryption (CSE)**

When data is encrypted by the client and then sent to the server

**Server-side Encrypted(SSE)**

when the data is encrypted by the server


## 🔐 Encryption In-Transit (TLS/SSL)

**Definition:**

Encryption in transit protects your data while it’s moving from one place to another (e.g., from your computer to Amazon S3 over the internet).
It prevents unauthorized people from intercepting, reading, or tampering with the data during transfer.

## How it works

	1. Sender-side Encryption:

	•	Before the data leaves your computer (client), it’s encrypted using TLS (Transport Layer Security) or SSL (Secure Sockets Layer).
	
    •	Example: Uploading a file (PDF) to S3 → data is encrypted before going through the internet.
	
    2.	Transmission:

	•	The data travels securely over the internet.

	•	Even if a hacker intercepts the packets, they will see only encrypted content, not the original file.

	3.	Server-side Decryption:

	•	At the destination (S3 bucket), Amazon automatically decrypts the data so the application or authorized users can use it.

⸻

##  Algorithms: TLS vs SSL

1. Transport Layer Security (TLS)
	
    •	The modern protocol for encryption in transit.
	
    •	Provides confidentiality, integrity, and authenticity of the communication.
	
    •	Current status:
	
    •	TLS 1.0 and 1.1 = ❌ Deprecated
	
    •	TLS 1.2 = ✅ Secure and widely used
	
    •	TLS 1.3 = ✅ Best practice (more secure, faster handshakes)

2. Secure Sockets Layer (SSL)
	
    •	The older version of TLS.
	
    •	All SSL versions (1.0, 2.0, 3.0) = ❌ Deprecated (no longer secure).
	
    •	Should never be used anymore.

👉 In practice, when you connect to S3 (or any AWS service) using HTTPS, you are using TLS.

⸻

📌 Example in AWS S3
	
    •	When uploading/download files (PUT, GET) with HTTPS → data is encrypted in transit.
	
    •	AWS SDKs and AWS CLI automatically use TLS 1.2 or 1.3.
	
    •	If you use HTTP (not HTTPS), your data will travel unencrypted (not recommended).

⸻

📌 Key Benefits of Encryption In-Transit
	
    •	Confidentiality – nobody can read your data while it’s moving.
	
    •	Integrity – ensures the data is not modified in transit.
	
    •	Authentication – verifies that the server you connect to (e.g., Amazon S3) is the real one.

⸻

✅ Summary:
	
    •	Always use HTTPS (TLS 1.2/1.3) for S3 data transfers.
	
    •	SSL is obsolete, TLS is the standard.
	
    •	Encryption in transit ensures your files are safe between your machine and S3, but once in S3, you should also consider encryption at rest (SSE-S3, SSE-KMS, etc.) for end-to-end protection.

##
**who manages the keys.**


## 🔐 S3 – Server-Side Encryption (SSE) Default

Definition:

Server-side encryption means that Amazon S3 encrypts your objects after it receives them and before saving them to disk, and then decrypts them when you access them.

👉 This ensures data is encrypted at rest (inside S3 storage).

⸻

## 1️⃣ SSE-S3 (Amazon S3-Managed Keys)
	
    •	How it works:
	
    •	Amazon S3 handles all encryption and key management for you.
	
    •	Uses AES-256 encryption automatically.
	
    •	Management:
	
    •	You do nothing—S3 generates and manages the keys.
	
    •	Use Case:
	
    •	Easiest option (default encryption if you don’t configure anything).
	
    •	When you don’t need fine-grained control over keys.

Pros:

✅ Simple, no setup.

✅ No extra cost.

✅ Secure with AES-256.


Cons:

❌ No control over keys.

⸻

## 2️⃣ SSE-KMS (AWS Key Management Service Keys)
	
    •	How it works:
	
    •	Encryption keys are stored in AWS KMS (Key Management Service).
	
    •	You can use AWS-managed keys (aws/s3) or create your own customer-managed CMKs (Customer Master Keys).
	
    •	Management:
	
    •	AWS manages encryption, but you can control access to keys via IAM policies & KMS key policies.
	
    •	Use Case:
	
    •	When you need more control, auditing, or compliance requirements.

Pros:

✅ Centralized key management with KMS.

✅ Fine-grained access control (per bucket, object, or user).

✅ Integration with CloudTrail (audit logs).

Cons:

❌ Slight cost for KMS API calls.

❌ More complexity than SSE-S3.

⸻

## 3️⃣ SSE-C (Customer-Provided Keys)
	
    When you upload an object, Amazon S3 uses the encryption key that you provide to apply AES-256 encryption to your data. Amazon S3 then removes the encryption key from memory. When you retrieve an object, you must provide the same encryption key as part of your request. Amazon S3 first verifies that the encryption key that you provided matches, and then it decrypts the object before returning the object data to you.

There are no additional charges for using SSE-C. However, requests to configure and use SSE-C incur standard Amazon S3 request charges. For information about pricing, see Amazon S3 pricing.

    •	How it works:
	
    •	You generate and manage your own encryption keys.
	
    •	You pass the key along with your PUT/GET requests to S3.
	
    •	S3 uses your key to encrypt/decrypt but does not store the key.
	
    •	Management:
	
    •	You are fully responsible for key management and security.
	
    •	Use Case:
	
    •	When you want complete control over encryption keys outside AWS.

Pros:

✅ Maximum control.

✅ AWS never stores your keys.

Cons:

❌ High responsibility—if you lose the key, you lose the data.

❌ More complex to implement.

## demo for SSE-C
You need to create a cryptographically strong random key and base64-encode it.

```bash
# Generate 32 random bytes and base64 encode them
dd if=/dev/urandom bs=1 count=32 2>/dev/null | base64 > sse-c-key.txt
```
**Step 2: Create a New S3 Bucket**

SSE-C is set on a per-object basis during upload, not as a default bucket policy. The bucket itself doesn't need any special encryption configuration.
```bash
aws s3api create-bucket \
    --bucket my-unique-ssec-bucket-20230829 \
    --region us-east-1
```
**Step 3: Upload an Object using SSE-C**
This is where you provide your key for the upload operation. The CLI will read the key from the file and send the required headers. Notice the --sse-customer-key flag.
```bash
# Upload a test file
echo "This is my highly sensitive data, encrypted with my own key!" > secret-file.txt

# Upload with SSE-C
aws s3api put-object \
    --bucket my-unique-ssec-bucket-20230829 \
    --key secret-file.txt \
    --body secret-file.txt \
    --sse-customer-algorithm AES256 \
    --sse-customer-key fileb://sse-c-key.txt
```
## 4️⃣ DSSE-KMS (Dual-Layer Server-Side Encryption with KMS Keys)
	
    •	How it works:
	
    •	Introduced for highly regulated industries (healthcare, finance, government).
	
    •	Applies two independent layers of encryption using two separate KMS keys.
	
    •	One layer is applied by S3, and another by KMS.
	
    •	Management:
	
    •	Keys are managed in AWS KMS, but you define which keys to use.
	
    •	Use Case:
	
    •	When regulations demand multi-layer encryption.

Pros:


✅ Strongest security model in S3.

✅ Useful for compliance (HIPAA, FedRAMP, PCI DSS).

Cons:

❌ More costly (double KMS operations).

❌ More complex than standard SSE-KMS.

⸻

📌 Important Note (from your slide):
Server-side encryption protects object contents but not metadata (e.g., object name, size, and some metadata remain unencrypted).


## What is an S3 Bucket Key?

An S3 Bucket Key is a temporary, per-bucket data key that Amazon S3 generates and manages for you. It is used to encrypt objects within a single S3 bucket, instead of S3 calling AWS KMS for every single object operation.

Here's the analogy:

**Standard SSE-KMS (without Bucket Key):** Every time you upload a file (PutObject), S3 calls KMS. KMS generates a unique data key for that one file, using your customer master key (CMK). This happens for every single file, leading to many KMS API calls.

Upload File.txt -> Call KMS -> Get Data Key -> Encrypt file

Upload Image.jpg -> Call KMS -> Get Data Key -> Encrypt image

Cost: You pay for each KMS API call.

**SSE-KMS with Bucket Key:** S3 calls KMS once to generate a single Bucket Key. This Bucket Key is then cached and used to create the unique data keys for multiple objects within that bucket for a period of time (typically up to 1 hour).

S3 -> Call KMS once -> Get a Bucket Key

Upload File.txt -> Use Bucket Key -> Get Data Key -> Encrypt file

Upload Image.jpg -> Use same Bucket Key -> Get Data Key -> Encrypt image

Cost: You pay for far fewer KMS API calls.

- Key Benefits
1. **Cost Reduction:** This is the primary benefit. It can reduce the cost of AWS KMS requests by up to 99%! Instead of paying for a KMS API call (GenerateDataKey) for every object upload/download, you pay for roughly one call per hour per bucket.

2. **Performance Improvement:** By reducing the number of calls to KMS, upload and download operations are faster, as there's less network latency and processing overhead.

## How to Enable bucket key
You can enable the Bucket Key in two ways:

1. **As the default for a whole bucket (Recommended)**

This is set using the put-bucket-encryption command, as shown in the previous SSE-KMS setup. The BucketKeyEnabled boolean is the crucial part.

```bash
aws s3api put-bucket-encryption \
    --bucket my-unique-bucket-name \
    --server-side-encryption-configuration '{
        "Rules": [
            {
                "ApplyServerSideEncryptionByDefault": {
                    "SSEAlgorithm": "aws:kms",
                    "KMSMasterKeyID": "alias/my-key-alias"
                },
                "BucketKeyEnabled": true # <-- This enables it for the bucket
            }
        ]
    }'
```

2. **For an individual object during upload**
You can override the bucket's default setting on a per-request basis.

```bash
aws s3api put-object \
    --bucket my-unique-bucket-name \
    --key my-file.txt \
    --body my-file.txt \
    --server-side-encryption aws:kms \
    --sse-kms-key-id alias/my-key-alias \
    --bucket-key-enabled # <-- This enables it for just this upload
```

- How to Check if a Bucket Key is Enabled
```bash
aws s3api get-bucket-encryption \
    --bucket my-unique-bucket-name
```

- Important Considerations

1. **Backwards Compatibility:** The Bucket Key is used for encryption. When you download an object, S3 automatically handles decryption whether the Bucket Key was used or not. There's no difference for the client.

2. **Requires SSE-KMS:** The Bucket Key feature only works with SSE-KMS encryption. It is not available for SSE-S3 or SSE-C.

3. **KMS Permissions Still Apply:** All the same KMS key policies and IAM permissions are still required for the underlying CMK. The Bucket Key is just a performance/cost optimization layer on top.

4. **Enabled by Default** in AWS Console: When you enable default encryption with a KMS key for a bucket using the AWS Management Console, S3 Bucket Key is now enabled by default.

## Client-Side Encryption

```bash

# 1. Generate your own 256-bit key (and guard it preciously!)
openssl rand -out my-aes-key.bin 32

# 2. Encrypt a file locally using OpenSSL
openssl enc -aes-256-cbc -in plaintext-file.txt -out encrypted-file.enc -pass file:./my-aes-key.bin

# 3. Upload the already-encrypted file to S3. AWS sees only ciphertext.
aws s3 cp encrypted-file.enc s3://my-bucket/

# 4. Download the ciphertext
aws s3 cp s3://my-bucket/encrypted-file.enc .

# 5. Decrypt it locally using your key
openssl enc -d -aes-256-cbc -in encrypted-file.enc -out decrypted-file.txt -pass file:./my-aes-key.bin
```