terraform {
  required_version = ">= 0.13.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "lab6-7ter-form"
    key            = "terraform.tfstate"
    region         = "ap-northeast-1"
    dynamodb_table = "lab-my-tf-lockid"
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

# Оголошення змінної для REPOSITORY_URI
variable "REPOSITORY_URI" {
  description = "The URI of the Docker repository"
  type        = string
}

# Lightsail контейнерний сервіс
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

resource "aws_lightsail_container_service_deployment_version" "flask_app_deployment" {
  container {
    container_name = "flask-application"
    image          = "${var.REPOSITORY_URI}:latest"

    ports = {
      8080 = "HTTP"
    }
  }

  public_endpoint {
    container_name  = "flask-application"
    container_port  = 8080

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

# Security Group
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
    cidr_blocks = ["your_public_ip/32"] # Заміна на вашу публічну IP адресу
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
