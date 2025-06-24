################################################################################
# General Variables
################################################################################

variable "compartment_ocid" {
  description = "OCID of the compartment"
  type        = string
}

variable "region" {
  description = "OCI region"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

################################################################################
# Cluster Variables
################################################################################

variable "cluster_name" {
  description = "Name of the OKE cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version for OKE cluster"
  type        = string
}

################################################################################
# Network Variables
################################################################################

variable "vcn_id" {
  description = "OCID of the VCN"
  type        = string
}

variable "lb_subnet_ids" {
  description = "OCIDs of the load balancer subnets"
  type        = list(string)
}

variable "nodepool_subnet_ids" {
  description = "OCIDs of the node pool subnets"
  type        = list(string)
}

variable "api_endpoint_subnet_id" {
  description = "OCID of the API endpoint subnet"
  type        = string
}

################################################################################
# Node Pool Variables
################################################################################

variable "node_pool_size" {
  description = "Number of nodes in the node pool"
  type        = number
}

variable "node_shape" {
  description = "Shape of the worker nodes"
  type        = string
}

variable "node_shape_config_ocpus" {
  description = "Number of OCPUs for flexible node shape"
  type        = number
}

variable "node_shape_config_memory_in_gbs" {
  description = "Amount of memory in GBs for flexible node shape"
  type        = number
}