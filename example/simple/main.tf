provider "google" {
  project     = "my-project"
  region      = "us-central1"
  zone        = "us-central1-a"
  credentials = "secret/credentials.json"
}

module "cos_module" {
  source = "dennbagas/terraform-google-cos-compose-traefik-hardened"

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
