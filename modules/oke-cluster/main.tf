################################################################################
# Data Sources
################################################################################

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_ocid
}

data "oci_containerengine_cluster_option" "oke_cluster_option" {
  cluster_option_id = "all"
}

data "oci_containerengine_node_pool_option" "oke_node_pool_option" {
  node_pool_option_id = "all"
}

# Get the latest Oracle Linux image
data "oci_core_images" "node_pool_images" {
  compartment_id           = var.compartment_ocid
  operating_system         = "Oracle Linux"
  operating_system_version = "8"
  shape                    = var.node_shape
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

################################################################################
# OKE Cluster
################################################################################

resource "oci_containerengine_cluster" "oke_cluster" {
  compartment_id     = var.compartment_ocid
  kubernetes_version = var.kubernetes_version
  name               = var.cluster_name
  vcn_id             = var.vcn_id

  endpoint_config {
    is_public_ip_enabled = true
    subnet_id            = var.api_endpoint_subnet_id
  }

  options {
    service_lb_subnet_ids = var.lb_subnet_ids

    add_ons {
      is_kubernetes_dashboard_enabled = false
      is_tiller_enabled               = false
    }

    kubernetes_network_config {
      pods_cidr     = "10.244.0.0/16"
      services_cidr = "10.96.0.0/16"
    }
  }

  freeform_tags = {
    "Environment" = var.environment
    "CreatedBy"   = "Terraform"
  }
}

################################################################################
# Node Pool
################################################################################

resource "oci_containerengine_node_pool" "oke_node_pool" {
  cluster_id         = oci_containerengine_cluster.oke_cluster.id
  compartment_id     = var.compartment_ocid
  kubernetes_version = var.kubernetes_version
  name               = "${var.cluster_name}-pool"
  node_shape         = var.node_shape

  node_shape_config {
    ocpus         = var.node_shape_config_ocpus
    memory_in_gbs = var.node_shape_config_memory_in_gbs
  }

  node_source_details {
    image_id    = data.oci_core_images.node_pool_images.images[0].id
    source_type = "IMAGE"
  }

  node_config_details {
    placement_configs {
      availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
      subnet_id           = var.nodepool_subnet_ids[0]
    }
    placement_configs {
      availability_domain = data.oci_identity_availability_domains.ads.availability_domains[1].name
      subnet_id           = var.nodepool_subnet_ids[1]
    }
    placement_configs {
      availability_domain = data.oci_identity_availability_domains.ads.availability_domains[2].name
      subnet_id           = var.nodepool_subnet_ids[2]
    }
    size = var.node_pool_size
  }

  initial_node_labels {
    key   = "name"
    value = var.cluster_name
  }

  freeform_tags = {
    "Environment" = var.environment
    "CreatedBy"   = "Terraform"
  }
}

################################################################################
# Dynamic Group for OKE
################################################################################

resource "oci_identity_dynamic_group" "oke_dynamic_group" {
  compartment_id = var.compartment_ocid
  description    = "Dynamic group for OKE cluster ${var.cluster_name}"
  matching_rule  = "ALL {instance.compartment.id = '${var.compartment_ocid}', tag.oke-cluster-name.value = '${var.cluster_name}'}"
  name           = "${var.cluster_name}-dynamic-group"

  freeform_tags = {
    "Environment" = var.environment
    "CreatedBy"   = "Terraform"
  }
}

################################################################################
# Policy for OKE Dynamic Group
################################################################################

resource "oci_identity_policy" "oke_policy" {
  compartment_id = var.compartment_ocid
  description    = "Policy for OKE cluster ${var.cluster_name}"
  name           = "${var.cluster_name}-policy"

  statements = [
    "allow dynamic-group ${oci_identity_dynamic_group.oke_dynamic_group.name} to manage load-balancers in compartment id ${var.compartment_ocid}",
    "allow dynamic-group ${oci_identity_dynamic_group.oke_dynamic_group.name} to manage volume-family in compartment id ${var.compartment_ocid}",
    "allow dynamic-group ${oci_identity_dynamic_group.oke_dynamic_group.name} to manage instance-family in compartment id ${var.compartment_ocid}",
    "allow dynamic-group ${oci_identity_dynamic_group.oke_dynamic_group.name} to use virtual-network-family in compartment id ${var.compartment_ocid}",
    "allow dynamic-group ${oci_identity_dynamic_group.oke_dynamic_group.name} to use file-family in compartment id ${var.compartment_ocid}"
  ]

  freeform_tags = {
    "Environment" = var.environment
    "CreatedBy"   = "Terraform"
  }
}