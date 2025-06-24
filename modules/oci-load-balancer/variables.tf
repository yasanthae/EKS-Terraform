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
# Network Variables
################################################################################

variable "vcn_id" {
  description = "OCID of the VCN"
  type        = string
}

variable "public_subnet_ids" {
  description = "OCIDs of the public subnets for load balancer"
  type        = list(string)
}

################################################################################
# Cluster Variables
################################################################################

variable "cluster_id" {
  description = "OCID of the OKE cluster"
  type        = string
}