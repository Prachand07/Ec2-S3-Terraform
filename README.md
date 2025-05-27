# AWS EC2 and S3 Infrastructure Provisioning with Terraform

This code provisions a basic AWS infrastructure setup, including a private EC2 instance and a secure S3 bucket with versioning, and encryption enabled.

---
## What This Configuration Provisions

1. **A custom VPC** with CIDR block `10.0.0.0/16`.
2. **A private subnet** (`10.0.1.0/24`) in a user-defined availability zone.
3. **A public subnet** (`10.0.2.0/24`) in a user-defined availability zone.
4. **Route tables and its associations** 
5. **Security groups** that allows traffic to the instances.
6. **Internet Gateway** configured to allow us to connect with outside world
7. **NAT Gateway** launched in public subnet
7. **Secure SSH Key**: A TLS-generated private key is saved securely with 0400 permissions.
9. **No Credentials**: No secrets or keys are hardcoded; all permissions handled via IAM roles.
10. **An EC2 instance** with no public IP in the private subnet.
11. **An EC2 instance** in public subnet, that helps in accessing private subnet instance
12. **A secure S3 bucket** with:
   - Versioning enabled
   - Server-side encryption (SSE) using AES256
   - Public access completely blocked
   - A unique name using a random suffix
13. **An output** displaying the final S3 bucket and instance name and bastion instance ip address

---

## 🔧 Providers Used

This configuration uses **two providers**:

- [`aws`]:
  - Manages AWS resources such as EC2, S3, IAM, VPC.
- [`random`]:
  - Used to generate a random hexadecimal ID to ensure the **S3 bucket name is globally unique**, as bucket names must not conflict with existing names in other AWS accounts.

---

## Prequisites

Before running this Terraform setup, make sure you have the following:

- **Terraform** installed on your system (v1.0+ recommended).
- **AWS CLI** installed (optional but helpful for verification).
- An **AWS account** and an **IAM user** with the necessary permissions:
 - Your **AWS credentials** (`AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`) configured either:
  - As environment variables, OR
  - Using `aws configure` CLI, OR
  - In the Terraform provider block (not recommended for security)

---

##  How to Use This Terraform Configuration

### 1. Clone the repository

```bash
git clone https://github.com/Prachand07/Ec2-S3-Terraform
```
### 2. Initialize Terraform
This step downloads the necessary provider plugins.
```bash
terraform init
```
### 3. Apply the configuration to provision resource
```bash
terraform apply
```
### 4 Destroying the Infrastructure
To tear down everything created by this configuration:
```bash
terraform destory
```
## Notes
You can customize instance types, AMI IDs, or availability zones via variables.
Make sure that your AMI and subnet availability zone are compatible
