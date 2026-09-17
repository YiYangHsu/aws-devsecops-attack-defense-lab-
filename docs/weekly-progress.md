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



```

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
```
## Week 4 — ECR and ECS/Fargate

### Objective

Move the hardened Docker application from the local environment into AWS
and run it using ECS/Fargate.

### What I Built

- Amazon ECR private repository
- Immutable container image tags
- ECR vulnerability scanning
- VPC and public subnet
- Internet Gateway and route table
- Application security group
- ECS cluster
- ECS task execution IAM role
- Fargate task definition
- ECS service
- CloudWatch container logging

### Deployment Flow

Docker Image
→ Amazon ECR
→ ECS Task Definition
→ ECS Service
→ AWS Fargate
→ CloudWatch Logs

### Troubleshooting

The original `v2` image used an OCI image index containing Docker build
provenance metadata. Amazon ECR basic scanning could not scan the tagged
image index.

A new `v3` image was created using a scanner-compatible image manifest,
after which ECR successfully produced vulnerability findings.

Git Bash also converted the `/ecs/...` CloudWatch log group path into a
Windows-style path when used with the AWS CLI. Using
`MSYS_NO_PATHCONV=1` prevented this conversion.

### Security Observation

Shortly after exposing the Fargate workload publicly on TCP/8080,
CloudWatch recorded unexpected external probing.

The traffic was investigated and no evidence of successful compromise
was identified.

### Key Lesson

Deploying an application is only part of operating a cloud workload.

A security engineer must also understand:

- How the image was built
- Which vulnerabilities exist
- Which network paths are exposed
- Which IAM permissions exist
- What telemetry is available
- How unexpected activity should be investigated

## Week 5 - Container Vulnerability Management

### Completed

Built a complete container vulnerability remediation workflow using
Amazon ECR.

Started with the Debian-based `v3` image, which contained 21 ECR
findings:

- 6 Critical
- 11 High
- 3 Medium
- 1 Low

Investigated Critical glibc and Perl findings and verified the installed
packages from inside the container.

Determined that newer Debian package versions were not available through
the configured repositories.

Evaluated `python:3.12-alpine` as an alternative base image.

Built `v5`, tested application compatibility and non-root execution, and
reduced ECR findings from 21 to 5.

Traced the remaining util-linux findings to the installed Alpine
`libuuid` package.

Found an updated Alpine package version and created `v6` with
`libuuid 2.42.3-r1`.

Validated the application locally, verified non-root execution, pushed
the image to ECR, and rescanned it.

ECR Basic Scanning reported no findings for `v6` at scan time.

Updated Terraform from `v3` to `v6`, creating ECS Task Definition
revision 3.

Successfully deployed the remediated workload and verified `/` and
`/health` through its public Fargate IP.

Confirmed successful HTTP 200 requests in CloudWatch Logs.

Destroyed all 14 disposable lab resources after evidence collection.

### Key Lessons

Vulnerability management requires triage rather than blindly reacting
to severity ratings.

Container vulnerabilities can originate from inherited base-image
packages rather than application code.

A newer image tag does not mean the underlying vulnerable package has
changed.

Source package names reported by scanners may differ from installed
binary package names.

A clean vulnerability scan is a point-in-time scanner result, not proof
that software is permanently vulnerability-free.

## Week 6 - IAM Attack Surface and Least Privilege

### Completed

Created a disposable S3 IAM lab containing an allowed test object and a
restricted decoy object.

Verified the ECS workload initially had an Execution Role but no Task
Role.

Created an ECS Task Role with intentionally broad `s3:*` permissions
scoped to the disposable lab bucket.

Updated the Python application to use Boto3 and temporary ECS Task Role
credentials without storing static AWS credentials.

Built and scanned container image `v7`.

Validated that the broad Task Role allowed the application to:

- Read the intended object
- Read the restricted decoy object
- List the S3 bucket

Replaced the broad policy with least privilege:

`s3:GetObject`

on only:

`allowed/test-data.txt`

Validated the remediated permissions:

- `/s3/allowed` returned HTTP 200
- `/s3/restricted` returned HTTP 403
- `/s3/list` returned HTTP 403

CloudWatch Logs captured the before-and-after authorization behavior.

Saved IAM, ECS, and runtime evidence under:

`docs/evidence/week-06/`

Destroyed all 21 disposable lab resources after testing.

### Key Lessons

ECS Task Roles define the AWS permissions available to application code.

A compromised workload may inherit its Task Role permissions.

Broad IAM permissions increase blast radius even when the application
only requires a small subset of those permissions.

Least privilege should restrict both actions and resources.

AWS IAM implicitly denies operations that do not have an applicable
Allow.

Authorization can be tightened independently of application code when
the workload continues to use the same Task Role.