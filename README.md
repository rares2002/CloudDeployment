# CloudDeployment

This repository contains Terraform infrastructure-as-code for deploying a production-ready **Amazon EKS (Elastic Kubernetes Service)** cluster on AWS, complete with:

- **VPC** with public and private subnets across multiple availability zones
- **NAT Gateways** for outbound internet access from private subnets
- **IAM roles** for the EKS control plane and worker node groups
- **EKS Managed Node Group** (auto-scaling EC2 worker nodes)
- **ECR (Elastic Container Registry)** repository for storing Docker images

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Project Structure](#project-structure)
3. [Setup](#setup)
4. [Configuration](#configuration)
5. [Deploy](#deploy)
6. [Connect to the Cluster](#connect-to-the-cluster)
7. [Outputs](#outputs)
8. [Tear Down](#tear-down)

---

## Prerequisites

Before you begin, ensure you have the following tools installed and configured:

| Tool | Minimum Version | Purpose |
|------|----------------|---------|
| [Terraform](https://developer.hashicorp.com/terraform/downloads) | `>= 1.3.0` | Infrastructure provisioning |
| [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) | `>= 2.0` | AWS authentication & `kubeconfig` update |
| [kubectl](https://kubernetes.io/docs/tasks/tools/) | any recent | Interacting with the cluster after provisioning |

You also need an **AWS account** with permissions to create:
- VPCs, subnets, internet gateways, NAT gateways, Elastic IPs, and route tables
- IAM roles and policy attachments
- EKS clusters and managed node groups
- ECR repositories

### Configure AWS credentials

```bash
aws configure
```

Enter your `AWS Access Key ID`, `AWS Secret Access Key`, default region (e.g. `us-east-1`), and preferred output format.  
Alternatively, export the credentials as environment variables:

```bash
export AWS_ACCESS_KEY_ID="your-access-key-id"
export AWS_SECRET_ACCESS_KEY="your-secret-access-key"
export AWS_DEFAULT_REGION="us-east-1"
```

---

## Project Structure

```
CloudDeployment/
└── terraform/
    ├── main.tf        # VPC, subnets, NAT gateways, IAM roles, EKS cluster & node group, ECR
    ├── variables.tf   # All input variables with defaults
    ├── outputs.tf     # Useful values printed after apply
    └── versions.tf    # Terraform & provider version constraints
```

---

## Setup

1. **Clone the repository**

   ```bash
   git clone https://github.com/rares2002/CloudDeployment.git
   cd CloudDeployment/terraform
   ```

2. **Initialize Terraform** – downloads the AWS provider plugin and sets up the working directory.

   ```bash
   terraform init
   ```

---

## Configuration

All tuneable parameters are declared in `terraform/variables.tf`. The defaults are suitable for a development environment. Override them by creating a `terraform.tfvars` file inside the `terraform/` directory:

```hcl
# terraform/terraform.tfvars (example)
aws_region          = "eu-west-1"
cluster_name        = "my-eks-cluster"
cluster_version     = "1.29"
vpc_cidr            = "10.0.0.0/16"
public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
node_instance_type  = "t3.medium"
node_desired_size   = 2
node_min_size       = 1
node_max_size       = 4
# Restrict the public API endpoint to your IP in production:
endpoint_public_access_cidrs = ["203.0.113.0/32"]
tags = {
  Project   = "CloudDeployment"
  ManagedBy = "Terraform"
  Env       = "dev"
}
```

| Variable | Default | Description |
|----------|---------|-------------|
| `aws_region` | `us-east-1` | AWS region for all resources |
| `cluster_name` | `cloud-deployment-cluster` | Name prefix used for all resources |
| `cluster_version` | `1.29` | Kubernetes version for EKS |
| `vpc_cidr` | `10.0.0.0/16` | CIDR block for the VPC |
| `public_subnet_cidrs` | `["10.0.1.0/24","10.0.2.0/24"]` | CIDRs for public subnets |
| `private_subnet_cidrs` | `["10.0.3.0/24","10.0.4.0/24"]` | CIDRs for private subnets |
| `node_instance_type` | `t3.medium` | EC2 instance type for worker nodes |
| `node_desired_size` | `2` | Desired number of worker nodes |
| `node_min_size` | `1` | Minimum number of worker nodes |
| `node_max_size` | `4` | Maximum number of worker nodes |
| `endpoint_public_access_cidrs` | `["0.0.0.0/0"]` | CIDRs allowed to reach the public EKS API endpoint |
| `tags` | `{Project, ManagedBy}` | Tags applied to all AWS resources |

---

## Deploy

All commands below are run from inside the `terraform/` directory.

1. **Preview the changes** – shows what Terraform will create without making any changes.

   ```bash
   terraform plan
   ```

   To save the plan to a file (recommended for production):

   ```bash
   terraform plan -out=tfplan
   ```

2. **Apply the configuration** – provisions all AWS resources. This step typically takes **10–20 minutes**.

   ```bash
   terraform apply
   ```

   If you saved a plan file:

   ```bash
   terraform apply tfplan
   ```

   Type `yes` when prompted to confirm.

---

## Connect to the Cluster

After `terraform apply` completes, update your local `kubeconfig` to point to the new cluster:

```bash
aws eks update-kubeconfig \
  --region <aws_region> \
  --name <cluster_name>
```

Replace `<aws_region>` and `<cluster_name>` with the values you used (defaults: `us-east-1` and `cloud-deployment-cluster`).

Verify connectivity:

```bash
kubectl get nodes
```

You should see the worker nodes in `Ready` state.

---

## Outputs

After a successful `apply`, Terraform prints the following values:

| Output | Description |
|--------|-------------|
| `cluster_name` | Name of the EKS cluster |
| `cluster_endpoint` | API server endpoint URL |
| `cluster_certificate_authority_data` | Base64-encoded CA data *(sensitive)* |
| `cluster_version` | Kubernetes version running on the cluster |
| `vpc_id` | ID of the provisioned VPC |
| `public_subnet_ids` | IDs of the public subnets |
| `private_subnet_ids` | IDs of the private subnets |
| `ecr_repository_url` | URL of the ECR Docker image repository |
| `node_group_role_arn` | ARN of the IAM role used by the node group |

To re-display the outputs at any time:

```bash
terraform output
```

---

## Tear Down

To destroy all resources created by this project and avoid ongoing AWS charges:

```bash
terraform destroy
```

Type `yes` when prompted. This will permanently delete the EKS cluster, VPC, subnets, NAT gateways, ECR repository, and all associated resources.
