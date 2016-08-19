variable "region" {
  default = "us-east-1"
  description = "The region of AWS, for AMI lookups."
}

variable "amis" {
  type = "map"
  default = {
    us-east-1 = "ami-2d39803a"
  }
}

variable "availability_zones" {
    default = "subnet-013c3c77,subnet-48401d10,subnet-c76030ed,subnet-023f0c3f"
 }

variable "key_name" {
	default = "TESTDEVOPS"
    description = "SSH key name in your AWS account for AWS instances."
}

variable "health_check_type" {
	default = "ELB"
	description = "Health check type for the ELB"
}

variable "iam_profile" {
	default = "Admin"
}

variable "instance_type" {
	default = "t2.micro"
}

variable "asg_max" {
	default = 3
}

variable "asg_min" {
	default = 1
}

variable "asg_desired" {
	default = 1
}