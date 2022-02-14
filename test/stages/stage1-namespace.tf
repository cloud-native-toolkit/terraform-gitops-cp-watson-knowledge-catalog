module "gitops_namespace" {
  source = "github.com/cloud-native-toolkit/terraform-gitops-namespace.git"

  gitops_config = module.gitops.gitops_config
  git_credentials = module.gitops.git_credentials
  name = var.namespace
}

module "gitops_cs_namespace" {
  depends_on = [
    module.gitops_namespace
  ]
  source = "github.com/cloud-native-toolkit/terraform-gitops-namespace.git"

  gitops_config = module.gitops.gitops_config
  git_credentials = module.gitops.git_credentials
  name = var.cpd_common_services_namespace
  create_operator_group = false
}

module "gitops_cpd_operator_namespace" {
  depends_on = [
    module.gitops_cs_namespace
  ]
  source = "github.com/cloud-native-toolkit/terraform-gitops-namespace.git"

  gitops_config = module.gitops.gitops_config
  git_credentials = module.gitops.git_credentials
  name = var.cpd_operator_namespace
  create_operator_group = true
}

resource null_resource write_namespace {
  provisioner "local-exec" {
    command = "echo -n '${module.gitops_namespace.name}' > .namespace"
  }

  provisioner "local-exec" {
    command = "echo -n '${module.gitops_cs_namespace.name}' > .cs_namespace"
  }

  provisioner "local-exec" {
    command = "echo -n '${module.gitops_cpd_operator_namespace.name}' > .operator_namespace"
  }
}

module cs_pull_secret {
  depends_on = [
    module.gitops_cpd_operator_namespace
  ]
  source = "github.com/cloud-native-toolkit/terraform-gitops-pull-secret"

  gitops_config = module.gitops.gitops_config
  git_credentials = module.gitops.git_credentials
  server_name = module.gitops.server_name
  kubeseal_cert = module.gitops.sealed_secrets_cert
  namespace = var.cpd_common_services_namespace
  docker_username = "cp"
  docker_password = var.entitlement_key
  docker_server   = "cp.icr.io"
  secret_name     = "ibm-entitlement-key"
}

module cpd_pull_secret {
  depends_on = [
    module.cs_pull_secret
  ]
  source = "github.com/cloud-native-toolkit/terraform-gitops-pull-secret"

  gitops_config = module.gitops.gitops_config
  git_credentials = module.gitops.git_credentials
  server_name = module.gitops.server_name
  kubeseal_cert = module.gitops.sealed_secrets_cert
  namespace = var.cpd_operator_namespace
  docker_username = "cp"
  docker_password = var.entitlement_key
  docker_server   = "cp.icr.io"
  secret_name     = "ibm-entitlement-key"
}

