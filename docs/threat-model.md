# Threat Model

## 1. System Description

The project will deploy an internet-accessible containerized application using Amazon ECS and AWS Fargate.

The application will interact with AWS services using an ECS task IAM role.

Security services will provide logging, vulnerability detection, threat detection, and centralized security findings.

---

## 2. Assets

The following assets require protection:

| Asset             | Why It Matters                                  |
| ----------------- | ----------------------------------------------- |
| Web Application   | Publicly accessible attack surface              |
| Container         | Runs the application                            |
| Container Image   | May contain vulnerable software                 |
| ECS Task IAM Role | Provides AWS permissions to the workload        |
| AWS Credentials   | Could allow AWS API access if abused            |
| AWS Account       | Contains cloud infrastructure and services      |
| Application Logs  | Required for investigations                     |
| CloudTrail Logs   | Record AWS API activity                         |
| Terraform State   | Contains infrastructure information             |
| GitHub Repository | Contains infrastructure and CI/CD configuration |

---

## 3. Threat Actor

The primary threat actor for this lab is an external attacker.

### Attacker Can

* Access the public application.
* Send HTTP requests.
* Probe the application.
* Attempt to exploit application vulnerabilities.

### Attacker Cannot Initially

* Access the AWS console.
* Access the developer workstation.
* Directly access private AWS resources.

---

## 4. Main Attack Path

The primary attack scenario is:

```text
External Attacker
       |
       v
Public Application
       |
       | Application vulnerability
       v
Container Compromise
       |
       v
AWS Credentials / ECS Task Role
       |
       v
AWS API Calls
       |
       v
Unauthorized Cloud Activity
```

---

## 5. Initial Threats

| ID  | Threat                            | Potential Impact                    |
| --- | --------------------------------- | ----------------------------------- |
| T01 | Vulnerable application dependency | Application or container compromise |
| T02 | Vulnerable container image        | Code execution inside workload      |
| T03 | Container running insecurely      | Increased impact after compromise   |
| T04 | Excessive IAM permissions         | Unauthorized AWS resource access    |
| T05 | Stolen workload credentials       | AWS API abuse                       |
| T06 | Suspicious AWS API activity       | Cloud resource compromise           |
| T07 | Missing logs                      | Difficult incident investigation    |

---

## 6. Planned Security Controls

### Preventive Controls

* Container vulnerability scanning.
* Minimal container images.
* Non-root container execution.
* Least-privilege IAM.
* Secure Terraform configuration.
* CI/CD security scanning.

### Detective Controls

* CloudWatch Logs.
* AWS CloudTrail.
* Amazon GuardDuty.
* Amazon Inspector.
* AWS Security Hub.

### Response Controls

* Stop affected workloads.
* Restrict compromised IAM permissions.
* Replace vulnerable container images.
* Redeploy infrastructure.
* Document incident timelines.
* Improve preventive controls after incidents.

---

## 7. Primary Security Question

The main security question for this project is:

> If an attacker compromises the application container, what can they do next, how can AWS detect the activity, and how should we respond?

## Attack Scenario 01 — Vulnerable Container and S3 Data Access

### Scenario

An external attacker exploits vulnerable software in the
internet-facing application and gains access to the running container.

The compromised workload has an ECS task IAM role that allows the
application to read objects from an S3 bucket.

### Assets

- ECS workload
- Container image
- ECS task IAM role
- S3 bucket
- Data stored in S3

### Vulnerability

The container image contains outdated software with a known
security vulnerability.

### Threat

An attacker may exploit the vulnerable application, compromise the
container, and abuse the workload's AWS permissions.

### Attack Path

Internet
→ Public application
→ Vulnerable software
→ Container compromise
→ ECS task IAM role
→ AWS API
→ S3 bucket
→ S3 data

### Potential Impact

An attacker could use the permissions available to the compromised
workload to access application data stored in S3.

### Preventive Controls

- Patch vulnerable application dependencies.
- Use updated container base images.
- Scan container images for vulnerabilities.
- Apply least-privilege IAM permissions.

### Detective Controls

- Use CloudTrail to provide visibility into AWS API activity.
- Use GuardDuty to identify suspicious activity.

### Incident Response

If compromise is confirmed:

1. Contain the affected ECS workload.
2. Stop the compromised task.
3. Investigate the activity and determine the root cause.
4. Review and restrict IAM permissions.
5. Fix the vulnerable application or container image.
6. Build a new clean image.
7. Redeploy the workload.
8. Verify that the vulnerability has been remediated.
