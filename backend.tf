terraform {
  required_version = ">=0.12.0"
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 5.0"
    }
  }
  
  backend "s3" {
    # OCI Object Storage with S3 compatibility
    endpoint                    = "https://namespace.compat.objectstorage.region.oraclecloud.com"
    bucket                     = "terraform-state-bucket"
    key                        = "oke-terraform/terraform.tfstate"
    region                     = "us-phoenix-1"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    force_path_style           = true
  }
}