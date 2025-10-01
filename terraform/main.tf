provider "aws" {
  region = "eu-north-1"
}

variable "ami_id" {
  # Ubuntu 22.04 LTS AMI in eu-north-1 (default)
  default = "ami-0a716d3f3b16d290c"
}

variable "instance_type" {
  default = "t3.micro"
}

# Use an existing public key file (safe for CI)
resource "aws_key_pair" "deployer" {
  key_name   = "jenkins-key"
  public_key = file("${path.module}/../keys/jenkins_deploy_key.pub")
}

resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Allow SSH and HTTP"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # tighten for production
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

resource "aws_instance" "web" {
  count         = 2
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = aws_key_pair.deployer.key_name

  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = {
    Name = "WebServer-${count.index + 1}"
  }
}
