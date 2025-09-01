## S3 Event Notifications
S3 Event Notifications enable you to receive automated alerts when specific events happen in your S3 bucket. This allows you to build event-driven architectures that integrate S3 with other AWS services without the need to constantly poll your bucket for changes.

## Supported Event Types:
You can configure notifications for a wide variety of object-level operations, including:

        Object Creation Events: s3:ObjectCreated:* (e.g., Put, Post, Copy, CompleteMultipartUpload)

        Object Removal Events: s3:ObjectRemoved:* (e.g., Delete, DeleteMarkerCreated)

        Restore Events: s3:ObjectRestore:* (e.g., for objects restored from Glacier)

        Replication Events: s3:Replication:* (e.g., OperationFailedReplication, OperationMissedThreshold)

        Lifecycle Events:

                s3:LifecycleExpiration:* (when an object expires)

                s3:LifecycleTransition:* (when an object transitions to a different storage class)

        Intelligent-Tiering Events: s3:IntelligentTiering (when an object is moved to the Archive Access tier)

        Object Tags & ACLs: s3:ObjectTagging:*, s3:ObjectAcl:Put

Note: Reduced Redundancy Storage (RRS) object lost events is a legacy event type. RRS is deprecated and should not be used for new solutions.

## Destination Services:
Event notifications can be sent to one or more of these AWS services for processing:

- Amazon Simple Notification Service (SNS) topics: For fan-out messaging to multiple subscribers (e.g., email, SMS, HTTP endpoints).

- Amazon Simple Queue Service (SQS) queues: For reliable, decoupled message delivery to a single consumer application.

- Standard queues are supported. FIFO queues are NOT supported for S3 event notifications.

- AWS Lambda functions: To trigger serverless code that processes the object immediately after the event (e.g., creating thumbnails, validating content, indexing metadata).

- Amazon EventBridge: For advanced routing, filtering, and integration with over 15 AWS services and third-party SaaS applications. EventBridge provides a more granular filtering capability than native S3 notifications.

## Delivery Guarantee:
Amazon S3 event notifications are designed to be delivered "at least once."

This means that in rare cases, you might receive the same notification more than once.

Your application logic at the destination (especially with Lambda) should be idempotent (able to handle duplicate events without duplicate side effects).

Notifications are typically delivered in seconds but can sometimes take a minute or longer.