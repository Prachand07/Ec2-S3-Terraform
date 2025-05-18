terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.38.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "> 3.4"
    }
  }
}

provider "aws" {
  region = var.region
}

# VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

# Private Subnet 
resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = false
  availability_zone       = var.availability_zone
}

# Creating a Route Table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

# Security Group
resource "aws_security_group" "ec2_sg" {
  name   = "ec2_private_sg"
  vpc_id = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#Allowing Ec2 to assume role
resource "aws_iam_role" "ec2_role" {
  name = "ec2-read-s3-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

#Defining what EC2 is allowed with respect to S3
resource "aws_iam_role_policy" "s3_read_only" {
  name = "s3-read-only"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = ["s3:GetObject", "s3:ListBucket", "s3:Describe*"],
      Resource = ["arn:aws:s3:::*", "arn:aws:s3:::*/*"]
    }]
  })
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "s3-read"
  role = aws_iam_role.ec2_role.name
}

# Creating the ec2 instance
resource "aws_instance" "ec2" {
  ami                         = var.ami_id
  instance_type               = var.ec2_type
  subnet_id                   = aws_subnet.private.id
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
  associate_public_ip_address = false

  tags = {
    Name = "MyEC2"
  }
}

#Generate random id to ensure bucket name is unqiue
resource "random_id" "suffix" {
  byte_length = 4
}
#Creating S3 bucket
resource "aws_s3_bucket" "my_bucket" {
  bucket = "my-task-${random_id.suffix.hex}"
}
#Enable versioning on the created bucket
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.my_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}
# Enabling sse on the bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.my_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
#Blocking public access of the bucket
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket                  = aws_s3_bucket.my_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
#Printing the name of the source bucket
output "bucket_name" {
  value = aws_s3_bucket.my_bucket.bucket
}
