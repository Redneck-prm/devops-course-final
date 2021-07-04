terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = "eu-central-1"
}

resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "main"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "main"
  }
}


resource "aws_route_table_association" "main" {
    subnet_id = aws_subnet.main1.id
    route_table_id = aws_route_table.main.id
}

resource "aws_subnet" "main1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.0.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "main1"
  }
}


resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "SSH from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}

resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "http from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_http"
  }
}


resource "aws_network_interface" "web1" {
  subnet_id   = aws_subnet.main1.id
  private_ips = ["10.0.0.10"]
  security_groups = [aws_security_group.allow_ssh.id, aws_security_group.allow_http.id]
  tags = {
    Name = "web1"
  }
}


resource "aws_instance" "web-nginx-docker" {
  ami = "ami-05f7491af5eef733a"
  instance_type = "t2.micro"
  key_name = "vkuz-work"

  network_interface {
    network_interface_id = aws_network_interface.web1.id
    device_index         = 0
  }
 
  tags = {
    Name = "web-nginx-docker"
  }
}
