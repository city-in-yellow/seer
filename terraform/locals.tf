locals {
  # ssh/host
  user            = "jbassin"
  storage_path    = "/home/${local.user}/seer-volumes"
  private_ssh_key = file(var.private_ssh_key_location)
}
