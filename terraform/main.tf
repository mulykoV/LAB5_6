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

variable "REPOSITORY_URI" {
  type        = string
  description = "Опис змінної з назвою реєстру образів"
}

resource "aws_lightsail_container_service" "flask_application" {
  name  = "flask-application"
  power = "nano"  # Тип виводу
  scale = 1

  private_registry_access {} # Увімкнення доступу до приватного реєстру

  tags = {
    version = "1.0.0"
  }
}

resource "aws_lightsail_container_service_deployment_version" "flask_app_deployment" {

  container {
    container_name = "flask-application" # Правильний аргумент
    image          = "${var.REPOSITORY_URI}:latest"

    ports = {
      "8080" = "HTTP"
    }
  }

  public_endpoint {
    container_name = "flask-application" # Обов'язковий аргумент
    container_port = 8080               # Правильний порт для доступу
    health_check {
      healthy_threshold   = 3
      unhealthy_threshold = 5
      timeout_seconds     = 5
      interval_seconds    = 30
      path                = "/"
      success_codes       = "200-499"
    }
  }

  service_name = aws_lightsail_container_service.flask_application.name
}
