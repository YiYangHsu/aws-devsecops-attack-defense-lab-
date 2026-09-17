# IAM Least Privilege

## Objective

The goal of Week 6 was to understand how an ECS Task Role affects the
AWS attack surface of a containerized application.

The lab demonstrated the difference between:

- No application Task Role
- An intentionally over-permissioned Task Role
- A least-privilege Task Role

The main security question was:

If the application is compromised, what AWS permissions would the
attacker inherit?

## Initial State

The ECS Task Definition originally contained an ECS Task Execution Role
but no ECS Task Role.

AWS verification showed:

`ExecutionRole = devsecops-lab-ecs-task-execution-role`

`TaskRole = None`

The Execution Role was used by ECS/Fargate to pull the container image
from ECR and send logs to CloudWatch.

Because no Task Role existed, the application itself had no
application-level AWS permissions.

## IAM Lab Resources

A disposable S3 bucket was created for the IAM experiment.

The bucket contained two non-sensitive training objects:

`allowed/test-data.txt`

`restricted/decoy-data.txt`

The bucket was configured with:

- S3 Block Public Access
- AES256 server-side encryption
- Terraform management
- `force_destroy = true`

These objects allowed intended and unintended access to be tested
without using real sensitive data.

## Broad Task Role

An ECS Task Role named:

`devsecops-lab-ecs-task-role`

was created.

The role trusted:

`ecs-tasks.amazonaws.com`

The initial permissions policy deliberately allowed:

`s3:*`

against the disposable lab bucket and all objects inside it.

The policy was intentionally broader than the application required, but
it was restricted to the lab bucket so unrelated AWS resources were not
included in the experiment.

## Application IAM Testing

The Python application was updated to use Boto3.

No static AWS access keys were stored in the application or container.

Boto3 used temporary credentials provided automatically through the ECS
Task Role.

The S3 bucket name was supplied to the application through the
environment variable:

`IAM_LAB_BUCKET`

Three test endpoints were added:

`/s3/allowed`

Reads:

`allowed/test-data.txt`

`/s3/restricted`

Reads:

`restricted/decoy-data.txt`

`/s3/list`

Lists objects in the S3 bucket.

The updated container image was built as:

`v7`

The image was tested locally and confirmed to:

- Return the normal application response
- Pass the `/health` endpoint
- Run as the non-root `appuser`
- Pass ECR Basic Scanning with no findings at scan time

## Broad Permission Validation

With the broad Task Role policy, all three S3 operations succeeded.

| Request | Result |
|---|---|
| `/s3/allowed` | HTTP 200 |
| `/s3/restricted` | HTTP 200 |
| `/s3/list` | HTTP 200 |

This showed that the application had significantly more AWS permissions
than its actual requirement.

The application only needed to read one object, but the Task Role could
also read unrelated objects and enumerate the bucket.

Because the role contained `s3:*`, the IAM policy also authorized many
additional S3 operations that were not required by the workload.

## Least-Privilege Remediation

The broad policy was removed.

It was replaced with:

`Action: s3:GetObject`

on only:

`arn:aws:s3:::devsecops-iam-lab-472353357025/allowed/test-data.txt`

This reduced permissions in two areas.

The allowed action changed from:

`s3:*`

to:

`s3:GetObject`

The resource scope changed from:

the entire bucket and all objects

to:

one specific object.

The ECS Task Role itself did not change.

The container image did not change.

The application code did not change.

Only the IAM permissions were modified.

## Least-Privilege Validation

The same application endpoints were tested again after the IAM policy
change.

| Request | Result |
|---|---|
| `/s3/allowed` | HTTP 200 |
| `/s3/restricted` | HTTP 403 AccessDenied |
| `/s3/list` | HTTP 403 AccessDenied |

The required application function continued to work.

Access that the application did not require was denied.

This demonstrated AWS IAM implicit deny.

Because there was no applicable Allow for the restricted object or the
`ListBucket` operation, AWS denied those requests without requiring an
explicit Deny policy.

## CloudWatch Evidence

CloudWatch Logs captured both the broad-permission and
least-privilege tests.

Before remediation:

`GET /s3/allowed -> 200`

`GET /s3/restricted -> 200`

`GET /s3/list -> 200`

After remediation:

`GET /s3/allowed -> 200`

`GET /s3/restricted -> 403`

`GET /s3/list -> 403`

This provided direct before-and-after evidence that changing the IAM
policy reduced the workload's effective AWS permissions.

## Security Impact

The broad Task Role created the following attack path:

Application compromise

-> attacker inherits Task Role permissions

-> `s3:*` access to the lab bucket

-> access to data and operations beyond the application's requirement

After least-privilege remediation:

Application compromise

-> attacker inherits the same Task Role

-> `s3:GetObject` on one specific object

-> significantly smaller AWS blast radius

The application may still be compromised, but the amount of AWS access
available after compromise is reduced.

## Evidence

Week 6 evidence was saved under:

`docs/evidence/week-06/`

including:

`iam-runtime-validation.log`

`least-privilege-policy.json`

`task-definition-v7.json`

## Key Lessons

The ECS Task Execution Role and ECS Task Role serve different purposes.

The Execution Role is used by the ECS/Fargate platform.

The Task Role defines what AWS APIs the application can call.

A compromised application can potentially use the permissions assigned
to its Task Role.

Overly broad IAM permissions increase cloud blast radius.

Least privilege should restrict both the allowed actions and the
resources those actions can target.

Testing denied operations is as important as testing successful
operations.

IAM permissions can be reduced without rebuilding the application when
the Task Role identity remains the same.

ECS Task Roles allow applications to use temporary AWS credentials
without storing static access keys inside containers.