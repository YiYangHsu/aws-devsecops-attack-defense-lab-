# Terraform State Architecture

## Overview

This project uses separate Terraform configurations for persistent
infrastructure and disposable lab infrastructure.

The goal is to allow the AWS security lab to be created and destroyed
without deleting the Terraform remote state infrastructure.

## Architecture

```text
terraform/bootstrap
        |
        | Local Terraform State
        |
        v
Persistent S3 State Bucket
        |
        | Remote State
        v
terraform/lab
        |
        v
Disposable AWS Lab