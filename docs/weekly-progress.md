# Weekly Progress

## Week 1 — Architecture and Threat Modeling

### Objective

Understand the high-level architecture of the AWS DevSecOps Attack & Defense Lab and identify the primary security risks before deploying infrastructure.

### What I Learned

This week I learned that security architecture should begin by identifying assets, threats, attack paths, and security controls rather than immediately deploying security tools.

### Key Assets

* Containerized application
* Container image
* ECS task IAM role
* AWS credentials
* AWS account
* Logs
* Terraform state
* GitHub repository

### Main Attack Path

```text
Attacker
   ↓
Application
   ↓
Container
   ↓
IAM Credentials
   ↓
AWS API
```

### Key Security Insight

A compromised container does not automatically mean the entire AWS account is compromised.

The impact depends heavily on what permissions the container's IAM role has.

This demonstrates why least-privilege IAM is an important cloud security control.

### Questions for Future Weeks

* How does an ECS container receive AWS credentials?
* How can a container image be scanned for vulnerabilities?
* What activity does CloudTrail record?
* What can GuardDuty detect?
* How can an analyst investigate suspicious activity?
* How can CI/CD prevent insecure workloads from being deployed?
