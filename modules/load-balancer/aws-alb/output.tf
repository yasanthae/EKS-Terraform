output "lb_role_arn" {
  description = "ARN of the AWS Load Balancer Controller IAM role"
  value       = module.lb_role.iam_role_arn
}

output "controller_status" {
  description = "Status of the AWS Load Balancer Controller"
  value       = helm_release.alb_controller.status
}

output "controller_namespace" {
  description = "Namespace where the controller is deployed"
  value       = helm_release.alb_controller.namespace
}

output "controller_version" {
  description = "Version of the AWS Load Balancer Controller"
  value       = helm_release.alb_controller.version
}