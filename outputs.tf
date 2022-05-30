
output "name" {
  description = "The name of the module"
  value       = local.name
  depends_on  = [null_resource.setup_instance_gitops]
}

output "instance_name" {
  description = "The name of the Watson Knowledge Catalog instance"
  value       = local.instance_content.name
  depends_on  = [null_resource.setup_instance_gitops]
}

output "sub_chart" {
  description = "The name of the Watson Knowledge Catalog chart"
  value       = local.subscription_name
  depends_on  = [null_resource.setup_instance_gitops]
}

output "sub_name" {
  description = "The name of the Watson Knowledge Catalog subscription"
  value       = local.subscription_content.name
  depends_on  = [null_resource.setup_instance_gitops]
}

output "operator_namespace" {
  description = "The name of the operators namespace"
  value       = var.operator_namespace
  depends_on  = [null_resource.setup_instance_gitops]
}

output "cpd_namespace" {
  description = "The name of the Cloud Pak for Data namespace"
  value       = var.cpd_namespace
  depends_on  = [null_resource.setup_instance_gitops]
}

output "branch" {
  description = "The branch where the module config has been placed"
  value       = local.application_branch
  depends_on  = [null_resource.setup_instance_gitops]
}

output "namespace" {
  description = "The namespace where the module will be deployed"
  value       = local.namespace
  depends_on  = [null_resource.setup_instance_gitops]
}

output "server_name" {
  description = "The server where the module will be deployed"
  value       = var.server_name
  depends_on  = [null_resource.setup_instance_gitops]
}

output "layer" {
  description = "The layer where the module is deployed"
  value       = local.layer
  depends_on  = [null_resource.setup_instance_gitops]
}

output "type" {
  description = "The type of module where the module is deployed"
  value       = local.type
  depends_on  = [null_resource.setup_instance_gitops]
}
