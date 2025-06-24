# OKE-Terraform

This Terraform configuration creates an Oracle Kubernetes Engine (OKE) cluster on Oracle Cloud Infrastructure (OCI) with supporting networking and load balancer infrastructure.

## Architecture

The infrastructure includes:
- **VCN (Virtual Cloud Network)** with public and private subnets across 3 availability domains
- **OKE Cluster** with managed node pool
- **Load Balancer** for external access
- **Security Groups and Policies** for proper access control

## Prerequisites

1. **OCI Account**: Active Oracle Cloud Infrastructure account
2. **OCI CLI**: Installed and configured
3. **API Key**: Generated in OCI Console
4. **Terraform**: Version 0.12 or later
5. **kubectl**: For cluster management

## Setup Instructions

### 1. OCI Configuration

Generate an API key pair in the OCI Console:
```bash
# Generate private key
openssl genrsa -out ~/.oci/oci_api_key.pem 2048

# Generate public key
openssl rsa -pubout -in ~/.oci/oci_api_key.pem -out ~/.oci/oci_api_key_public.pem
```

Add the public key to your OCI user profile in the console.

### 2. Configure Variables

Copy the example variables file:
```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your OCI details:
- `tenancy_ocid`: Your tenancy OCID
- `user_ocid`: Your user OCID
- `compartment_ocid`: Target compartment OCID
- `fingerprint`: Your API key fingerprint
- `private_key_path`: Path to your private key file

### 3. Update Backend Configuration

Edit `backend.tf` to configure your Object Storage backend:
- Replace `namespace` with your OCI namespace
- Replace `region` with your target region
- Ensure the bucket exists or create it

### 4. Deploy Infrastructure

Initialize and deploy:
```bash
# Initialize Terraform
terraform init

# Plan the deployment
terraform plan

# Apply the configuration
terraform apply
```

## Accessing the Cluster

After deployment, configure kubectl:
```bash
# Get the kubeconfig
oci ce cluster create-kubeconfig \
  --cluster-id <cluster-id> \
  --file $HOME/.kube/config \
  --region <region> \
  --token-version 2.0.0

# Verify access
kubectl get nodes
```

## Key Features

### Networking
- **VCN**: 10.0.0.0/16 CIDR with DNS resolution
- **Public Subnets**: 10.0.101-103.0/24 for load balancers
- **Private Subnets**: 10.0.1-3.0/24 for worker nodes
- **NAT Gateway**: Outbound internet access for private subnets
- **Service Gateway**: Access to OCI services

### Security
- **Network Security Groups**: Controlled access rules
- **IAM Policies**: Least privilege access for OKE
- **Dynamic Groups**: Instance-based policy assignment

### High Availability
- **Multi-AD Deployment**: Resources across 3 availability domains
- **Managed Node Pool**: Auto-healing and updates
- **Load Balancer**: Traffic distribution and health checks

## Configuration Options

### Node Pool Scaling
Modify in `terraform.tfvars`:
```hcl
node_pool_size = 3
node_shape = "VM.Standard.E4.Flex"
node_shape_config_ocpus = 4
node_shape_config_memory_in_gbs = 32
```

### Kubernetes Version
Update the cluster version:
```hcl
kubernetes_version = "v1.30.1"
```

### Load Balancer
The load balancer is configured for HTTP/HTTPS traffic. For HTTPS, add an SSL certificate:
```hcl
# In modules/load-balancer/main.tf
ssl_configuration {
  certificate_name = "your-certificate"
}
```

## Outputs

After deployment, you'll get:
- **Cluster ID**: For kubectl configuration
- **Cluster Endpoint**: Kubernetes API server URL
- **Load Balancer IP**: Public IP for external access
- **VCN Details**: Network configuration information

## Cost Optimization

### Development Environment
- Use `VM.Standard.E4.Flex` with 1-2 OCPUs
- Set `node_pool_size = 1` for testing
- Use smaller load balancer bandwidth

### Production Environment
- Use `VM.Standard.E4.Flex` with 4+ OCPUs
- Set `node_pool_size = 3` or higher
- Configure autoscaling (manual configuration required)

## Troubleshooting

### Common Issues

1. **Authentication Errors**
   - Verify API key configuration
   - Check tenancy and user OCIDs
   - Ensure proper IAM permissions

2. **Network Connectivity**
   - Verify security list rules
   - Check route table configurations
   - Ensure NAT gateway is functioning

3. **Node Pool Issues**
   - Check compute quotas
   - Verify image availability in region
   - Review dynamic group policies

### Useful Commands

```bash
# Check cluster status
oci ce cluster get --cluster-id <cluster-id>

# List node pools
oci ce node-pool list --compartment-id <compartment-id>

# Get cluster events
kubectl get events --all-namespaces

# Check node status
kubectl describe nodes
```

## Cleanup

To destroy the infrastructure:
```bash
terraform destroy
```

Note: Ensure all Kubernetes resources (LoadBalancer services, PVCs) are deleted first to avoid orphaned OCI resources.

## Additional Resources

- [OCI Terraform Provider Documentation](https://registry.terraform.io/providers/oracle/oci/latest/docs)
- [OKE Documentation](https://docs.oracle.com/en-us/iaas/Content/ContEng/home.htm)
- [OCI CLI Documentation](https://docs.oracle.com/en-us/iaas/tools/oci-cli/latest/oci_cli_docs/)

## Migration Notes from AWS EKS

Key differences from the original AWS setup:
- **Load Balancer**: Native OCI integration vs AWS Load Balancer Controller
- **Storage**: Built-in Block Volume CSI vs separate EBS CSI driver  
- **IAM**: OCI Policies and Dynamic Groups vs AWS IAM roles
- **Networking**: VCN Security Lists vs AWS Security Groups
- **Authentication**: OCI CLI token vs AWS CLI token