
provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}

terraform {
  required_version = ">= 0.12"
}

data "terraform_remote_state" "vpc" {
  backend = "local"

  config = {
    path = "${path.module}/../../global/vpc/terraform.tfstate"
  }
}

provider "onepassword" {
}

data "onepassword_item_password" "logz_token" {
  name = var.logz_secret_id
}

data "onepassword_item_login" "aws-gw1_dyndns" {
  name = var.bastion_ddns_secret_id
}

# TODO Review filter
# Get the AMI id for the latest AWS NAT image
data "aws_ami" "amazon-linux-nat" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-vpc-nat-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "amazon-nat-sg" {
  name        = "amazon-net-sg"
  description = "Permits access for JumpBox and private network NAT service"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_staging_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allow_admin_cidr]
  }

  # ingress {
  #   from_port   = 80
  #   to_port     = 80
  #   protocol    = "tcp"
  #   cidr_blocks = [data.terraform_remote_state.vpc.outputs.vpc_mgmt_subnet_a_cidr]
  # }

  # ingress {
  #   from_port   = 443
  #   to_port     = 443
  #   protocol    = "tcp"
  #   cidr_blocks = [data.terraform_remote_state.vpc.outputs.vpc_mgmt_subnet_a_cidr]
  # }

  egress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    #tfsec:ignore:AWS009 Required for NAT services
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    #tfsec:ignore:AWS009 Required for NAT services
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Bastion: Enable RDP from bastion"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = [data.terraform_remote_state.vpc.outputs.vpc_cidr_block]
  }

  # TODO Review, useful for occassional troubleshooting
  egress {
    description = "Bastion: Ping... "
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [data.terraform_remote_state.vpc.outputs.vpc_cidr_block]
  }
}

# Routing table for mgmt subnet
resource "aws_route_table" "vpc_staging_mgmt_sn_a_rt" {
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_staging_id
  route {
    cidr_block  = "0.0.0.0/0"
    instance_id = aws_instance.nat-instance.id
  }
  tags = {
    Name = "vpc_staging_mgmt_sn_a_rt"
  }
}

# Attach route for NAT instance to management subnet
resource "aws_route_table_association" "mgmt-nat-rt-a" {
  subnet_id      = data.terraform_remote_state.vpc.outputs.vpc_staging_mgmt_sn_a_id
  route_table_id = aws_route_table.vpc_staging_mgmt_sn_a_rt.id
}

# TODO Provide a flag to disable user_data
# Deploy a server
resource "aws_instance" "nat-instance" {
  ami                         = data.aws_ami.amazon-linux-nat.id
  instance_type               = "t2.micro"
  subnet_id                   = data.terraform_remote_state.vpc.outputs.vpc_staging_public_sn_a_id
  associate_public_ip_address = true #tfsec:ignore:AWS012 Required for NAT and Bastion Services
  tags                        = { Name : "nat-instance" }
  key_name                    = var.bastion_key
  vpc_security_group_ids      = [aws_security_group.amazon-nat-sg.id]
  user_data                   = data.template_file.init.rendered
  source_dest_check           = false # Must be disabled to be able to be a NAT service

  provisioner "local-exec" {
    # TODO provide a flag for calling dhclient
    command = "/usr/local/sbin/ddclient -file tmp/ddclient.conf -ip ${aws_instance.nat-instance.public_ip}"
  }
}

# user_data script
# Sends all logs to a logz.io service
data "template_file" "init" {
  template = <<EOF
#!/bin/bash
curl -sLO https://github.com/logzio/logzio-shipper/raw/master/dist/logzio-rsyslog.tar.gz \
&& tar xzf logzio-rsyslog.tar.gz \
&& sudo rsyslog/install.sh -t linux -a "${data.onepassword_item_password.logz_token.password}" -l "${var.logz_endpoint}" -q
sudo yum update -y
sudo yum install -y python36
  EOF
}
