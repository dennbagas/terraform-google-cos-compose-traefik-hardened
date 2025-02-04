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

  traefik_env_file    = "traefik/.env"
  traefik_config_file = "traefik/traefik.yaml"

  docker_compose_file = "docker-compose.yaml"

  additional_files = [
    {
      file        = "composer/.env"
      target_path = "postgres/.env", # -> will be in composer home dir: /home/composer/postgres/.env
    },
    {
      file              = "composer/init/init-db.sh"
      target_path       = "postgres/init/init-db.sh", # -> will be in composer home dir: /home/composer/postgres/init/init-db.sh
      target_permission = 500,
      target_owner      = "chronos-access" # user with uid 1001 in cos-os
    },
  ]
  additional_runcmd_file = "additional_runcmd.yaml"
}
