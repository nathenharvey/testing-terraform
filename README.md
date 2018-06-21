# Testing Terraform

Terraform is used to manage infrastructure as code. InSpec is a powerful framework for validating that infrastructure. In combination they allow for fast, safe infrastructure automation.

Slides from this presentation, including embedded demos, are [available on SlideShare](https://www.slideshare.net/nathenharvey/testing-terraform-102777946).

# Running this code and the demos

Start with a [basic two-tier AWS web example](https://www.terraform.io/intro/examples/aws.html)

1.  Update `ssh_cidrs` in `terraform/variables.tf`
1. `terraform init`
1. `terraform plan -var "key_name=$AWS_KEYPAIR_NAME" -var "public_key_path=$AWS_KEY_PATH" -out plan.out`
1. `terraform apply -var "key_name=$AWS_KEYPAIR_NAME" -var "public_key_path=$AWS_KEY_PATH" plan.out`

A four node infrastructure is now running.  An elastic load balancer (ELB) and three web nodes.

Verify with Terraform

`terraform plan -var "key_name=$AWS_KEYPAIR_NAME" -var "public_key_path=$AWS_KEY_PATH"`

Login to the AWS Console.  Create a secruity group and assign that new security group to one of the web nodes.

Audit the infrastructure using terraform.

`terraform plan -var "key_name=$AWS_KEYPAIR_NAME" -var "public_key_path=$AWS_KEY_PATH"`

Check all security groups using `security_groups.rb`.

`inspec exec -t aws:// security_groups.rb`

Create an InSpec profile with the new controls and execute that profile.

1. `inspec init profile my_app`
1. `cp security_groups.rb my_app/controls/`
1. `cp instances.rb my_app/controls/`
1. `rm -rf my_app/libraries`
1. `inspec exec -t aws:// my_app`


## Bonus Round:  iggy

Iggy is a gem that generates InSpec profiles from Terraform state files.

1. `gem install inspec-iggy`
1. `inspec terraform generate --tfstate terraform.tfstate > my_terra.rb`
1. `inspec exec -t aws:// my_terra.rb`


