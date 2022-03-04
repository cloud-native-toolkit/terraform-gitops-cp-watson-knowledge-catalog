locals {
  name          = "ibm-cpd-wkc-instance"
  bin_dir       = module.setup_clis.bin_dir
  prerequisites_name = "ibm-cpd-wkc-prereqs"
  prerequisites_yaml_dir = "${path.cwd}/.tmp/${local.name}/chart/${local.prerequisites_name}"
  subscription_name = "ibm-cpd-wkc-subscription"
  subscription_yaml_dir = "${path.cwd}/.tmp/${local.name}/chart/${local.subscription_name}"
  instance_yaml_dir      = "${path.cwd}/.tmp/${local.name}/chart/${local.name}"
  service_url   = "http://${local.name}.${var.namespace}"

  subscription_content = {
    name = "ibm-cpd-wkc-operator-catalog-subscription"
    operator_namespace = var.operator_namespace
    syncwave = "-5"
    channel = "v1.0"
    installPlan = "Automatic"
  }

  instance_content = {
    cpd_namespace = var.cpd_namespace
    name = "wkc-cr"
    version = "4.0.5"
    license = "Enterprise"
    storageVendor = "portworx"
    wkc_set_kernel_params = "True"
    iis_set_kernel_params = "True"
  }

  layer = "services"
  operator_type  = "operators"
  base_type = "base"
  type = "instances"
  application_branch = "main"
  namespace = var.namespace
  layer_config = var.gitops_config[local.layer]

  lsccs = concat(var.sccs)
  rbac_name = "${var.cpd_namespace}-${var.service_account_name}-${local.lsccs}"
  rbac_rules = [{
    apiGroups = ["security.openshift.io"]
    resources = ["securitycontextconstraints"]
    resourceNames = [local.rbac_name]  #"${NAMESPACE}-${SERVICE_ACCOUNT_NAME}-${sccs}"
    verbs = ["use"]
  }]
}

module setup_clis {
  source = "github.com/cloud-native-toolkit/terraform-util-clis.git"
}

resource null_resource create_prerequisites_yaml {
  provisioner "local-exec" {
    command = "${path.module}/scripts/create-yaml.sh '${local.prerequisites_name}' '${local.prerequisites_yaml_dir}'"
  }
}

resource null_resource setup_prerequisites_gitops {
  depends_on = [null_resource.create_prerequisites_yaml]

  triggers = {
    name = local.prerequisites_name
    namespace = var.namespace
    yaml_dir = local.prerequisites_yaml_dir
    server_name = var.server_name
    layer = local.layer
    type = local.base_type
    git_credentials = yamlencode(var.git_credentials)
    gitops_config   = yamlencode(var.gitops_config)
    bin_dir = local.bin_dir
  }

  provisioner "local-exec" {
    command = "${self.triggers.bin_dir}/igc gitops-module '${self.triggers.name}' -n '${self.triggers.namespace}' --contentDir '${self.triggers.yaml_dir}' --serverName '${self.triggers.server_name}' -l '${self.triggers.layer}'"

    environment = {
      GIT_CREDENTIALS = nonsensitive(self.triggers.git_credentials)
      GITOPS_CONFIG   = self.triggers.gitops_config
    }
  }

  provisioner "local-exec" {
    when = destroy
    command = "${self.triggers.bin_dir}/igc gitops-module '${self.triggers.name}' -n '${self.triggers.namespace}' --delete --contentDir '${self.triggers.yaml_dir}' --serverName '${self.triggers.server_name}' -l '${self.triggers.layer}'"

    environment = {
      GIT_CREDENTIALS = nonsensitive(self.triggers.git_credentials)
      GITOPS_CONFIG   = self.triggers.gitops_config
    }
  }
}

module "gitops_sccs" {
  source = "github.com/cloud-native-toolkit/terraform-gitops-sccs.git?ref=v1.2.3"

  depends_on = [null_resource.setup_prerequisites_gitops]

  gitops_config = var.gitops_config
  git_credentials = var.git_credentials
  namespace = var.cpd_namespace
  service_account = var.service_account_name
  sccs = var.sccs
  server_name = var.server_name
}

module "gitops_rbac" {
  source = "github.com/cloud-native-toolkit/terraform-gitops-rbac.git?ref=v1.7.1"

