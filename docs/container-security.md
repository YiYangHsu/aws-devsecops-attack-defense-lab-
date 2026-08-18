# Container Security

## Overview

This project uses Docker to package the application before it is deployed
to AWS ECS/Fargate.

During Week 3, an initial container image was created and then hardened
to reduce the privileges available to the application process.

## Container Architecture

```text
Application Source Code
        |
        v
Dockerfile
        |
        v
Docker Image
        |
        v
Running Container
        |
        v
Python Application Process

Initial Container — Version 1

The first version used the following basic Dockerfile:

FROM python:3.12-slim


WORKDIR /app


COPY app.py .


EXPOSE 8080


CMD ["python", "app.py"]

The application worked successfully:

GET /         -> AWS DevSecOps Attack & Defense Lab
GET /health   -> healthy

However, inspection of the running container showed:

whoami -> root
id     -> uid=0(root)

The Python application process was therefore running as the root user
inside the container.

Security Risk

If an attacker exploits the application and gains command execution
inside the container, the attacker inherits the privileges of the
application process.

In Version 1, this meant the attacker could operate as root inside the
container.

Application Exploit
        |
        v
Container Compromise
        |
        v
Root Process
        |
        v
Larger Blast Radius

Running a workload as root does not automatically compromise the Docker
host or AWS account, but it increases the privileges available inside
the compromised container.

Hardened Container — Version 2

A dedicated application user was created:

FROM python:3.12-slim


RUN useradd --create-home --shell /usr/sbin/nologin appuser


WORKDIR /app


COPY --chown=appuser:appuser app.py .


USER appuser


EXPOSE 8080


CMD ["python", "app.py"]
Security Controls
Dedicated Non-Root User

The application runs as appuser instead of root.

Restricted Login Shell

The application account uses /usr/sbin/nologin because it does not
require interactive login access.

Application File Ownership

The application file is owned by the dedicated application user.

Verification

After rebuilding the image as Version 2, the application continued to
function correctly.

GET /         -> AWS DevSecOps Attack & Defense Lab
GET /health   -> healthy

The running identity was verified:

whoami
appuser


id
uid=1000(appuser) gid=1000(appuser)

The running Python process was also verified to use UID 1000.

The application directory showed:

-rwxr-xr-x appuser appuser app.py

A test attempt to write to the root user's directory failed:

touch /root/test.txt


Permission denied

This confirmed that the application was no longer running with root
privileges.

Before and After
Version	Application User	UID	Root Access
v1	root	0	Yes, inside container
v2	appuser	1000	Restricted
Security Principle

This change applies the Principle of Least Privilege.

The application only receives the permissions required to perform its
function.

If the application is compromised, the attacker's available privileges
are therefore reduced.

This is also an example of defense in depth: the control does not prevent
all application vulnerabilities, but it reduces the impact of a
successful compromise.

---