# Week 7 - CloudTrail Security Telemetry

## Objective

The goal of Week 7 was to add AWS API audit telemetry to the existing ECS/Fargate lab and learn how to correlate application activity with AWS activity.

The lab focused on three questions:

1. What happened inside the application?
2. Which AWS identity performed the AWS API call?
3. Where can the audit evidence be stored and investigated?

## Architecture

The application ran on Amazon ECS using AWS Fargate.

Application-side telemetry:

```text
Python application
    -> ECS awslogs driver
    -> CloudWatch Logs
    -> /ecs/devsecops-lab-app
```

AWS-side telemetry:

```text
Application
    -> Boto3
    -> ECS Task Role
    -> S3 GetObject
    -> CloudTrail
    -> CloudWatch Logs
    -> S3 audit archive
```

The two telemetry sources serve different purposes:

- CloudWatch Logs provides centralized log storage and investigation.
- CloudTrail records AWS API activity and the identity associated with the request.

## CloudTrail Configuration

Created a CloudTrail trail:

`devsecops-lab-security-trail`

The trail was configured to:

- Enable logging
- Include management events
- Capture read and write activity
- Capture S3 object data events for the dedicated IAM lab bucket
- Deliver audit records to CloudWatch Logs
- Archive CloudTrail log files in a separate S3 bucket
- Enable log file validation

The S3 data-event selector targeted:

`arn:aws:s3:::devsecops-iam-lab-472353357025/`

This allowed the lab to capture object-level activity such as `GetObject`.

## CloudTrail Destinations

Two destinations were used.

### CloudWatch Logs

The CloudTrail log group was:

`/aws/cloudtrail/devsecops-lab`

This destination was used for convenient searching and investigation.

The existing application log group remained separate:

`/ecs/devsecops-lab-app`

The separation provides two perspectives:

```text
/ecs/devsecops-lab-app
-> application behavior

/aws/cloudtrail/devsecops-lab
-> AWS API audit activity
```

### S3 Archive

CloudTrail log files were also delivered to:

`devsecops-cloudtrail-logs-472353357025`

The archive contained paths under:

`AWSLogs/472353357025/CloudTrail/us-east-1/...`

CloudTrail digest files were also present under:

`AWSLogs/472353357025/CloudTrail-Digest/`

The CloudTrail archive bucket was separate from the S3 bucket used as the application's IAM test target.

## IAM Roles

Week 7 used three separate IAM roles with different responsibilities.

### ECS Task Execution Role

Used by the ECS/Fargate platform for tasks such as pulling the image from ECR and delivering container logs.

### ECS Task Role

Used by the application code to call AWS APIs.

For the final Week 6 configuration, the application had:

`s3:GetObject`

on:

`allowed/test-data.txt`

### CloudTrail to CloudWatch Role

Used by the CloudTrail service to deliver audit events to CloudWatch Logs.

Its trust relationship allowed:

`cloudtrail.amazonaws.com`

to assume the role.

Its permissions allowed CloudTrail to create log streams and put log events into the CloudTrail CloudWatch log group.

The distinction is:

```text
Trust policy
-> who may assume the role?

Permissions policy
-> what may the role do?

Trail configuration
-> which trail is configured to use the role?
```

## Terraform Data Blocks

The lab also reinforced the difference between Terraform `data` blocks and `resource` blocks.

`aws_caller_identity` reads information from AWS, such as the account ID.

`aws_iam_policy_document` is used to build IAM policy JSON. It does not create the policy by itself.

A `resource` block creates or manages the AWS object.

For example:

```text
data.aws_iam_policy_document.cloudtrail_cloudwatch
-> builds policy JSON

resource.aws_iam_role_policy.cloudtrail_cloudwatch
-> attaches the policy to the CloudTrail delivery role
```

## Validation

The CloudTrail status check returned:

`IsLogging = true`

and showed successful CloudWatch delivery.

The event-selector check confirmed:

- Management events enabled
- S3 object data events enabled
- Target bucket configured

## End-to-End Test

The application endpoint was called:

`/s3/allowed`

The application returned the expected training data.

The application CloudWatch log recorded:

```text
GET /s3/allowed HTTP/1.1 200
```

A CloudTrail search using an exact JSON field filter then found the corresponding S3 data event.

Important CloudTrail fields included:

```text
eventName      = GetObject
eventSource    = s3.amazonaws.com
userIdentity   = AssumedRole
role           = devsecops-lab-ecs-task-role
bucket         = devsecops-iam-lab-472353357025
key            = allowed/test-data.txt
managementEvent = false
eventCategory  = Data
httpStatusCode = 200
```

The event also showed an ECS Fargate execution context for the task credentials.

## Correlation

The strongest Week 7 evidence was the correlation between application and AWS audit logs.

Application perspective:

```text
GET /s3/allowed -> 200
```

CloudTrail perspective:

```text
GetObject
-> ECS Task Role session
-> allowed/test-data.txt
-> HTTP 200
```

This produced the following investigation chain:

```text
HTTP request
    -> Python application
    -> Boto3
    -> ECS Task Role
    -> S3 GetObject
    -> CloudTrail data event
    -> CloudWatch investigation log
    -> S3 audit archive
```

## False-Positive Investigation

An initial CloudWatch Logs search used the text filter:

`GetObject`

This returned CloudTrail management events for `FilterLogEvents` because the search request itself contained the text `GetObject` in its filter pattern.

The issue was resolved by using an exact JSON filter:

```text
{ $.eventName = "GetObject" }
```

This demonstrated the importance of filtering on structured event fields rather than relying only on plain-text matches.

## Security Investigation Model

Week 7 demonstrated two complementary perspectives:

```text
CloudWatch application logs
-> What did the application receive and return?

CloudTrail
-> Which AWS API call occurred, which identity made it, what resource was targeted, and when?
```

Together they provide better evidence than either source alone.

## Evidence

Week 7 evidence was saved under:

`docs/evidence/week-07/`

Files included:

- `application-s3-allowed.log`
- `cloudtrail-getobject.log`
- `cloudtrail-s3-archive.log`
- `cloudtrail-event-selectors.json`
- `cloudtrail-status.json`

## Key Lessons

CloudTrail is an AWS API audit service, not a replacement for application logging.

CloudWatch Logs is a centralized log destination and investigation surface and can receive application logs as well as CloudTrail events.

CloudTrail management events and S3 object data events are different event categories.

S3 object-level data events must be explicitly selected for the resources that need monitoring.

The ECS Task Role identifies the application when it calls AWS APIs.

The ECS Task Execution Role and CloudTrail delivery role perform different jobs and should not be treated as one shared identity.

Terraform `data` blocks can read information or calculate configuration. `aws_iam_policy_document` builds policy JSON rather than creating an AWS policy directly.

Structured log filters reduce false positives during investigations.

Correlating application logs with CloudTrail provides a stronger end-to-end view of a cloud security event.

## Cleanup

After evidence collection, the disposable Week 7 environment was destroyed with Terraform.

Result:

`Destroy complete! Resources: 29 destroyed.`

The Week 7 evidence files remained in the repository for later review and documentation.
