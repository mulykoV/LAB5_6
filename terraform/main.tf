terraform {
  required_version = ">= 0.13.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Backend configuration для S3 та DynamoDB
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

# Ресурс для Lightsail контейнерного сервісу
resource "aws_lightsail_container_service" "flask_app" {
  name        = "flask-app"
  power       = "nano"   # Тип сервісу (nano, micro, small і т.д.)
  scale       = 1        # Кількість вузлів
  is_active   = true

  private_registry_access {
    ecr_image_puller_role = true
  }

  tags = {
    Environment = "production"
    Project     = "Lab6"
  }
}

# Ресурс для розгортання додатку
resource "aws_lightsail_container_service_deployment_version" "flask_app_deployment" {
  container_service_name = aws_lightsail_container_service.flask_app.name

  container {
    image = "${var.REPOSITORY_URI}:latest" # Використовує останню версію імеджа
    command = []  # Можна додати команди для запуску контейнера
    environment = {
      APP_ENV = "production"
    }
    ports = {
      "80" = "HTTP"
    }
  }

  public_endpoint {
    container_name = "flask_app"
    container_port = 80

    health_check {
      healthy_threshold   = 2
      unhealthy_threshold = 2
      timeout_seconds     = 2
      interval_seconds    = 5
      path                = "/"
      success_codes       = "200-499"
    }
  }
}
