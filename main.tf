# 1. Strict structural block to fetch the AWS plugin
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket  = "pyaephyo-terraform-state-bucket" # Must match your exact bucket name
    key     = "dev/terraform.tfstate"           # The folder path inside the bucket
    region  = "us-east-1"
    encrypt = true # Encrypts the state file for security
  }
}

# 2. Strict cloud keyword, passing your custom variable reference
provider "aws" {
  region = var.ec2_region
}

# 3. Create a Security Group with a custom nickname ("my_custom_firewall")
resource "aws_security_group" "ec2_firewall" {
  name = "security_gp"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 4. Launch the EC2 Instance with a custom nickname ("my_dev_server")
resource "aws_instance" "second_server" {
  ami           = var.ec2_ami
  instance_type = var.instance_size
  key_name      = var.ec2_ssh_key

  # Strict parameter referencing your custom firewall resource nickname dynamically!
  vpc_security_group_ids = [aws_security_group.ec2_firewall.id]

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install nginx -y
              sudo systemctl start nginx
              sudo systemctl enable nginx
              EOF

  tags = {
    Name = "Restart-Nginx-Server"
  }
}

# 5. Automatically print the public IP address
output "deployed_server_ip" {
  value = aws_instance.second_server.public_ip
}
