#module "gitops_cp4d_instance" {
#  source = "github.com/cloud-native-toolkit/terraform-gitops-cp4d-instance.git"
#
#  depends_on = [
#    module.gitops_cp4d_operator
#  ]
#
#  gitops_config = module.gitops.gitops_config
#  git_credentials = module.gitops.git_credentials
#  server_name = module.gitops.server_name
#  namespace = module.gitops_namespace.name
#  cpd_operator_namespace = module.gitops_cpd_operator_namespace.name
#  kubeseal_cert = module.gitops.sealed_secrets_cert
#  entitlement_key = var.cp_entitlement_key
#}
