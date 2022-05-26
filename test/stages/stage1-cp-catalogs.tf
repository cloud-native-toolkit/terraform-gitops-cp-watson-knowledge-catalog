#module "gitops_ibm_catalogs" {
#  depends_on = [
#    module.gitops_cpd_operator_namespace
#  ]
#  
#  source = "github.com/cloud-native-toolkit/terraform-gitops-cp-catalogs.git"
#
#  gitops_config = module.gitops.gitops_config
#  git_credentials = module.gitops.git_credentials
#  server_name = module.gitops.server_name
#  kubeseal_cert = module.gitops.sealed_secrets_cert
#  entitlement_key = var.entitlement_key
#}
