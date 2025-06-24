################################################################################
# VCN Module
################################################################################

module "vcn" {
  source = "./modules/vcn"

  compartment_ocid = var.compartment_ocid
  region           = var.region
  environment      = var.environment
}

################################################################################
# OKE Cluster Module
################################################################################

module "oke" {
  source = "./modules/oke-cluster"

  compartment_ocid    = var.compartment_ocid
  region              = var.region
  cluster_name        = var.cluster_name
  kubernetes_version  = var.kubernetes_version
  environment         = var.environment
  
  vcn_id              = module.vcn.vcn_id
  lb_subnet_ids       = module.vcn.public_subnet_ids
  nodepool_subnet_ids = module.vcn.private_subnet_ids
  api_endpoint_subnet_id = module.vcn.public_subnet_ids[0]
  
  node_pool_size                    = var.node_pool_size
  node_shape                        = var.node_shape
  node_shape_config_ocpus          = var.node_shape_config_ocpus
  node_shape_config_memory_in_gbs  = var.node_shape_config_memory_in_gbs
}

################################################################################
# Load Balancer Module
################################################################################

module "load_balancer" {
  source = "./modules/load-balancer"

  compartment_ocid = var.compartment_ocid
  region           = var.region
  environment      = var.environment
  
  vcn_id           = module.vcn.vcn_id
  public_subnet_ids = module.vcn.public_subnet_ids
  cluster_id       = module.oke.cluster_id
}