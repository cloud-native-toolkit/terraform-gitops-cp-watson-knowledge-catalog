
resource null_resource write_outputs {
  provisioner "local-exec" {
    command = "echo \"$${OUTPUT}\" > gitops-output.json"

    environment = {
      OUTPUT = jsonencode({
        name                = module.gitops_cp_wkc.name
        instance_name       = module.gitops_cp_wkc.instance_name
        sub_chart           = module.gitops_cp_wkc.sub_chart
        sub_name            = module.gitops_cp_wkc.sub_name
        operator_namespace  = module.gitops_cp_wkc.operator_namespace
        cpd_namespace       = module.gitops_cp_wkc.cpd_namespace
        branch              = module.gitops_cp_wkc.branch
        namespace           = module.gitops_cp_wkc.namespace
        server_name         = module.gitops_cp_wkc.server_name
        layer               = module.gitops_cp_wkc.layer
        layer_dir           = module.gitops_cp_wkc.layer == "infrastructure" ? "1-infrastructure" : (module.gitops_cp_wkc.layer == "services" ? "2-services" : "3-applications")
        type                = module.gitops_cp_wkc.type
      })
    }
  }
}
