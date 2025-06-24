################################################################################
# Cluster Outputs
################################################################################

output "cluster_id" {
  description = "OCID of the OKE cluster"
  value       = oci_containerengine_cluster.oke_cluster.id
}

output "cluster_name" {
  description = "Name of the OKE cluster"
  value       = oci_containerengine_cluster.oke_cluster.name
}

output "cluster_endpoint" {
  description = "Kubernetes API server endpoint"
  value       = oci_containerengine_cluster.oke_cluster.endpoints[0].kubernetes
}

output "cluster_ca_certificate" {
  description = "Base64 encoded cluster CA certificate"
  value       = base64decode(oci_containerengine_cluster.oke_cluster.kubernetes_version)
  sensitive   = true
}

output "kubernetes_version" {
  description = "Kubernetes version of the cluster"
  value       = oci_containerengine_cluster.oke_cluster.kubernetes_version
}

################################################################################
# Node Pool Outputs
################################################################################

output "node_pool_id" {
  description = "OCID of the node pool"
  value       = oci_containerengine_node_pool.oke_node_pool.id
}

output "node_pool_name" {
  description = "Name of the node pool"
  value       = oci_containerengine_node_pool.oke_node_pool.name
}

################################################################################
# Policy Outputs
################################################################################

output "dynamic_group_id" {
  description = "OCID of the dynamic group"
  value       = oci_identity_dynamic_group.oke_dynamic_group.id
}

output "policy_id" {
  description = "OCID of the policy"
  value       = oci_identity_policy.oke_policy.id
}