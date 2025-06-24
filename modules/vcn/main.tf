################################################################################
# Availability Domains Data Source
################################################################################

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_ocid
}

################################################################################
# VCN
################################################################################

resource "oci_core_vcn" "oke_vcn" {
  compartment_id = var.compartment_ocid
  display_name   = "${var.environment}-oke-vcn"
  cidr_blocks    = ["10.0.0.0/16"]
  dns_label      = "okevcn"

  freeform_tags = {
    "Environment" = var.environment
    "CreatedBy"   = "Terraform"
  }
}

################################################################################
# Internet Gateway
################################################################################

resource "oci_core_internet_gateway" "oke_ig" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.oke_vcn.id
  display_name   = "${var.environment}-oke-internet-gateway"
  enabled        = true
}

################################################################################
# NAT Gateway
################################################################################

resource "oci_core_nat_gateway" "oke_nat_gateway" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.oke_vcn.id
  display_name   = "${var.environment}-oke-nat-gateway"
}

################################################################################
# Service Gateway
################################################################################

data "oci_core_services" "oci_services" {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}

resource "oci_core_service_gateway" "oke_sg" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.oke_vcn.id
  display_name   = "${var.environment}-oke-service-gateway"
  
  services {
    service_id = data.oci_core_services.oci_services.services[0]["id"]
  }
}

################################################################################
# Route Tables
################################################################################

# Public Route Table
resource "oci_core_route_table" "oke_rt_public" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.oke_vcn.id
  display_name   = "${var.environment}-oke-rt-public"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.oke_ig.id
  }
}

# Private Route Table
resource "oci_core_route_table" "oke_rt_private" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.oke_vcn.id
  display_name   = "${var.environment}-oke-rt-private"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.oke_nat_gateway.id
  }

  route_rules {
    destination       = data.oci_core_services.oci_services.services[0]["cidr_block"]
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.oke_sg.id
  }
}

################################################################################
# Security Lists
################################################################################

# Public Security List
resource "oci_core_security_list" "oke_sl_public" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.oke_vcn.id
  display_name   = "${var.environment}-oke-sl-public"

  # Egress Rules
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  # Ingress Rules
  ingress_security_rules {
    protocol = "6" # TCP
    source   = "0.0.0.0/0"
    tcp_options {
      min = 80
      max = 80
    }
  }

  ingress_security_rules {
    protocol = "6" # TCP
    source   = "0.0.0.0/0"
    tcp_options {
      min = 443
      max = 443
    }
  }

  ingress_security_rules {
    protocol = "6" # TCP
    source   = "10.0.0.0/16"
    tcp_options {
      min = 6443
      max = 6443
    }
  }
}

# Private Security List
resource "oci_core_security_list" "oke_sl_private" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.oke_vcn.id
  display_name   = "${var.environment}-oke-sl-private"

  # Egress Rules
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  # Ingress Rules - Allow all traffic within VCN
  ingress_security_rules {
    protocol = "all"
    source   = "10.0.0.0/16"
  }
}

################################################################################
# Public Subnets
################################################################################

resource "oci_core_subnet" "oke_public_subnet" {
  count                      = 3
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.oke_vcn.id
  cidr_block                 = "10.0.${101 + count.index}.0/24"
  display_name               = "${var.environment}-oke-public-subnet-${count.index + 1}"
  dns_label                  = "okepublic${count.index + 1}"
  availability_domain        = data.oci_identity_availability_domains.ads.availability_domains[count.index % length(data.oci_identity_availability_domains.ads.availability_domains)].name
  route_table_id             = oci_core_route_table.oke_rt_public.id
  security_list_ids          = [oci_core_security_list.oke_sl_public.id]
  prohibit_public_ip_on_vnic = false

  freeform_tags = {
    "Environment" = var.environment
    "Type"        = "public"
    "kubernetes.io/role/elb" = "1"
  }
}

################################################################################
# Private Subnets
################################################################################

resource "oci_core_subnet" "oke_private_subnet" {
  count                      = 3
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.oke_vcn.id
  cidr_block                 = "10.0.${1 + count.index}.0/24"
  display_name               = "${var.environment}-oke-private-subnet-${count.index + 1}"
  dns_label                  = "okeprivate${count.index + 1}"
  availability_domain        = data.oci_identity_availability_domains.ads.availability_domains[count.index % length(data.oci_identity_availability_domains.ads.availability_domains)].name
  route_table_id             = oci_core_route_table.oke_rt_private.id
  security_list_ids          = [oci_core_security_list.oke_sl_private.id]
  prohibit_public_ip_on_vnic = true

  freeform_tags = {
    "Environment" = var.environment
    "Type"        = "private"
    "kubernetes.io/role/internal-elb" = "1"
  }
}