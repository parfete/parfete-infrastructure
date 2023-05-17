terraform {
  backend "remote" {
    # The name of your Terraform Cloud organization.
    organization = "parfete"
    
    # The name of the Terraform Cloud workspace to store Terraform state files in.
    workspaces {
      name = "parfete"
    }
  }
}
