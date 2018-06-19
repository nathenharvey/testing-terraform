# set a minimum requirement for the version of terraform
terraform {
  required_version = "~> 0.11.0"
}

# Specify the provider and access details
provider "aws" {
  region = "${var.aws_region}"
}

# Create a VPC to launch our instances into
resource "aws_vpc" "testing_terraform" {
  cidr_block = "${var.vpc_cidr}"
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.testing_terraform.id}"
}

# Grant the VPC internet access on its main route table
resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.testing_terraform.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.default.id}"
}

# Create a subnet to launch our instances into
resource "aws_subnet" "default" {
  vpc_id                  = "${aws_vpc.testing_terraform.id}"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

# A security group for the ELB so it is accessible via the web
resource "aws_security_group" "world_to_elb" {
  name        = "testing_terraform_elb"
  description = "World-facing ELB SG for Testing Terraform Presentation.  nharvey contact"
  vpc_id      = "${aws_vpc.testing_terraform.id}"

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Our default security group to access
# the instances over SSH and HTTP
resource "aws_security_group" "lb_to_webservers" {
  name        = "testing_terraform"
  description = "Used in testing terraform"
  vpc_id      = "${aws_vpc.testing_terraform.id}"

  # HTTP access from the VPC
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ssh_from_office" {
  name   = "testing-terraform-ssh"
  vpc_id = "${aws_vpc.testing_terraform.id}"

  # SSH access from special office addresses
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = "${var.ssh_cidrs}"
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elb" "web" {
  name = "testing-terraform-elb"

  subnets = ["${aws_subnet.default.id}"]

  security_groups = [
    "${aws_security_group.world_to_elb.id}",
    "${aws_security_group.lb_to_webservers.id}",
  ]

  instances = ["${aws_instance.web.*.id}"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
}

resource "aws_instance" "web" {
  count         = 3
  instance_type = "t2.micro"

  # Lookup the correct AMI based on the region
  # we specified
  ami = "${lookup(var.aws_amis, var.aws_region)}"

  root_block_device {
    delete_on_termination = true
  }

  # The name of our SSH keypair.
  key_name = "${var.key_name}"

  # Our Security groups to allow HTTP and SSH access
  vpc_security_group_ids = [
    "${aws_security_group.lb_to_webservers.id}",
    "${aws_security_group.ssh_from_office.id}",
  ]

  # We're going to launch into the same subnet as our ELB. In a production
  # environment it's more common to have a separate private subnet for
  # backend instances.
  subnet_id = "${aws_subnet.default.id}"

  tags {
    Name          = "Testing Terraform - web-${count.index}"
    X-TTL         = "2018-06-19"
    X-Dept        = "Community Engineering"
    X-Application = "Testing Terraform"
    X-Contact     = "nharvey"
  }

  # The connection block tells our provisioner how to
  # communicate with the resource (instance)
  connection {
    # The default username for our AMI
    user = "ubuntu"

    # The connection will use the local SSH agent for authentication.
  }

  # We run a remote provisioner on the instance after creating it.
  # In this case, we just install nginx and start it. By default,
  # this should be on port 80
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get -y update",
      "sudo apt-get -y install nginx",
      "sudo service nginx start",
    ]
  }
}
