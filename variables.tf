variable "region" {
  default = "eu-north-1"
}

# variable "aws_access_key" {
#   type = string
# }

# variable "aws_secret_key" {
#   type = string
# }

variable "ami_id" {
  description = "AMI ID to use for EC2 instance"
  type        = string
  default     = "ami-00f34bf9aeacdf007"
}

variable "ec2_type" {
  default = "t3.micro"
}

variable "availability_zone" {
  default = "eu-north-1a"
}
