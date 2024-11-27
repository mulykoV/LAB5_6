terraform {
  required_version = ">= 0.13.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }

  backend "s3" {
    bucket         = "lab6-7ter-form"
    key            = "terraform.tfstate"
    region         = "ap-northeast-1"
    dynamodb_table = "lab-my-tf-lockid" # DynamoDB table for state locking
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

# Declare REPOSITORY_URI variable
variable "REPOSITORY_URI" {
  description = "The URI of the Docker repository"
  type        = string
}

# Security group resource
resource "aws_security_group" "web_app" {
  name        = "web_app"
  description = "Security group for web app"

  lifecycle {
    prevent_destroy = true
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web_app"
  }
}

# ECR repository resource
resource "aws_ecr_repository" "flask_app" {
  name = "flask-app-repo"
}

# Build the Docker image
resource "docker_image" "flask_app_image" {
  name          = "${aws_ecr_repository.flask_app.repository_url}:latest"
  build {
    context    = "D:/Learning/ProgrammingTechnology/LAB5-6"  # Path to your Dockerfile
    dockerfile = "Dockerfile"  # Dockerfile location
  }
}

# IAM role policy for ECR access (Lightsail needs this to pull images)
resource "aws_iam_role" "ecr_access_role" {
  name = "lightsail_ecr_access"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Principal = {
        Service = "lightsail.amazonaws.com"
      }
      Action   = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "ecr_access_policy" {
  name        = "ecr_access_policy"
  description = "Policy to allow Lightsail to access ECR"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage"
      ]
      Resource = "*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecr_access_policy_attachment" {
  role       = aws_iam_role.ecr_access_role.name
  policy_arn = aws_iam_policy.ecr_access_policy.arn
}

# Lightsail container service
resource "aws_lightsail_container_service" "flask_application" {
  name  = "flask-app"
  power = "nano"
  scale = 1

  private_registry_access {
    ecr_image_puller_role {
      is_active = true
    }
  }

  tags = {
    version = "1.0.0"
  }
}

# Deployment version for Lightsail container service
resource "aws_lightsail_container_service_deployment_version" "flask_app_deployment" {
  container {
    container_name = "flask-application"
    image          = docker_image.flask_app_image.name  # Using the created Docker image

    ports = {
      80 = "HTTP"
    }
  }

  public_endpoint {
    container_name  = "flask-application"
    container_port  = 80

    health_check {
      healthy_threshold   = 2
      unhealthy_threshold = 2
      timeout_seconds     = 2
      interval_seconds    = 5
      path                = "/"
      success_codes       = "200-499"
    }
  }

  service_name = aws_lightsail_container_service.flask_application.name
}

# Output logs from Lightsail deployment (to troubleshoot)
output "lightsail_deployment_logs" {
  value = aws_lightsail_container_service_deployment_version.flask_app_deployment.container
}

