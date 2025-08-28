🚫 Amazon S3 Block Public Access

Block Public Access is a safety feature in Amazon S3 that prevents unintended public exposure of data. Since unrestricted S3 buckets are the #1 security misconfiguration, AWS enables this feature by default to protect your data.

⸻

🔐 Why It Matters

	•	By default, S3 buckets and objects are private.

	•	However, mistakes in ACLs or bucket policies can make them public.

	•	To prevent leaks, Block Public Access ensures you can centrally restrict all public access.

⸻

⚙️ Block Public Access Options


There are four settings that can be enabled individually or together:

	1.	Block public access to new ACLs
	•	Prevents new Access Control Lists (ACLs) from granting public access.

	2.	Block public access to any ACLs
	•	Ignores all existing ACLs that grant public access (legacy protection).

	3.	Block public access to new bucket policies or access points
	•	Prevents newly created bucket policies or access points from allowing public access.

	4.	Block public access to any bucket policies or access points
	•	Blocks existing bucket policies and access points that allow public access.


👉 Enabling Block all public access is the same as turning on all four settings.

⸻

📌 Key Notes

	•	Access points can have their own independent Block Public Access setting.

	•	This feature works at both bucket level and account level.

	•	Best practice: Always enable Block Public Access unless there’s a clear, controlled business requirement for public access (e.g., hosting a public website).

⸻

✅ Best Practices for GitHub Documentation

	•	Always enable Block Public Access by default.

	•	Review bucket policies regularly with IAM Access Analyzer.

	•	Use AWS PrivateLink or VPC Endpoints for private access instead of public endpoints.

⸻