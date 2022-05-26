#module "gitops_cp_foundation" {
#  source = "github.com/cloud-native-toolkit/terraform-gitops-cp-foundational-services.git"
#
#  depends_on = [
#    module.gitops_ibm_catalogs
#  ]
#
#  gitops_config = module.gitops.gitops_config
#  git_credentials = module.gitops.git_credentials
#  server_name = module.gitops.server_name
#  namespace = module.gitops_cs_namespace.name
#  kubeseal_cert = module.gitops.sealed_secrets_cert
#}
