terraform {
 required_version = ">= 0.13"
 required_providers {
    esxi = {
      source = "registry.terraform.io/josenk/esxi"
      # https://github.com/josenk/terraform-provider-esxi
      # https://registry.terraform.io/providers/josenk/esxi
  }
 }
}

provider "esxi" {
  #Hostname ou IP
  esxi_hostname      = "10.10.10.200"
  esxi_hostport      = "22"
  #esxi_hostssl       = "443"
  esxi_username      = "root"
  esxi_password      = "YkaNm6DXfc?+" # "@isSimpl0n!"
}

resource "esxi_guest" "Confluence-Deb-01" {
  guest_name    = "Confluence-Deb-01" # Nom de VM
  #id = var.id
  disk_store    = "Prod" # Datastore
  memsize       = "1024" # Ram
  numvcpus      = "1" # Cpu

  #  Specify an existing guest to clone, an ovf source, or neither to build a bare-metal guest vm.
  #
  #clone_from_vm      = "Templates/centos7"
  #URL du fichier ovf
  ovf_source        = "../tpl/Blk-Deb-01-Esx-Cln.ovf"

  network_interfaces {
    virtual_network = "VM Network"
    mac_address = var.mac_addr
    #nic_type = "" #Type de Carte reseau (option avancee !!)
  }

  #Provisionning
  connection {
		type	=	"ssh"
		user	=	var.ssh_user
		host	=	var.ssh_host
    #password = var.ssh_pwd
		private_key = file(var.ssh_key)
   }

    provisioner "remote-exec" {
      inline = [
        "apt install -y sudo",
        "useradd -m ${var.new_user}",
        "echo -e ${var.new_user_pwd}'\\n'${var.new_user_pwd} | passwd ${var.new_user}",
        "usermod -aG sudo ${var.new_user}",
        "echo \"${var.new_user} ALL=(ALL) NOPASSWD: ALL\" | tee /etc/sudoers.d/${var.new_user}",
        "mkdir /home/${var.new_user}/.ssh"
      ]
    }

    #provisioner "file" {
    #  source = "bin/"
    #  destination = "/tmp/"
    #}

    provisioner "remote-exec" {
      inline= [
        "mkdir /home/${var.new_user}/Confluence",
        "echo \"${var.ssh_pubkey}\" >> /home/${var.new_user}/.ssh/authorized_keys",
        "cd /home/${var.new_user}/Confluence",
        "sudo ./atlassian-confluence-7.19.9-x64.bin -q -varfile response.varfile"
      ]
    }
}
