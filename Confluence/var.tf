variable "mac_addr" {
    type = string
    default = "00:50:56:01:01:01"
}

variable "id" {
    type = string
    default = "10"
}

variable "ssh_user" {
    type = string
    default = "root"
}

variable "ssh_pwd" {
    type = string
    default = "root"
}

variable "ssh_host" {
    type = string
    default = "10.10.10.201"
}

variable "ssh_key" {
  type = string
    default = "/home/blk/.ssh/id_rsa"
}

variable "ssh_pubkey" {
    type = string
    default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDPtzo6XlTVmINt39+Nxzx7q2b8V38C88+eInfuVCkVDYGROCCSs5t7OefVrI0kzmN56g7qJ+llz6v/lSt8MBBviwrPs5asofGe/I3xdRPT70ZdpzniiRTOSbD77U7MoFbSU/Wi7QdYl15Nk89DmmS6tAfzuYGM5NkRZpfTO9PE9E3A/YWQvDBs8rNG/9RIKRoAnr/0vTbWxJiQRXLui+4jYEMSImF9ny1PMxJNHdYyMRjOc3T9dxEg9GESPiRuJdyXDKbPGpyL/h8agIqTaojFxFQmAJpokOZ4QnAmeGvMrz5Bl3fbzu7ySxMs3KP9jXuXynqxe9IgKcY8yEzW3G3j blk@Voyager"
}

variable "hostname" {
    type = string
    default = "PRD-CFL-LX"
}

variable "new_user" {
    type = string
    default = "cfl"
}

variable "new_user_pwd" {
    type = string
    default = "cfl"
}

variable "time_to_wait" {
    type = string
    default = "10"
}