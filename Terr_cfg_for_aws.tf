terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

variable "aws_region" {
  type = string
}

variable "key_pair_name" {
  type = string
}

variable "public_key" {
  type = string
}

variable "ec2_instance_type" {
  type = string
}

provider "aws" {
  region = var.aws_region
}

data "aws_ami" "debian" {
  most_recent = true
  owners      = ["679593333241"]

  filter {
    name   = "name"
    values = ["debian-stretch-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_eip" "elastic_ip" {
  instance = aws_instance.devops_task_6c.id
}

resource "aws_security_group" "devops-task" {
  name = "devops-task-SG"

  ingress = [
    {
      description      = "HTTP"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    },
    {
      description      = "SSH"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = []
    self             = false
  }
}

resource "aws_key_pair" "tf-key" {
  key_name   = var.key_pair_name
  public_key = var.public_key
}

resource "aws_instance" "devops_task_6c" {
  ami           = data.aws_ami.debian.id
  instance_type = var.ec2_instance_type

  vpc_security_group_ids = [aws_security_group.devops-task.id]

  key_name = aws_key_pair.tf-key.id

  root_block_device {
    volume_size = 15
  }

  user_data = <<-EOL
  #!/bin/bash
  apt update && apt install -y nginx
  echo 'Hello world from Crash course DevOps' > /var/www/html/index.html
  EOL
}
