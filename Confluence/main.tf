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
  disk_store      = "Prod" # Datastore
  memsize         = "1024" # Ram
  numvcpus        = "1" # Cpu
  boot_disk_size  = "10"

  #  Specify an existing guest to clone, an ovf source, or neither to build a bare-metal guest vm.
  #
  #clone_from_vm      = "Templates/centos7"
  #URL du fichier ovf
  ovf_source        = "../tpl/LX-TPL/LX-TPL.ovf"

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
    password = var.ssh_pwd
		#private_key = file(var.ssh_key)
   }

   provisioner "remote-exec" {
    inline = [
        "echo ${var.hostname} > /etc/hostname",
        "sed -i /127.0.1.1\tLX-TPL/c\\127.0.1.1\t${var.hostname}\\",
        "apt install -y sudo",
        "useradd -m ${var.new_user}",
        "echo ${var.new_user_pwd}'\\n'${var.new_user_pwd} | passwd ${var.new_user}",
        "echo ${var.new_user}'\\n'${var.new_user}",
        "usermod -aG sudo ${var.new_user}",
        "echo \"${var.new_user} ALL=(ALL) NOPASSWD: ALL\" | tee /etc/sudoers.d/${var.new_user}",
        "mkdir -p /home/${var.new_user}/Confluence",
        "mkdir -p /home/${var.new_user}/.ssh",
        "echo \"${var.ssh_pubkey}\" >> /home/${var.new_user}/.ssh/authorized_keys"
    ]
   }

    provisioner "local-exec" {
      command = <<-EOT
          ssh ${var.new_user}@10.10.10.201
          "echo d'\\n'2'\\n'd'\\n'1'\\n'n'\\n'p'\\n'1'\\n''\\n''\\n'n'\\n'w'\\n'" | fdisk /dev/sda
          reboot
          ts=`date +%s`
          let "ts += ${var.time_to_wait} * 60"
          connect=1
          while [[ $connect -gt 0 ]] && [[ `date +%s` -lt $ts ]];do ssh -o "StrictHostKeyChecking=no" ${var.new_user}@${var.ssh_host};connect=$?;if [[ $connect -gt 0 ]];then sleep 30;fi;done
        EOT
    }

    /*provisioner "remote-exec" {
      inline = [
        #"ps aux | grep sshd | grep -v grep | awk '{print $2}' | xargs kill | reboot"
      ]
    }*/

    provisioner "remote-exec" {
      inline = [
        "resize2fs /dev/sda1",
        "fdisk -l"
      ]
    }

    provisioner "file" {
      source = "bin/"
      destination = "/home/${var.new_user}/Confluence"
    }

    provisioner "remote-exec" {
      inline= [
        "cd /home/${var.new_user}/Confluence",
        "chmod 733 ./atlassian-confluence-7.19.9-x64.bin",
        "sudo ./atlassian-confluence-7.19.9-x64.bin -q -varfile response.varfile"
      ]
    }
}
