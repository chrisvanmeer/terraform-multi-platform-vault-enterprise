terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.27.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.12.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "4.21.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.3.2"
    }

    template = {
      source  = "hashicorp/template"
      version = "2.2.0"
    }

    local = {
      source  = "hashicorp/local"
      version = "2.2.3"
    }

  }
}
