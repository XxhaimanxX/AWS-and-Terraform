###########
## Provider
###########
provider "aws" {
    #profile = var.aws_profile
    region = var.aws_region
}

###########
## Remote State
###########

terraform {
  cloud{
    organization = "Opsschool-Israel_H"

    workspaces {
        name = "network"
    }
  }
}