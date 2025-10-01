# main.tf

provider "aws" {
  region = "eu-north-1"
}

# Use imported security group
data "aws_security_group" "web_sg" {
  filter {
    name   = "group-name"
    values = ["web-sg"]
  }
}

# Launch EC2 instances using imported key pair and security group
resource "aws_instance" "web" {
  count         = 2
  ami           = "ami-0a716d3f3b16d290c"  # replace with your AMI
  instance_type = "t3.micro"
  key_name      = "jenkins-key"  # reference imported key

  vpc_security_group_ids = [data.aws_security_group.web_sg.id]

  tags = {
    Name = "WebServer-${count.index + 1}"
  }
}


