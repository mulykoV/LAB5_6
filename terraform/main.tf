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
    dynamodb_table = "lab-my-tf-lockid" # Назва DynamoDB таблиці для lock-файлів
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

# Ресурс для безпеки: створення Security Group
resource "aws_security_group" "web_app" {
  name        = "web_app"
  description = "Security group for web app"

  lifecycle {
    prevent_destroy = true
  }

  # Правила вхідного трафіку (ingress)
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

  # Правила вихідного трафіку (egress)
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

# Інші ресурси, такі як EC2, S3, RDS тощо, можна додавати тут, залежно від твоїх вимог
