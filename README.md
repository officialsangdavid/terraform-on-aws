# Terraform on AWS

> A complete, hands-on Terraform project provisioning production-ready AWS infrastructure — including a module-based VPC, public and private subnets, and an EC2 instance running Ubuntu 24.04, with remote state management via HCP Terraform.

---

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [Resources Created](#resources-created)
- [Getting Started](#getting-started)
- [Configuration](#configuration)
- [Variables and Outputs](#variables-and-outputs)
- [Modules](#modules)
- [Remote State Management](#remote-state-management)
- [Managing Infrastructure](#managing-infrastructure)
- [Common Commands](#common-commands)
- [Security](#security)
- [Troubleshooting](#troubleshooting)
- [Author](#author)

---

## Overview

This project uses **Terraform** to provision core AWS infrastructure from code. Instead of manually clicking through the AWS Console, everything is defined in configuration files and deployed consistently every time.

Key highlights:
- Infrastructure is defined as **code** — repeatable, version-controlled, and auditable
- Uses a **dynamic data source** to always fetch the latest Ubuntu 24.04 AMI automatically
- Networking is managed via the **official HashiCorp VPC module** from the Terraform Registry
- State is managed **remotely** via HCP Terraform for security and team collaboration
- AWS credentials are stored securely as **environment variables** on HCP Terraform — never in code
- Configuration is split into **separate files** for clean organization and maintainability

---

## Architecture

```
AWS (eu-west-2)
└── VPC - terraform-aws-modules/vpc/aws (10.0.0.0/16)
    ├── Public Subnet  (10.0.101.0/24) ← eu-west-2a
    ├── Private Subnet (10.0.1.0/24)   ← eu-west-2a
    └── Private Subnet (10.0.2.0/24)   ← eu-west-2b
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
├── terraform.tf          # Terraform settings, provider and HCP cloud config
├── main.tf               # Core compute resources and data sources
├── vpc.tf                # VPC module and networking configuration
├── variables.tf          # Input variable definitions
├── outputs.tf            # Output value definitions
├── .terraform.lock.hcl   # Dependency lock file — ensures consistent provider versions
├── .gitignore            # Prevents sensitive files from being committed to Git
└── README.md             # Project documentation
```

---

## Resources Created

### 1. VPC Module (`terraform-aws-modules/vpc/aws`)
The VPC is managed using the official HashiCorp VPC module from the Terraform Registry. It provisions the following automatically:
- **VPC** — private, isolated network (`10.0.0.0/16`)
- **Public Subnet** — internet-accessible subnet (`10.0.101.0/24`)
- **Private Subnets** — internal-only subnets (`10.0.1.0/24`, `10.0.2.0/24`)
- **Internet Gateway** — allows public subnet to reach the internet
- **Route Tables** — controls traffic routing between subnets
- **Security Groups** — default firewall rules

> **Note:** NAT Gateway and VPN Gateway are disabled in this project to avoid additional AWS charges.

### 2. EC2 Instance (`aws_instance`)
- **AMI:** Latest Ubuntu Noble 24.04 (fetched dynamically via data source)
- **Instance Type:** `t2.micro` (AWS Free Tier eligible)
- **Subnet:** Placed inside the VPC's private subnet
- **Security Group:** Uses the VPC module's default security group

### 3. Data Source (`data.aws_ami`)
- **Owner:** Canonical (`099720109477`) — the official verified publisher of Ubuntu
- **Filter:** Always fetches the most recent Ubuntu 24.04 image
- **Purpose:** Eliminates the need to hardcode AMI IDs that change per region and over time

---

## Getting Started

### Step 1: Clone the repository
```bash
git clone https://github.com/officialsangdavid/terraform-on-aws.git
cd terraform-on-aws
```

### Step 2: Configure AWS credentials locally
```bash
aws configure
```
You will be prompted for:
```
AWS Access Key ID:      # From AWS Console → Security Credentials → Access Keys
AWS Secret Access Key:  # From AWS Console → Security Credentials → Access Keys
Default region name:    # eu-west-2
Default output format:  # Press Enter to skip
```

### Step 3: Log in to HCP Terraform
```bash
terraform login
```
This opens a browser where you generate an API token. Copy and paste it back into the terminal when prompted. The token will be stored at:
```
~/.terraform.d/credentials.tfrc.json
```

### Step 4: Initialize Terraform
```bash
terraform init
```
This will:
- Connect to your HCP Terraform organization (`TerraCore`)
- Create the remote workspace (`terraform-on-aws`) if it does not exist
- Download the required AWS provider plugin
- Download the VPC module from the Terraform Registry

### Step 5: Validate your configuration
```bash
terraform validate
```
Checks your configuration for syntax errors and internal consistency without connecting to AWS.

### Step 6: Format your configuration
```bash
terraform fmt
```
Automatically reformats all `.tf` files to follow HashiCorp's official style guidelines.

### Step 7: Preview the changes
```bash
terraform plan
```
Shows exactly what Terraform will create before making any real changes. Review this carefully before applying.

### Step 8: Apply the configuration
```bash
terraform apply
```
Type `yes` when prompted to confirm. Terraform will provision all resources on AWS.

---

## Configuration

### `terraform.tf` — Core settings
```hcl
terraform {
  cloud {
    organization = "TerraCore"
    workspaces {
      name = "terraform-on-aws"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.36.0"
    }
  }
  required_version = ">= 1.14"
}

provider "aws" {
  region = "eu-west-2"
}
```

| Setting | Value | Meaning |
|---------|-------|---------|
| `organization` | `TerraCore` | HCP Terraform organization name |
| `workspaces.name` | `terraform-on-aws` | Remote workspace for state storage |
| `aws version` | `~> 6.36.0` | AWS provider 6.36.x — stays within 6.x range |
| `required_version` | `>= 1.14` | Minimum Terraform CLI version required |
| `region` | `eu-west-2` | AWS London region |

---

## Variables and Outputs

### Input Variables (`variables.tf`)
Variables allow you to customize your configuration without modifying resource definitions directly.

```hcl
variable "instance_name" {
  description = "Value of the EC2 instance Name tag"
  type        = string
  default     = "terraform-on-aws"
}

variable "instance_type" {
  description = "The EC2 instance type"
  type        = string
  default     = "t2.micro"
}
```

You can override variables at the command line:
```bash
terraform plan -var instance_type=t2.large
terraform apply -var instance_name=my-server
```

### Output Values (`outputs.tf`)
Outputs expose important information about your infrastructure after apply:

```hcl
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.app_server.id
}

output "instance_private_ip" {
  description = "Private IP of the EC2 instance"
  value       = aws_instance.app_server.private_ip
}
```

View outputs anytime with:
```bash
terraform output
terraform output -raw vpc_id
```

---

## Modules

This project uses the official **AWS VPC module** from the Terraform Registry instead of manually defining VPC resources. This approach:
- Replaces hundreds of lines of manual networking code with a single module block
- Follows community best practices for VPC configuration
- Automatically creates subnets, route tables, internet gateways and security groups

### `vpc.tf`
```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.19.0"

  name = "terraform-on-aws-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24"]

  enable_dns_hostnames = true
  enable_nat_gateway   = false   # Disabled to avoid additional AWS charges
  enable_vpn_gateway   = false   # Disabled to avoid additional AWS charges
}
```

### Referencing Module Outputs
Module resources are referenced using the `module.<name>.<output>` pattern:

```hcl
# Placing EC2 in the VPC's private subnet
subnet_id = module.vpc.private_subnets[0]

# Attaching the VPC's default security group
vpc_security_group_ids = [module.vpc.default_security_group_id]
```

> **Note:** Every time you add a new module, run `terraform init` to download it before running plan or apply.

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
| Plan execution | Local machine | HCP Terraform servers |

### Setting up AWS credentials on HCP Terraform
Since plans run on HCP Terraform's servers, your AWS credentials must be added as environment variables:

1. Go to `app.terraform.io`
2. Navigate to your workspace → **Variables**
3. Add the following **Environment Variables:**

| Key | Sensitive? |
|-----|-----------|
| `AWS_ACCESS_KEY_ID` | No |
| `AWS_SECRET_ACCESS_KEY` | ✅ Yes — mark as sensitive |

---

## Managing Infrastructure

### Inspect State
```bash
# List all tracked resources
terraform state list

# Show full details of all resources
terraform show
```

### Remove a Single Resource
Comment out the resource block in its `.tf` file, then apply:
```bash
terraform apply
# Terraform detects the removed resource and destroys only that one
```

### Target a Specific Resource
```bash
terraform destroy -target aws_instance.app_server
```

### Destroy Everything
```bash
terraform destroy
# Destroys all resources managed by Terraform in the correct dependency order
```

> **Important:** Always run `terraform destroy` when you are done learning to avoid unexpected AWS charges.

---

## Common Commands

| Command | Purpose |
|---------|---------|
| `terraform init` | Initialize project, download providers and modules |
| `terraform validate` | Check configuration for syntax errors |
| `terraform fmt` | Auto-format all `.tf` files |
| `terraform plan` | Preview changes before applying |
| `terraform plan -var key=value` | Preview with a specific variable override |
| `terraform apply` | Create or update infrastructure |
| `terraform destroy` | Delete all managed infrastructure |
| `terraform destroy -target resource` | Delete a specific resource |
| `terraform state list` | List all resources in state |
| `terraform show` | Show full details of current state |
| `terraform output` | Display all output values |
| `terraform output -raw name` | Display a specific output value without quotes |
| `terraform login` | Authenticate with HCP Terraform |

---

## Security

### Files excluded from Git (`.gitignore`)

```
terraform.tfstate         # Contains sensitive infrastructure details
terraform.tfstate.backup  # Backup of state file — equally sensitive
.terraform/               # Large provider plugin directory — no need to commit
*.tfvars                  # May contain passwords and secrets
crash.log                 # Terraform crash logs
```

### Best Practices followed in this project
- ✅ AWS credentials are **never hardcoded** in `.tf` files
- ✅ State file is stored **remotely** on HCP Terraform, not locally
- ✅ AMI is sourced from **Canonical's verified AWS account only** (`099720109477`)
- ✅ Sensitive variables on HCP Terraform are marked as **sensitive/hidden**
- ✅ Provider versions are **locked** via `.terraform.lock.hcl`
- ✅ NAT Gateway and VPN Gateway are **disabled** to avoid unnecessary costs
- ✅ Configuration is **split into separate files** for clean organization
- ✅ VPC module sourced from the **official Terraform Registry** — not written from scratch

---

## Troubleshooting

### Error: No default VPC
```
VPCIdNotSpecified: No default VPC for this user
```
**Fix:** This project creates its own VPC via the VPC module. Ensure the `module.vpc` block is present in `vpc.tf` and `subnet_id` references `module.vpc.private_subnets[0]` in the EC2 resource.

---

### Error: No valid credential sources found
```
Error: No valid credential sources found
```
**Fix:** Add `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` as **Environment Variables** in your HCP Terraform workspace settings at `app.terraform.io`.

---

### Error: Drift detected
```
Objects have changed outside of Terraform
```
**Fix:** Resources were modified or deleted outside of Terraform (e.g. directly in AWS Console). Run `terraform apply` to let Terraform reconcile and recreate them.

---

### Error: EIP Address Limit Exceeded
```
AddressLimitExceeded: The maximum number of addresses has been reached
```
**Fix:** AWS limits accounts to 5 Elastic IPs per region. Set `enable_nat_gateway = false` in your VPC module to avoid creating EIPs, or release unused EIPs from the AWS Console under EC2 → Elastic IPs.

---

### Error: Incorrect attribute value type
```
set of string required, but have string
```
**Fix:** `vpc_security_group_ids` expects a list. Wrap the value in square brackets:
```hcl
vpc_security_group_ids = [module.vpc.default_security_group_id]
```

---

### Git: Push rejected (non-fast-forward)
```
error: failed to push some refs
```
**Fix:** Your local branch is behind the remote. Always commit local changes first, then pull before pushing:
```bash
git add .
git commit -m "your message"
git pull --no-rebase origin main
git push origin main
```

---

## Author

**Sang David**
- GitHub: [@officialsangdavid](https://github.com/officialsangdavid)



