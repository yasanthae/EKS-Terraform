# Copy this file to terraform.tfvars and fill in your values

################################################################################
# OCI Authentication
################################################################################

tenancy_ocid     = "ocid1.tenancy.oc1..aaaaaaaa..."
user_ocid        = "ocid1.user.oc1..aaaaaaaa..."
private_key_path = "~/.oci/oci_api_key.pem"
fingerprint      = "aa:bb:cc:dd:..."
region           = "us-phoenix-1"

################################################################################
# Compartment
################################################################################

compartment_ocid = "ocid1.compartment.oc1..aaaaaaaa..."

################################################################################
# Environment Configuration
################################################################################

environment        = "dev"
cluster_name        = "oke-cluster"
kubernetes_version  = "v1.30.1"

################################################################################
# Node Pool Configuration
################################################################################

node_pool_size                    = 2
node_shape                        = "VM.Standard.E4.Flex"
node_shape_config_ocpus          = 2
node_shape_config_memory_in_gbs  = 16