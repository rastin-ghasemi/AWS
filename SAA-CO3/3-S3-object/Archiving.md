## Amazon S3 Archive Solutions
Archiving is the process of moving rarely accessed data to a lower-cost, long-term storage tier. S3 offers two distinct strategies for archiving objects, each suited for different scenarios.

## 1. S3 Glacier Storage Classes (Manual Management)
Use these when you know your data's access patterns and can manually manage its lifecycle. You choose the specific storage class for your objects.

- S3 Glacier Flexible Retrieval (formerly S3 Glacier):

    - **Retrieval Time:** Minutes to hours (with expedited retrieval in 1-5 minutes for a higher cost).

    - **Cost:** Lowest cost for archive data with flexible retrieval options.

    - **Use Case:** Long-term data backups, archives where retrieval isn't immediately needed.
- S3 Glacier Deep Archive:
    - **Retrieval Time:** Minimum 12 hours.

    - **Cost:** Lowest storage cost in AWS, designed for data that is rarely accessed and has no time-sensitive retrieval requirements.

    - **Use Case:** Regulatory compliance archives, data that must be retained for 7+ years.


## 2. S3 Intelligent-Tiering (Automatic Management)
Use this when you do not know or cannot predict your data's access patterns. AWS automatically moves objects between tiers based on changing access patterns.

**How it works:** This storage class includes two archive tiers that it can automatically move objects into after they have not been accessed for a continuous period (90 days).

- S3 Intelligent-Tiering Archive Access Tier:
    - **Retrieval Time:** Within milliseconds (same as Standard). Objects are automatically moved back to the Frequent Access tier when requested.

    - **Cost:** Slightly higher storage cost than manual Glacier classes, but you pay no retrieval fees when access patterns change.

- S3 Intelligent-Tiering Deep Archive Access Tier:
    - **Retrieval Time:** Minimum 12 hours (same as S3 Glacier Deep Archive).

    - **Cost:** Slightly higher storage cost than manual Deep Archive, but you pay no retrieval fees for the automatic tiering.


**Summary:** Choose manual Glacier classes for ultimate cost savings on known cold data. Choose Intelligent-Tiering to avoid retrieval fees and management effort for data with unpredictable access.