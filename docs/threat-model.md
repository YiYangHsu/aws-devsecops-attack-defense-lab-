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
