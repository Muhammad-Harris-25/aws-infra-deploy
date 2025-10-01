# Use existing key pair (do not force create)
resource "aws_key_pair" "deployer" {
  key_name = "jenkins-key"  # Already exists in AWS
  # remove 'public_key' if already imported
}

# Use existing security group
resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Allow web traffic"
  vpc_id      = "vpc-0ee0b1e9385206793"  # replace with your VPC ID

  # Example ingress rules (optional)
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

# Your EC2 instances
resource "aws_instance" "web" {
  count         = 2
  ami           = "ami-0a716d3f3b16d290c"
  instance_type = "t3.micro"
  key_name      = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = {
    Name = "WebServer-${count.index + 1}"
  }
}
