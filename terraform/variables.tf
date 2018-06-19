variable "public_key_path" {
  default = "/Users/nathenharvey/.aws/nathenharvey-community.pem"

  description = <<DESCRIPTION
Path to the SSH public key to be used for authentication.
Ensure this keypair is added to your local SSH agent so provisioners can
connect.

Example: ~/.ssh/terraform.pub
DESCRIPTION
}

variable "key_name" {
  default     = "nathenharvey-community.pem"
  description = "Desired name of AWS key pair"
}

variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "us-east-1"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "ssh_cidrs" {
  default = ["173.239.212.22/32"]
}

# Ubuntu Xenial 16.04 LTS (x64)
variable "aws_amis" {
  default = {
    us-east-1 = "ami-a4dc46db"
    us-east-2 = "ami-6a003c0f"
    us-west-1 = "ami-8d948ced"
    us-west-2 = "ami-db710fa3"
  }
}
