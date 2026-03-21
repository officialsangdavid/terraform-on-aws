# Terraform on AWS

> Provision production-ready AWS infrastructure using Terraform — including a custom VPC, Subnet, and EC2 instance running Ubuntu 24.04, with remote state management via HCP Terraform.

---

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [Resources Created](#resources-created)
- [Getting Started](#getting-started)
- [Configuration](#configuration)
- [Remote State Management](#remote-state-management)
- [Common Commands](#common-commands)
- [Security](#security)
- [Troubleshooting](#troubleshooting)
- [Author](#author)

---

## Overview

This project uses **Terraform** to provision core AWS infrastructure from code. Instead of manually clicking through the AWS Console, everything is defined in a single `main.tf` configuration file and deployed consistently every time.

Key highlights:
- Infrastructure is defined as **code** — repeatable, version-controlled, and auditable
- Uses a **dynamic data source** to always fetch the latest Ubuntu 24.04 AMI automatically
- State is managed **remotely** via HCP Terraform for security and team collaboration
- AWS credentials are stored securely as **environment variables** on HCP Terraform — never in code

---

## Architecture

```
AWS (us-west-2)
└── VPC (10.0.0.0/16)
    └── Subnet (10.0.1.0/24)
        └── EC2 Instance (t2.micro - Ubuntu 24.04)
```

---

## Prerequisites

Before you begin, make sure you have the following installed and configured:

| Requirement | Version | Purpose |
|-------------|---------|---------|
| [Terraform](https://developer.hashicorp.com/terraform/install) | >= 1.14 | Infrastructure provisioning tool |
| [AWS CLI](https://aws.amazon.com/cli/) | Latest | AWS authentication and configuration |
| [AWS Account](https://aws.amazon.com) | - | Cloud provider where resources are created |
| [HCP Terraform Account](https://app.terraform.io) | - | Remote state storage and management |

---

## Project Structure

```
terraform-on-aws/
├── main.tf                  # Core configuration — providers, data sources, resources
├── .terraform.lock.hcl      # Dependency lock file — ensures consistent provider versions
├── .gitignore               # Prevents sensitive files from being pushed to Git
└── README.md                # Project documentation
```

---

## Resources Created

### 1. VPC (`aws_vpc`)
- **CIDR Block:** `10.0.0.0/16`
- **Purpose:** A private, isolated network within AWS where all resources live
- **Tag:** `main-vpc`

### 2. Subnet (`aws_subnet`)
- **CIDR Block:** `10.0.1.0/24`
- **Purpose:** A subdivision of the VPC where the EC2 instance is placed
- **Tag:** `main-subnet`

### 3. EC2 Instance (`aws_instance`)
- **AMI:** Latest Ubuntu Noble 24.04 (fetched dynamically via data source)
- **Instance Type:** `t2.micro` (AWS Free Tier eligible)
- **Tag:** `terraform-on-aws`

### 4. Data Source (`data.aws_ami`)
- **Owner:** Canonical (`099720109477`) — the official publisher of Ubuntu
- **Filter:** Always fetches the most recent Ubuntu 24.04 image
- **Purpose:** Eliminates the need to hardcode AMI IDs that change per region and over time

---

## Getting Started

### Step 1: Clone the repository
```bash
git clone https://github.com/officialsangdavid/terraform-on-aws.git
cd terraform-on-aws
```

### Step 2: Configure AWS credentials
```bash
aws configure
```
You will be prompted for:
```
AWS Access Key ID:      # From AWS Console → Security Credentials
AWS Secret Access Key:  # From AWS Console → Security Credentials
Default region name:    # e.g. us-west-2
Default output format:  # Press Enter to skip
```

### Step 3: Log in to HCP Terraform
```bash
terraform login
```
This opens a browser where you generate an API token. Copy and paste it back into the terminal.

### Step 4: Initialize Terraform
```bash
terraform init
```
This will:
- Connect to your HCP Terraform organization
- Create the remote workspace if it does not exist
- Download the required AWS provider plugin

### Step 5: Validate your configuration
```bash
terraform validate
```
Checks your configuration for syntax errors and internal consistency.

### Step 6: Format your configuration
```bash
terraform fmt
```
Automatically reformats your `.tf` files to follow HashiCorp's style guidelines.

### Step 7: Preview the changes
```bash
terraform plan
```
Shows exactly what Terraform will create before making any real changes.

### Step 8: Apply the configuration
```bash
terraform apply
```
Type `yes` when prompted to confirm. Terraform will provision all resources on AWS.

---

## Configuration

The `terraform {}` block at the top of `main.tf` defines the project's core settings:

```hcl
terraform {
  cloud {
    organization = "terracore"
    workspaces {
      name = "terraform-on-aws"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.36"
    }
  }
  required_version = ">= 1.14"
}
```

| Setting | Value | Meaning |
|---------|-------|---------|
| `organization` | `terracore` | HCP Terraform organization name |
| `workspaces.name` | `terraform-on-aws` | Remote workspace for state storage |
| `aws version` | `~> 6.36` | AWS provider 6.36 or higher within 6.x |
| `required_version` | `>= 1.14` | Minimum Terraform CLI version required |

---

## Remote State Management

This project uses **HCP Terraform** to store the Terraform state file remotely instead of locally.

### Why remote state?

| Feature | Local State | HCP Terraform |
|---------|------------|---------------|
| State file location | Your machine | HCP secure cloud storage |
| Risk of loss | High | None |
| Team collaboration | Impossible | Full support |
| State history | None | Full version history |
| Security | Low | High |

### Setting up AWS credentials on HCP Terraform

Since the plan runs on HCP Terraform's servers, your AWS credentials must be added as environment variables:

1. Go to `app.terraform.io`
2. Navigate to your workspace → **Variables**
3. Add the following **Environment Variables:**

| Key | Value | Sensitive |
|-----|-------|-----------|
| `AWS_ACCESS_KEY_ID` | Your AWS access key | No |
| `AWS_SECRET_ACCESS_KEY` | Your AWS secret key | ✅ Yes |

---

## Common Commands

| Command | Purpose |
|---------|---------|
| `terraform init` | Initialize the project and download providers |
| `terraform validate` | Check configuration for errors |
| `terraform fmt` | Auto-format configuration files |
| `terraform plan` | Preview changes before applying |
| `terraform apply` | Create or update infrastructure |
| `terraform destroy` | Delete all managed infrastructure |
| `terraform state list` | List all resources in state |
| `terraform show` | Show full details of current state |

---

## Security

### Files excluded from Git (`.gitignore`)

```
terraform.tfstate         # Contains sensitive infrastructure details
terraform.tfstate.backup  # Backup of state file — equally sensitive
.terraform/               # Large provider plugin directory
*.tfvars                  # May contain passwords and secrets
crash.log                 # Terraform crash logs
```

### Best Practices followed in this project
- ✅ AWS credentials are **never hardcoded** in `.tf` files
- ✅ State file is stored **remotely** on HCP Terraform, not locally
- ✅ AMI is sourced from **Canonical's verified AWS account only** (`099720109477`)
- ✅ Sensitive variables on HCP Terraform are marked as **sensitive/hidden**
- ✅ Provider versions are **locked** via `.terraform.lock.hcl`

---

## Troubleshooting

### Error: No default VPC
```
VPCIdNotSpecified: No default VPC for this user
```
**Fix:** This project creates its own VPC and Subnet, so this error should not occur. If it does, ensure the `aws_vpc` and `aws_subnet` resources are present in `main.tf` and the `subnet_id` is referenced in the `aws_instance` resource.

---

### Error: No valid credential sources found
```
Error: No valid credential sources found
```
**Fix:** Add `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` as **Environment Variables** in your HCP Terraform workspace settings.

---

### Error: Drift detected
```
Objects have changed outside of Terraform
```
**Fix:** This means resources were modified or deleted outside of Terraform. Run `terraform apply` to let Terraform reconcile and recreate them.

---

## Author

**Sang David**
- GitHub: [@officialsangdavid](https://github.com/officialsangdavid)

---

> **Note:** Always run `terraform destroy` when you are done learning to avoid unexpected AWS charges.
