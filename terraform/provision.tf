resource "null_resource" "provision_server" {
  triggers = {
    host = var.host
    user = local.user
  }

  connection {
    type        = "ssh"
    user        = local.user
    host        = var.host
    port        = var.port
    private_key = local.private_ssh_key
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p ${local.storage_path}"
    ]
  }
}