  depends_on = [null_resource.setup_prerequisites_gitops]

  gitops_config             = var.gitops_config
  git_credentials           = var.git_credentials
  service_account_namespace = var.cpd_namespace
  service_account_name      = var.service_account_name
  namespace                 = var.cpd_namespace
  label                     = var.rbac_label
  rules                     = local.rbac_rules
  server_name               = var.server_name
  cluster_scope             = var.rbac_cluster_scope
}

resource null_resource create_operator_yaml {
  depends_on = [null_resource.setup_prerequisites_gitops]

  provisioner "local-exec" {
    command = "${path.module}/scripts/create-yaml.sh '${local.subscription_name}' '${local.subscription_yaml_dir}'"

    environment = {
      VALUES_CONTENT = yamlencode(local.subscription_content)
    }
  }
}

resource null_resource setup_operator_gitops {
  depends_on = [null_resource.create_operator_yaml]

  triggers = {
    name = local.subscription_name
    namespace = var.namespace
    yaml_dir = local.subscription_yaml_dir
    server_name = var.server_name
    layer = local.layer
    type = local.operator_type
    git_credentials = yamlencode(var.git_credentials)
    gitops_config   = yamlencode(var.gitops_config)
    bin_dir = local.bin_dir
  }

  provisioner "local-exec" {
    command = "${self.triggers.bin_dir}/igc gitops-module '${self.triggers.name}' -n '${self.triggers.namespace}' --contentDir '${self.triggers.yaml_dir}' --serverName '${self.triggers.server_name}' -l '${self.triggers.layer}' --type '${self.triggers.type}'"

    environment = {
      GIT_CREDENTIALS = nonsensitive(self.triggers.git_credentials)
      GITOPS_CONFIG   = self.triggers.gitops_config
    }
  }

  provisioner "local-exec" {
    when = destroy
    command = "${self.triggers.bin_dir}/igc gitops-module '${self.triggers.name}' -n '${self.triggers.namespace}' --delete --contentDir '${self.triggers.yaml_dir}' --serverName '${self.triggers.server_name}' -l '${self.triggers.layer}' --type '${self.triggers.type}'"

    environment = {
      GIT_CREDENTIALS = nonsensitive(self.triggers.git_credentials)
      GITOPS_CONFIG   = self.triggers.gitops_config
    }
  }
}

resource null_resource create_instance_yaml {
  depends_on = [null_resource.setup_prerequisites_gitops]

  provisioner "local-exec" {
    command = "${path.module}/scripts/create-yaml.sh '${local.name}' '${local.instance_yaml_dir}' "

    environment = {
      VALUES_CONTENT = yamlencode(local.instance_content)
    }
  }
}

resource null_resource setup_instance_gitops {
  depends_on = [null_resource.create_instance_yaml]

  triggers = {
    name = local.name
    namespace = var.namespace
    yaml_dir = local.instance_yaml_dir
    server_name = var.server_name
    layer = local.layer
    type = local.type
    git_credentials = yamlencode(var.git_credentials)
    gitops_config   = yamlencode(var.gitops_config)
    bin_dir = local.bin_dir
  }

  provisioner "local-exec" {
    command = "${self.triggers.bin_dir}/igc gitops-module '${self.triggers.name}' -n '${self.triggers.namespace}' --contentDir '${self.triggers.yaml_dir}' --serverName '${self.triggers.server_name}' -l '${self.triggers.layer}' --type '${self.triggers.type}'"

    environment = {
      GIT_CREDENTIALS = nonsensitive(self.triggers.git_credentials)
      GITOPS_CONFIG   = self.triggers.gitops_config
    }
  }

  provisioner "local-exec" {
    when = destroy
    command = "${self.triggers.bin_dir}/igc gitops-module '${self.triggers.name}' -n '${self.triggers.namespace}' --delete --contentDir '${self.triggers.yaml_dir}' --serverName '${self.triggers.server_name}' -l '${self.triggers.layer}' --type '${self.triggers.type}'"

    environment = {
      GIT_CREDENTIALS = nonsensitive(self.triggers.git_credentials)
      GITOPS_CONFIG   = self.triggers.gitops_config
    }
  }
}