terraform {
  required_version = ">= 0.13.0"

  required_providers {
    aws = {
@@ -13,14 +13,21 @@ terraform {
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
@@ -56,3 +63,5 @@ resource "aws_security_group" "web_app" {
    Name = "web_app"
  }
}
