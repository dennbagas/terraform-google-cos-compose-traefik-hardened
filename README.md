# Terraform Google Container Optimized VM with Docker Compose and Hardened Traefik Module

This Terraform module provisions a Google Cloud VM instance running [Container-Optimized OS (COS)](https://cloud.google.com/container-optimized-os/docs), pre-configured with Docker Compose and a hardened Traefik reverse proxy based on [traefik-hardened](https://github.com/wollomatic/traefik-hardened) repo. This module simplifies the deployment of containerized applications on Google Cloud Platform while implementing security best practices.

## Usage

Basic usage of this module is as follows:

```hcl
provider "google" {
  project     = "my-project"
  region      = "us-central1"
  zone        = "us-central1-a"
  credentials = "secret/credentials.json"
}

module "cos_module" {
  source = "dennbagas/cos-compose-traefik-hardened/google"

  machine_name     = "my-server"
  machine_type     = "e2-micro"
  network_tags     = ["allow-http", "allow-ssh"]
  disk_auto_delete = "true"
  disk_size        = 25
  disk_type        = "pd-standard"

  ssh_user         = "my-user"
  ssh_pub_key_file = "secret/my-key.pub"

  docker_compose_file = "docker-compose.yaml"
}
```

The services in docker-compose.yaml must use network `traefik-servicenet` to be exposed by traefik. For example:

```yaml
services:
  my-services:
    image: my-image:latest
    ...
    networks:
      - traefik-servicenet

  ...

networks:
  traefik-servicenet:
    external: true
    name: traefik-servicenet
```

Functional examples are included in the [examples](./examples/) directory.

## Inputs

| Name                                                                                                         | Description                                                                                                                                     | Type                                                                                                                                                                           | Default         | Required |
| ------------------------------------------------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | --------------- | :------: |
| <a name="input_additional_files"></a> [additional_files](#input_additional_files)                            | Additional files can be application configuration or secret that is needed by Docker Compose file. Target path will prefixed by /home/composer/. | <pre>list(object({<br/> file = string<br/> target_path = string<br/> target_permission = optional(number, 644)<br/> target_owner = optional(string, "composer")<br/> }))</pre> | `[]`            |    no    |
| <a name="input_additional_runcmd_file"></a> [additional_runcmd_file](#input_additional_runcmd_file)          | List of bash based command that run in series. Only run on the first boot.                                                                      | `string`                                                                                                                                                                       | `""`            |    no    |
| <a name="input_allow_stopping_for_update"></a> [allow_stopping_for_update](#input_allow_stopping_for_update) | Allow stopping the instance for specific Terraform changes.                                                                                     | `string`                                                                                                                                                                       | `true`          |    no    |
| <a name="input_disk_auto_delete"></a> [disk_auto_delete](#input_disk_auto_delete)                            | Whether the disk will be auto-deleted when the instance is deleted. Defaults to true.                                                           | `string`                                                                                                                                                                       | `true`          |    no    |
| <a name="input_disk_size"></a> [disk_size](#input_disk_size)                                                 | The size of the image in gigabytes.                                                                                                             | `number`                                                                                                                                                                       | `20`            |    no    |
| <a name="input_disk_type"></a> [disk_type](#input_disk_type)                                                 | The GCE disk type. Such as pd-standard, pd-balanced or pd-ssd.                                                                                  | `string`                                                                                                                                                                       | `"pd-standard"` |    no    |
| <a name="input_docker_compose_file"></a> [docker_compose_file](#input_docker_compose_file)                   | Main application is in this Docker Compose file.                                                                                                | `string`                                                                                                                                                                       | n/a             |   yes    |
| <a name="input_machine_name"></a> [machine_name](#input_machine_name)                                        | A unique name for the resource, required by GCE. Changing this forces a new resource to be created.                                             | `string`                                                                                                                                                                       | n/a             |   yes    |
| <a name="input_machine_type"></a> [machine_type](#input_machine_type)                                        | Instance machine type.                                                                                                                          | `string`                                                                                                                                                                       | `"e2-micro"`    |    no    |
| <a name="input_network_tags"></a> [network_tags](#input_network_tags)                                        | A list of network tags to attach to the instance.                                                                                               | `list(string)`                                                                                                                                                                 | `[]`            |    no    |
| <a name="input_ssh_pub_key_file"></a> [ssh_pub_key_file](#input_ssh_pub_key_file)                            | Public SSH key that can connect to VM.                                                                                                          | `string`                                                                                                                                                                       | n/a             |   yes    |
| <a name="input_ssh_user"></a> [ssh_user](#input_ssh_user)                                                    | SSH user that can connect to VM.                                                                                                                | `string`                                                                                                                                                                       | n/a             |   yes    |
| <a name="input_subnetwork_name"></a> [subnetwork_name](#input_subnetwork_name)                               | Self link of the VPC subnet to use for the internal interface.                                                                                  | `string`                                                                                                                                                                       | `"default"`     |    no    |
| <a name="input_traefik_config_file"></a> [traefik_config_file](#input_traefik_config_file)                   | Custom Traefik configuration file.                                                                                                              | `string`                                                                                                                                                                       | `""`            |    no    |
| <a name="input_traefik_env_file"></a> [traefik_env_file](#input_traefik_env_file)                            | Traefik Environment Variable file.                                                                                                              | `string`                                                                                                                                                                       | `""`            |    no    |
| <a name="input_vpc_name"></a> [vpc_name](#input_vpc_name)                                                    | The VPC name or self_link of the network to attach this interface to                                                                            | `string`                                                                                                                                                                       | `"default"`     |    no    |

## Outputs

| Name                                                                    | Description  |
| ----------------------------------------------------------------------- | ------------ |
| <a name="output_vm_public_ip"></a> [vm_public_ip](#output_vm_public_ip) | VM Public IP |

## Resources

| Name                                                                                                                                    | Type        |
| --------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [google_compute_instance.cos_instance](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | resource    |
| [google_compute_image.cos](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_image)             | data source |
| [template_file.cloud-init](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file)                    | data source |

## Requirements

These sections describe requirements for using this module.

### Requirements

| Name                                                                     | Version      |
| ------------------------------------------------------------------------ | ------------ |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 0.13      |
| <a name="requirement_google"></a> [google](#requirement_google)          | >= 3.53, < 7 |
| <a name="requirement_template"></a> [template](#requirement_template)    | >= 2.1.0     |

### Providers

| Name                                                            | Version      |
| --------------------------------------------------------------- | ------------ |
| <a name="provider_google"></a> [google](#provider_google)       | >= 3.53, < 7 |
| <a name="provider_template"></a> [template](#provider_template) | >= 2.1.0     |

### Enable API's

In order to operate with the Service Account you must activate the following APIs on the project where the Service Account was created:

- Compute Engine API - compute.googleapis.com
