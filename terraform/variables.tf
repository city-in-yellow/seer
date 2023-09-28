# host/ssh
variable "host" {
  type = string
}

variable "port" {
  type = string
}

variable "private_ssh_key_location" {
  type = string
}

# terraform backend
variable "tf_backend_password" {
  type = string
}

variable "tf_backend_port" {
  type = number
}
