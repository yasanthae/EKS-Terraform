################################################################################
# OCI Load Balancer
################################################################################

resource "oci_load_balancer_load_balancer" "oke_lb" {
  compartment_id = var.compartment_ocid
  display_name   = "${var.environment}-oke-loadbalancer"
  shape          = "flexible"
  subnet_ids     = var.public_subnet_ids

  shape_details {
    maximum_bandwidth_in_mbps = 100
    minimum_bandwidth_in_mbps = 10
  }

  is_private = false

  freeform_tags = {
    "Environment" = var.environment
    "CreatedBy"   = "Terraform"
    "Purpose"     = "OKE-LoadBalancer"
  }
}

################################################################################
# Backend Set for HTTP Traffic
################################################################################

resource "oci_load_balancer_backend_set" "oke_backend_set_http" {
  name             = "oke-backend-set-http"
  load_balancer_id = oci_load_balancer_load_balancer.oke_lb.id
  policy           = "ROUND_ROBIN"

  health_checker {
    port                = "80"
    protocol            = "HTTP"
    response_body_regex = ".*"
    url_path            = "/healthz"
    return_code         = 200
    interval_ms         = 10000
    timeout_in_millis   = 3000
    retries             = 3
  }
}

################################################################################
# Backend Set for HTTPS Traffic
################################################################################

resource "oci_load_balancer_backend_set" "oke_backend_set_https" {
  name             = "oke-backend-set-https"
  load_balancer_id = oci_load_balancer_load_balancer.oke_lb.id
  policy           = "ROUND_ROBIN"

  health_checker {
    port                = "443"
    protocol            = "HTTP"
    response_body_regex = ".*"
    url_path            = "/healthz"
    return_code         = 200
    interval_ms         = 10000
    timeout_in_millis   = 3000
    retries             = 3
  }
}

################################################################################
# HTTP Listener
################################################################################

resource "oci_load_balancer_listener" "oke_listener_http" {
  load_balancer_id         = oci_load_balancer_load_balancer.oke_lb.id
  name                     = "oke-listener-http"
  default_backend_set_name = oci_load_balancer_backend_set.oke_backend_set_http.name
  port                     = 80
  protocol                 = "HTTP"

  connection_configuration {
    idle_timeout_in_seconds = 240
  }
}

################################################################################
# HTTPS Listener (placeholder - SSL certificate would be needed)
################################################################################

resource "oci_load_balancer_listener" "oke_listener_https" {
  load_balancer_id         = oci_load_balancer_load_balancer.oke_lb.id
  name                     = "oke-listener-https"
  default_backend_set_name = oci_load_balancer_backend_set.oke_backend_set_https.name
  port                     = 443
  protocol                 = "HTTP"  # Change to HTTPS when SSL certificate is configured

  connection_configuration {
    idle_timeout_in_seconds = 240
  }
}

################################################################################
# Network Security Group for Load Balancer
################################################################################

resource "oci_core_network_security_group" "oke_lb_nsg" {
  compartment_id = var.compartment_ocid
  vcn_id         = var.vcn_id
  display_name   = "${var.environment}-oke-lb-nsg"

  freeform_tags = {
    "Environment" = var.environment
    "CreatedBy"   = "Terraform"
  }
}

################################################################################
# NSG Rules for Load Balancer
################################################################################

# Allow HTTP traffic from internet
resource "oci_core_network_security_group_security_rule" "oke_lb_nsg_rule_http_ingress" {
  network_security_group_id = oci_core_network_security_group.oke_lb_nsg.id
  direction                 = "INGRESS"
  protocol                  = "6"  # TCP
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"

  tcp_options {
    destination_port_range {
      max = 80
      min = 80
    }
  }
}

# Allow HTTPS traffic from internet
resource "oci_core_network_security_group_security_rule" "oke_lb_nsg_rule_https_ingress" {
  network_security_group_id = oci_core_network_security_group.oke_lb_nsg.id
  direction                 = "INGRESS"
  protocol                  = "6"  # TCP
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"

  tcp_options {
    destination_port_range {
      max = 443
      min = 443
    }
  }
}

# Allow all egress traffic
resource "oci_core_network_security_group_security_rule" "oke_lb_nsg_rule_egress" {
  network_security_group_id = oci_core_network_security_group.oke_lb_nsg.id
  direction                 = "EGRESS"
  protocol                  = "all"
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"
}