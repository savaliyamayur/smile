# Configure AWS provider
provider "aws" {
  region = "us-east-1" # Replace with your desired region
}

# Create VPC and subnets
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  subnet {
    availability_zone = "us-east-1a"
    cidr_block = "10.0.1.0/24"
  }

  subnet {
    availability_zone = "us-east-1b"
    cidr_block = "10.0.2.0/24"
  }
}

# Create EKS cluster with managed node groups
resource "aws_eks_cluster" "api_cluster" {
  name = "my-rest-api-cluster"
  vpc_config {
    subnet_ids = [aws_subnet.main[0].id, aws_subnet.main[1].id]
    security_group_ids = [aws_security_group.api_sg.id]
  }
  role_arn = aws_iam_role.cluster_role.arn
  node_group_role_arn = aws_iam_role.node_group_role.arn
  node_sizing = {
    desired_size = 2
    max_size = 4
    instance_type = "t3.medium"
  }
}

# Define security groups
resource "aws_security_group" "api_sg" {
  name = "api-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port = 5000
    to_port = 5000
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Restrict to specific CIDRs in production
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Configure IAM roles for EKS and node groups
resource "aws_iam_role" "cluster_role" {
  name = "eks-cluster-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role" "node_group_role" {
  name = "eks-node-group-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# Attach policies to IAM roles
resource "aws_iam_role_policy_attachment" "cluster_role_attachment" {
  role = aws_iam_role.cluster_role.id
  policy_arn = aws_iam_policy.amazon_eks_cluster_policy.arn
}

resource "aws_iam_role_policy_attachment" "node_group_role_attachment" {
  role = aws_iam_role.node_group_role.id
  policy_arn = aws_iam_policy.amazon_eks_nodegroup_policy.arn
}

# Import EKS cluster endpoint for kubectl access
output "cluster_endpoint" {
  value = aws_eks_cluster.api_cluster.endpoint
}

