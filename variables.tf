variable "ec2_region" {
  type    = string
  default = "us-east-1"
}

variable "instance_size" {
  type    = string
  default = "t3.micro"
}

variable "ec2_ami" {
  type    = string
  default = "ami-091138d0f0d41ff90" # Your exact console Ubuntu AMI ID
}

variable "ec2_ssh_key" {
  type    = string
  default = "Newkp"
}
