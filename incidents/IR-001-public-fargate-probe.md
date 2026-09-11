# IR-001 — Unexpected External Probe Against Public Fargate Workload

## Summary

During Week 4 of the AWS DevSecOps Attack & Defense Lab, unexpected
external traffic was observed against the public ECS/Fargate application.

The application was intentionally exposed to the Internet on TCP port
8080 as part of the security lab.

CloudWatch Logs recorded traffic from an unexpected external source
shortly after the workload became publicly accessible.

No evidence of successful exploitation or workload compromise was
identified.

## Environment

- AWS ECS
- AWS Fargate
- Amazon ECR
- CloudWatch Logs
- Public subnet
- Public task IP
- Security group allowing TCP/8080 from `0.0.0.0/0`

## Detection Source

The activity was detected through application logs forwarded from the
Fargate container to Amazon CloudWatch Logs.

## Timeline

| Time | Activity | Result |
|---|---|---|
| 04:45 | Expected request to `/` | HTTP 200 |
| 04:46 | Expected request to `/health` | HTTP 200 |
| 04:49 | Unexpected external request to `/` | HTTP 200 |
| 04:49 | Unexpected malformed request data | HTTP 400 |

## Observed Activity

Expected testing traffic included requests such as:

- `GET /`
- `GET /health`
- `GET /favicon.ico`

An additional external source sent a request to the application followed
by malformed or nonstandard input.

The application rejected the malformed input with HTTP status 400.

## Investigation

The following questions were considered:

### Did the workload stop?

No evidence indicated that the ECS task stopped as a result of the
observed traffic.

### Was command execution observed?

No.

### Was AWS API abuse observed?

No.

### Was sensitive data accessed?

No evidence was available indicating data access.

### Was the container compromised?

No evidence of compromise was identified from the available application
logs.

## Assessment

The activity is classified as unexpected external probing rather than a
confirmed security incident.

The event demonstrates that publicly reachable cloud workloads can begin
receiving unsolicited traffic shortly after exposure to the Internet.

## Existing Security Controls

The application container was running as a dedicated non-root user:

`appuser (UID 1000)`

The application did not yet have an ECS task IAM role granting access to
AWS services.

These controls reduced the potential blast radius if application
exploitation had occurred.

## Containment

Because the environment is a disposable security lab, the workload can
be removed after evidence collection using:

`terraform destroy`

This removes the public workload and eliminates the exposed network
surface when the lab is not being used.

## Lessons Learned

- Internet-facing workloads should be treated as discoverable.
- Public access should be intentional and minimized.
- Application logs provide valuable investigation evidence.
- HTTP 400 responses can reveal malformed or unexpected probing.
- An unexpected request does not automatically prove compromise.
- Non-root containers and least privilege reduce potential impact.
- Disposable lab infrastructure reduces unnecessary exposure when not in use.