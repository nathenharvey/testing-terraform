# Testing Terraform

Start with a [basic two-tier AWS web example](https://www.terraform.io/intro/examples/aws.html)


1. `terraform init`
1. `terraform plan -var "key_name=$AWS_KEYPAIR_NAME" -var "public_key_path=$AWS_KEY_PATH"`
1. `terraform apply -var "key_name=$AWS_KEYPAIR_NAME" -var "public_key_path=$AWS_KEY_PATH"`

