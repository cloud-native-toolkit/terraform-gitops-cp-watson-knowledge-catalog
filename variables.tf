
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

variable "cluster_ingress_hostname" {
  type        = string
  description = "Ingress hostname of the IKS cluster."
  default     = ""
}

variable "operator_namespace" {
  type        = string
  description = "operator namespace"
  default     = "cpd-operators"
}

variable "cpd_namespace" {
  type        = string
  description = "cpd namespace"
  default     = "gitops-cp4d-instance"
}

variable "scc_group" {
  type        = list(string)
  description = "The list of sccs that should be generated for the service account (valid values are anyuid and privileged)"
  default     = ["anyuid"]
}

variable "rbac_label" {
  type        = string
  description = "The name for RBAC rule"
  default     = "wkc-iis-scc-rb"
}

variable "rbac_rules" {
  type        = list(object({
    apiGroups = list(string)
    resources = list(string)
    resourceNames = optional(list(string))
    verbs     = list(string)
  }))
  description = "Rules for rbac rules"
  default     = [{
    apiGroups = ["security.openshift.io"]
    resources = ["securitycontextconstraints"]
    resourceNames = ["wkc-iis-scc"]
    verbs = ["use"]
  }]
}

variable "rbac_cluster_scope" {
  type        = bool
  description = "Flag indicating that RBAC should be created as ClusterRole and ClusterRoleBinding instead of Role and RoleBinding"
  default     = true
}

variable "service_account_name" {
  type        = string
  description = "The name of the service account for wkc"
  default     = "wkc-iis-sa"
}

