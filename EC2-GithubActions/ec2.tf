# Data to retrieve the default VPC
data "aws_vpc" "default" {
  default = true
}

# Data to retrieve the default VPC's subnets
data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}

data "aws_subnet" "default" {
  id = data.aws_subnet_ids.default.ids[0]
}

# Security group to allow required traffic
resource "aws_security_group" "ec2_sg" {
  name        = "ec2-instance-sg"
  description = "Allow SSH, HTTP, HTTPS, Prometheus, Grafana, and additional ports"
  vpc_id      = data.aws_vpc.default.id

  # SSH
  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP
  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS
  ingress {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Prometheus (port 9090)
  ingress {
    description = "Allow Prometheus"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Node Exporter (port 9100)
  ingress {
    description = "Allow Node Exporter"
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Grafana (port 3000)
  ingress {
    description = "Allow Grafana"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Custom port (port 9000)
  ingress {
    description = "Allow custom port 9000"
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all egress
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance
resource "aws_instance" "ec2_instance" {
  ami           = "ami-0915bcb5fa77e4892" # Replace with your preferred Ubuntu AMI ID
  instance_type = "t2.medium"
  subnet_id     = data.aws_subnet.default.id
  security_groups = [
    aws_security_group.ec2_sg.name,
  ]

  key_name = "EC2" # Replace with your key pair

  tags = {
    Name = "Self-Hosted-Runner"
  }
}
