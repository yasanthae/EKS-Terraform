################################################################################
# VCN Outputs
################################################################################

output "vcn_id" {
  description = "OCID of the VCN"
  value       = oci_core_vcn.oke_vcn.id
}

output "vcn_cidr_blocks" {
  description = "CIDR blocks of the VCN"
  value       = oci_core_vcn.oke_vcn.cidr_blocks
}

################################################################################
# Subnet Outputs
################################################################################

output "public_subnet_ids" {
  description = "OCIDs of the public subnets"
  value       = oci_core_subnet.oke_public_subnet[*].id
}

output "private_subnet_ids" {
  description = "OCIDs of the private subnets"
  value       = oci_core_subnet.oke_private_subnet[*].id
}

output "public_subnet_cidr_blocks" {
  description = "CIDR blocks of the public subnets"
  value       = oci_core_subnet.oke_public_subnet[*].cidr_block
}

output "private_subnet_cidr_blocks" {
  description = "CIDR blocks of the private subnets"
  value       = oci_core_subnet.oke_private_subnet[*].cidr_block
}

################################################################################
# Gateway Outputs
################################################################################

output "internet_gateway_id" {
  description = "OCID of the Internet Gateway"
  value       = oci_core_internet_gateway.oke_ig.id
}

output "nat_gateway_id" {
  description = "OCID of the NAT Gateway"
  value       = oci_core_nat_gateway.oke_nat_gateway.id
}

output "service_gateway_id" {
  description = "OCID of the Service Gateway"
  value       = oci_core_service_gateway.oke_sg.id
}