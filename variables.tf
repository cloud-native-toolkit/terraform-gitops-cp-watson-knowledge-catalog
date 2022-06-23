
variable "gitops_config" {
  type        = object({
    boostrap = object({
      argocd-config = object({
        project = string
        repo = string
        url = string
        path = string
      })
    })
    infrastructure = object({
      argocd-config = object({
        project = string
        repo = string
        url = string
        path = string
      })
      payload = object({
        repo = string
        url = string
        path = string
      })
    })
    services = object({
      argocd-config = object({
        project = string
        repo = string
        url = string
        path = string
      })
      payload = object({
        repo = string
        url = string
        path = string
      })
    })
    applications = object({
      argocd-config = object({
        project = string
        repo = string
        url = string
        path = string
      })
      payload = object({
        repo = string
        url = string
        path = string
      })
    })
  })
  description = "Config information regarding the gitops repo structure"
}

variable "git_credentials" {
  type = list(object({
    repo = string
    url = string
    username = string
    token = string
  }))
  description = "The credentials for the gitops repo(s)"
  sensitive   = true
}

variable "namespace" {
  type        = string
  description = "The namespace where the application should be deployed"
}

variable "kubeseal_cert" {
  type        = string
  description = "The certificate/public key used to encrypt the sealed secrets"
  default     = ""
}

variable "server_name" {
  type        = string
  description = "The name of the server"
  default     = "default"
}

variable "operator_namespace" {
  type        = string
  description = "operator namespace"
  default     = "cpd-operators"
}

variable "cpd_namespace" {
  type        = string
  description = "cpd namespace"
  default     = "cp4d"
}

variable "operator_channel" {
  type        = string
  description = "operator channel"
  default     = "v1.0"
}

variable "instance_version" {
  type        = string
  description = "Instance version"
  default     = "4.0.9"
}

variable "license" {
  type        = string
  description = "License type"
  default     = "Enterprise"
}

variable "storage_class" {
  type        = string
  description = "Storage class for the instance"
  default     = "portworx-shared-gp3"
}

variable "storage_vendor" {
  type        = string
  description = "Storage vendor for the instance"
  default     = "portworx"
}

variable "install_plan" {
  type        = string
  description = "install plan"
  default     = "Automatic"
}

variable "wkc_set_kernel_params" {
  type        = string
  description = "WKC Set Kernel Parameters"
  default     = "True"
}

variable "iis_set_kernel_params" {
  type        = string
  description = "IIS Set Kernel Parameters"
  default     = "True"
}

variable "sub_syncwave" {
  type        = string
  description = "Sync Wave"
  default     = "-5"
}

variable "inst_syncwave" {
  type        = string
  description = "Sync Wave"
  default     = "-3"
}