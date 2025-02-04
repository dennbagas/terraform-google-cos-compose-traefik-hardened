data "template_file" "cloud-init" {
  template = file("${path.module}/assets/cloud-init.yaml")

  vars = {
    traefik_env       = var.traefik_env_file != "" ? file(var.traefik_env_file) : ""
    traefik_config    = var.traefik_config_file != "" ? file(var.traefik_config_file) : file("${path.module}/assets/traefik-default.yaml")
    additional_runcmd = var.additional_runcmd_file != "" ? file(var.additional_runcmd_file) : ""
    additional_files = templatefile(
      "${path.module}/assets/cloud-init-files.tmpl",
      { additional_files = var.additional_files }
    )
    docker_config  = file("${path.module}/assets/docker-config.json")
    docker_compose = file(var.docker_compose_file)
  }
}

data "google_compute_image" "cos" {
  # Use dev version as it is the cos release that have Docker v25
  # This module need Docker v25 because traefik needs to attach multiple network at docker run
  # That capability comes in Docker v25
  # TODO: this must be updated to stable once the stable version include Docker v25
  name    = "cos-dev-121-18849-0-0"
  project = "cos-cloud"
}

resource "google_compute_instance" "cos_instance" {
  name                      = var.machine_name
  machine_type              = var.machine_type
  tags                      = var.network_tags
  allow_stopping_for_update = true

  boot_disk {
    auto_delete = var.disk_auto_delete
    device_name = "${var.machine_name}-disk"
    initialize_params {
      image = data.google_compute_image.cos.self_link
      size  = var.disk_size
      type  = var.disk_type
    }
  }

  network_interface {
    network    = var.vpc_name
    subnetwork = var.subnetwork_name
    access_config {}
  }

  service_account {
    scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write",
      "https://www.googleapis.com/auth/pubsub",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/trace.append",
    ]
  }

  metadata = {
    block-project-ssh-keys = true
    user-data              = data.template_file.cloud-init.rendered
    ssh-keys               = "${var.ssh_user}:${file(var.ssh_pub_key_file)}"
  }

  scheduling {
    automatic_restart   = "true"
    on_host_maintenance = "MIGRATE"
    preemptible         = "false"
  }
}
