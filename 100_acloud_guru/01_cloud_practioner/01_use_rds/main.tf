terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }

  backend "s3" {
    bucket = "jomo-acloudguru"
    key    = "jomo-acloudguru"
    region = "us-east-1"
  }

}

provider "aws" {
  region = "us-east-1"
}

variable "environment" {
  default = "prod"
}

data "aws_caller_identity" "iam" {}

data "aws_iam_user" "acloudguru" {
  user_name = "acloudguru"
}


variable "azs" {
  default = "us-east-1b,us-east-1c"
}


resource "aws_vpc" "db_vpc" {
  cidr_block = "10.123.0.0/16"
}

resource "aws_vpc" "ec2_vpc" {
  cidr_block = "10.124.0.0/16"
}

# Creating one subnet in each AZ
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.db_vpc.id
  count             = length(split(",", var.azs))
  availability_zone = element(split(",", var.azs), count.index)
  cidr_block        = "10.123.${count.index}.0/24"
}


resource "aws_db_subnet_group" "rdsmain_private" {
  name        = "rdsmain-private"
  description = "Private subnets for RDS instance"
  subnet_ids  = aws_subnet.private.*.id
}


resource "aws_security_group" "rds" {
  name        = "rds-sg"
  description = "Allow MySQL traffic to rds"
  vpc_id      = aws_vpc.db_vpc.id
}

resource "aws_security_group_rule" "sb_ingress" {
  from_port         = 0
  protocol          = "TCP"
  security_group_id = aws_security_group.rds.id
  to_port           = 3306
  type              = "ingress"
  cidr_blocks       = [
    aws_vpc.ec2_vpc.cidr_block]
}

resource "aws_db_instance" "default" {
  allocated_storage    = 10
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  name                 = "acloudguru"
  username             = "foo"
  password             = "foobarbaz"
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true

  identifier           = "acloudguru"
  storage_type         = "gp2"
  multi_az             = true
  db_subnet_group_name = aws_db_subnet_group.rdsmain_private.name

}


locals {
  instance-userdata = <<EOF
#!/bin/bash
export PATH=$PATH:/usr/local/bin
which pip >/dev/null
if [ $? -ne 0 ];
then
  echo 'PIP NOT PRESENT'
  if [ -n "$(which yum)" ];
  then
    yum install -y python-pip
  else
    apt-get -y update && apt-get -y install python-pip
  fi
else
  echo 'PIP ALREADY PRESENT'
fi
EOF
}
variable "amis" {
  type    = "map"
  default = {
    "eu-west-1" = "ami-0c21ae4a3bd190229"
    "us-east-1" = "ami-0922553b7b0369273"
  }
}
variable "region" {
  type    = "string"
  default = "us-east-1"
}
resource "aws_instance" "myinstance1" {
  ami              = lookup(var.amis, var.region)
  instance_type    = "t2.micro"
  user_data_base64 = base64encode(local.instance-userdata)
}
