# AWS DevSecOps Attack & Defense Lab

## Project Overview

This project is a hands-on AWS cloud security lab designed to develop practical skills in 
DevSecOps, 
container security, 
threat detection, 
incident investigation, 
and incident response.

The environment will use disposable AWS infrastructure managed with Terraform. Lab resources can be deployed when needed and destroyed after each learning session to reduce cloud costs and improve infrastructure reproducibility.

## Project Goals

The goals of this project are to learn how to:

* Deploy containerized applications in AWS.
* Secure container images and workloads.
* Apply least-privilege IAM permissions.
* Identify vulnerable or insecure configurations.
* Generate and analyze security telemetry.
* Detect suspicious activity.
* Investigate security incidents.
* Perform containment and remediation.
* Integrate security checks into CI/CD.
* Manage AWS infrastructure using Terraform.

## High-Level Architecture

```text
Internet
   |
   v
Containerized Application
   |
   v
Amazon ECS / Fargate
   |
   +----> CloudWatch Logs
   |
   +----> IAM Task Role
              |
              v
           AWS APIs

Security Monitoring:

CloudTrail
GuardDuty
Security Hub
Amazon Inspector
```

## Security Learning Model

The project follows this security workflow:

```text
Asset
  ↓
Threat

  ↓
Attack Path
  ↓
Prevention
  ↓
Detection
  ↓
Investigation
  ↓
Containment
  ↓
Remediation
```

## Infrastructure Strategy

Most AWS resources in the lab will be disposable.

```text
terraform apply
      ↓
Deploy Lab
      ↓
Run Security Exercise
      ↓
Investigate
      ↓
Document Results
      ↓
terraform destroy
```

Terraform remote state will remain persistent in Amazon S3.

## Project Status

Current phase:

**Week 1 — Architecture and Threat Modeling**
