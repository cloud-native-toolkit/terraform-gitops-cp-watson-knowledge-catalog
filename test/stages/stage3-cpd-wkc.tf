module "gitops_cp_wkc" {
  source = "./module"

  gitops_config = module.gitops.gitops_config
  git_credentials = module.gitops.git_credentials
  server_name = module.gitops.server_name
  namespace = module.gitops_namespace.name
  kubeseal_cert = module.gitops.sealed_secrets_cert
  #operator_namespace = module.gitops_cp4d_operator.namespace
  #cpd_namespace = module.gitops_cp4d_instance.namespace
  operator_namespace = "cpd-operators"
  cpd_namespace = "gitops-cp4d-instance"

  sccs = var.sccs
  rbac_label = var.rbac_label
  rbac_rules = [{
    apiGroups = ["security.openshift.io"]
    resources = ["securitycontextconstraints"]
    resourceNames = ["gitops-cp4d-instance-wkc-iis-sa-anyuid"]  #"${NAMESPACE}-${SERVICE_ACCOUNT_NAME}-${sccs}"
    verbs = ["use"]}]
  rbac_cluster_scope = var.rbac_cluster_scope
  service_account_name = var.service_account_name
}
