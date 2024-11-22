provider "aws" {
  region = "eu-west-2"
}

# Fetch default VPC
data "aws_vpc" "default" {
  default = true
}

# Fetch default subnet
data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}

# Create Security Group
resource "aws_security_group" "runner_sg" {
  name        = "self_hosted_runner_sg"
  description = "Allow required ports for monitoring, runner, and HTTP/HTTPS"
  vpc_id      = data.aws_vpc.default.id

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Restrict to your IP range
  }

  # HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Prometheus
  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Node Exporter
  ingress {
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Grafana
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# IAM Role for EC2
resource "aws_iam_role" "ec2_role" {
  name = "EC2_Admin_Access"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach Administrative Access Policy to the Role
resource "aws_iam_role_policy_attachment" "ec2_admin_access" {
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  role       = aws_iam_role.ec2_role.name
}

# Instance Profile for EC2 Role
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "EC2_Instance_Profile"
  role = aws_iam_role.ec2_role.name
}

# Launch EC2 Instance
resource "aws_instance" "self_hosted_runner" {
  ami           = "ami-1234567890abcdef0" # Replace with an appropriate AMI ID for your region
  instance_type = "t2.medium"
  subnet_id     = element(data.aws_subnet_ids.default.ids, 0)
  security_groups = [
    aws_security_group.runner_sg.name
  ]
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name

  # Key Pair
  key_name = "your-key-pair-name" # Replace with your existing EC2 key pair name

  tags = {
    Name = "Self-Hosted Runner"
  }
}
