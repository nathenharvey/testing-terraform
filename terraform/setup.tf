provider "aws" {
}

resource "aws_instance" "web" {
  instance_type = "t2.micro"
  ami = "ami-14c5486b"
#   key_name = "${aws_key_pair.auth.id}"
#   subnet_id = "${aws_subnet.default.id}"
#   vpc_security_group_ids = [
#     "${aws_security_group.lb_to_webservers.id}",
#     "${aws_security_group.ssh_from_office.id}",
#   ]
  tags {
    Project = "Innovative monetization"
  }
}

