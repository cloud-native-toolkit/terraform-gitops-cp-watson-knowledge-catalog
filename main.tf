locals {
  name          = "terraform-gitops-cp-watson-knowledge-catalog"
  prerequisites_name = "ibm-cpd-wkc-prereqs"
  prerequisites_chart_dir = "${path.module}/charts/${local.prerequisites_name}"
  prerequisites_yaml_dir      = "${path.cwd}/.tmp/${local.name}/chart/${local.prerequisites_name}"
  subscription_name = "ibm-cpd-wkc-subscription"
  subscription_chart_dir = "${path.module}/charts/${local.subscription_name}"
  subscription_yaml_dir      = "${path.cwd}/.tmp/${local.name}/chart/${local.subscription_name}"
  instance_name = "ibm-cpd-wkc-instance"
  instance_chart_dir = "${path.module}/charts/${local.instance_name}"
  instance_yaml_dir      = "${path.cwd}/.tmp/${local.name}/chart/${local.instance_name}"
  service_url   = "http://${local.name}.${var.namespace}"

  subscription_content = {
    name = "ibm-cpd-wkc-subscription"
    operator_namespace = var.namespace
    syncwave = "-5"
    channel = "v1.0"
    installPlan = "Automatic"
  }

  instance_content = {
    cpd_namespace = "cpd-instance"
    name = "wkc-cr"
    version = "4.0.5"
    license = "Enterprise"
    storageVendor = "Portworx"
    wkc_set_kernel_params = "True"
    iis_set_kernel_params = "True"
  }

  layer = "services"
  type  = "operators"
  application_branch = "main"
  namespace = var.namespace
  layer_config = var.gitops_config[local.layer]
}

module setup_clis {
  source = "github.com/cloud-native-toolkit/terraform-util-clis.git"
}

resource null_resource create_prerequisites_yaml {

  triggers = {
    name = local.prerequisites_name
    chart_dir = local.prerequisites_chart_dir
    yaml_dir = local.prerequisites_yaml_dir
  }
  provisioner "local-exec" {
    command = "${path.module}/scripts/create-yaml.sh '${self.triggers.name}' '${self.triggers.chart_dir}' '${self.triggers.yaml_dir}'"

    environment = {
      VALUES_CONTENT = yamlencode(local.subscription_content)
    }
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

resource null_resource create_operator_yaml {

  triggers = {
    name = local.subscription_name
    chart_dir = local.subscription_chart_dir
    yaml_dir = local.subscription_yaml_dir
  }
  provisioner "local-exec" {
    command = "${path.module}/scripts/create-yaml.sh '${self.triggers.name}' '${self.triggers.chart_dir}' '${self.triggers.yaml_dir}'"

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

resource null_resource create_instance_yaml {

  triggers = {
    name = local.instance_name
    chart_dir = local.instance_chart_dir
    yaml_dir = local.instance_yaml_dir
  }
  provisioner "local-exec" {
    command = "${path.module}/scripts/create-yaml.sh '${self.triggers.name}' '${self.triggers.chart_dir}' '${self.triggers.yaml_dir}'"

    environment = {
      VALUES_CONTENT = yamlencode(local.instance_content)
    }
  }
}

resource null_resource setup_instance_gitops {
  depends_on = [null_resource.create_instance_yaml]

  triggers = {
    name = local.instance_name
    namespace = var.namespace
    yaml_dir = local.instance_chart_dir
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

module "gitops_sccs" {
  source = "github.com/cloud-native-toolkit/terraform-gitops-sccs.git"

  depends_on = [null_resource.setup_instance_gitops]

  gitops_config = var.gitops_config
  git_credentials = var.git_credentials
  namespace = var.namespace
  service_account = var.service_account_name
  sccs = var.sccs
  server_name = var.server_name
  group = var.scc_group
}

module "gitops_rbac" {
  source = "github.com/cloud-native-toolkit/terraform-gitops-rbac.git"
  depends_on = [null_resource.gitops_sccs]

  gitops_config             = var.gitops_config
  git_credentials           = var.git_credentials
  service_account_namespace = var.cpd_namespace
  service_account_name      = var.service_account_name
  namespace                 = var.cpd_namespace
  label                     = var.rbac_label
  rules                     = var.rbac_rules
  server_name               = var.server_name
  cluster_scope             = var.rbac_cluster_scope
}