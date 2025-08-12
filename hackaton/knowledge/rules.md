
# Our Company's Architectural Rules
1. All public-facing APIs must be protected by an API Gateway with rate limiting.
2. Databases must never be exposed to the public internet. They should reside in a private subnet.
3. Use a managed database service (like SQL MI or RDS) instead of running a database on a VM.
