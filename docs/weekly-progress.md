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

## 2. Update `weekly-progress.md`

Add:

```markdown
## Week 2 — Terraform Bootstrap and Remote State

### Objective

Create a secure Terraform foundation that supports persistent remote state
and disposable AWS lab environments.

### What I Built

- Terraform bootstrap configuration
- Persistent S3 state bucket
- S3 versioning
- S3 Block Public Access
- Server-side encryption
- S3 remote backend
- Terraform state locking

### Architecture

```text
Bootstrap Terraform
       |
       v
Persistent S3 Backend
       |
       v
Lab Terraform
       |
       v
Disposable AWS Infrastructure



---

# 3. Update `weekly-progress.md`

Add this Week 3 section:

```markdown
## Week 3 — Docker Fundamentals and Container Hardening

### Objective

Understand Docker images, containers, ports, processes, and container
users while building a security baseline for the application.

### What I Built

- Python HTTP application
- Dockerfile
- Docker image Version 1
- Hardened Docker image Version 2
- Local container with port 8080 exposed

### Docker Workflow

```text
Source Code
    |
    v
Dockerfile
    |
    v
docker build
    |
    v
Docker Image
    |
    v
docker run
    |
    v
Running Container


---

# 4. Check what Git will commit

From your repository root:

```bash
git status