variable "vpc_name" {
  type        = string
  default     = "default"
  description = "The VPC name or self_link of the network to attach this interface to"
}

variable "subnetwork_name" {
  type        = string
  default     = "default"
  description = "Self link of the VPC subnet to use for the internal interface."
}

variable "network_tags" {
  type    = list(string)
  default = []
  description = "A list of network tags to attach to the instance."
}

variable "machine_type" {
  type        = string
  default     = "e2-micro"
  description = "Instance machine type."
}

variable "machine_name" {
  type        = string
  description = "A unique name for the resource, required by GCE. Changing this forces a new resource to be created."
}

variable "allow_stopping_for_update" {
  type        = string
  default     = true
  description = "Allow stopping the instance for specific Terraform changes."
}

variable "disk_size" {
  type        = number
  default     = 20
  description = "The size of the image in gigabytes."
}

variable "disk_type" {
  type        = string
  default     = "pd-standard"
  description = "The GCE disk type. Such as pd-standard, pd-balanced or pd-ssd."
}

variable "disk_auto_delete" {
  type        = string
  default     = true
  description = "Whether the disk will be auto-deleted when the instance is deleted. Defaults to true."
}

variable "ssh_user" {
  type        = string
  description = "SSH user that can connect to VM."
}

variable "ssh_pub_key_file" {
  type        = string
  sensitive   = true
  description = "Public SSH key that can connect to VM."
}

variable "traefik_env_file" {
  type        = string
  default     = ""
  description = "Traefik Environment Variable file."
}

variable "traefik_config_file" {
  type        = string
  default     = ""
  description = "Custom Traefik configuration file."
}

variable "docker_compose_file" {
  type        = string
  description = "Main application is in this Docker Compose file."
}

variable "additional_files" {
  type = list(object({
    file              = string
    target_path       = string
    target_permission = optional(number, 644)
    target_owner      = optional(string, "composer")
  }))
  default     = []
  description = "Additional files can be application configuration or secret that is needed by Docker Compose file. Target path will prefixed by /home/composer/."
}

variable "additional_runcmd_file" {
  type        = string
  default     = ""
  description = "List of bash based command that run in series. Only run on the first boot."
}
