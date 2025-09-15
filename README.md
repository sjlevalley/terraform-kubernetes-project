# EC2 Free Tier Terraform Project

This Terraform project deploys a basic EC2 instance in the AWS free tier using the default VPC and subnet.

## Prerequisites

1. **AWS CLI configured** with appropriate credentials
2. **Terraform installed** (version >= 1.0)
3. **SSH key pair** (already generated in the `ssh/` directory)

## Project Structure

```
.
├── main.tf          # Main Terraform configuration
├── variables.tf     # Variable definitions
├── outputs.tf       # Output values
├── README.md        # This file
└── ssh/             # SSH keys directory
    ├── main-key     # Private key
    └── main-key.pub # Public key
```

## Features

- **Free Tier Eligible**: Uses `t2.micro` instance type
- **Default VPC**: Uses AWS default VPC and subnet
- **Security Group**: Allows SSH (22), HTTP (80), and HTTPS (443) access
- **Web Server**: Automatically installs and starts Apache HTTP server
- **Public IP**: Instance gets a public IP address for external access

## Usage

### 1. Initialize Terraform

```bash
terraform init
```

### 2. Plan the deployment

```bash
terraform plan
```

### 3. Apply the configuration

```bash
terraform apply
```

### 4. Access the instance

After deployment, you can:

- **SSH into the instance**:

  ```bash
  ssh -i ssh/main-key ec2-user@<public_ip>
  ```

- **Access the web server**:
  Open `http://<public_ip>` in your browser

### 5. Destroy the infrastructure

```bash
terraform destroy
```

## Outputs

After successful deployment, Terraform will output:

- `public_ip`: Public IP address of the EC2 instance
- `instance_id`: AWS instance ID
- `instance_arn`: AWS resource ARN
- `availability_zone`: Availability zone where the instance is deployed

## Security Notes

- The security group allows SSH access from anywhere (0.0.0.0/0)
- Consider restricting SSH access to your IP address for production use
- The private key file (`ssh/main-key`) should be kept secure and not committed to version control

## Free Tier Considerations

- **t2.micro** instances are eligible for AWS free tier
- Free tier includes 750 hours per month of t2.micro usage
- Monitor your usage in the AWS Billing Console
- Remember to destroy resources when not in use to avoid charges
