provider "aws" {
  region = "us-east-1"
}

resource "aws_key_pair" "ssh_key" {
  key_name = "ec2-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_vpc" "vpc" {
  cidr_block = var.cidr
}

resource "aws_subnet" "sub1" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "rta" {
  subnet_id = aws_subnet.sub1.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_security_group" "sg" {
  name = "WEB"
  vpc_id = aws_vpc.vpc.id

  ingress {
    description = "HTTP from VPC"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress{
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    name = "Web-sgs"
  }
}