terraform{
    required_providers{
        local ={
            source = "hashicorp/local"
            version = "~> 2.5"
        }
        random = {
            source = "hashicorp/random"
            version = "~> 3.6"
        }
    }
}

provider "local" {}
provider "random" {}