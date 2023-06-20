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
  esxi_hostname      = "10.10.10.200" # Hostname ou IP
  esxi_hostport      = "22" # Port SSH
  #esxi_hostssl       = "443" #
  esxi_username      = "root"
  esxi_password      = "YkaNm6DXfc?+" # "@isSimpl0n!"
}

resource "esxi_guest" "Confluence-Deb-01" {
  guest_name    = "PRD-CFL-LX" # Nom de la nouvelle VM
  #id = var.id # id de la nouvelle VM
  disk_store      = "Prod" #  Nom de la Datastore ou sera stocke la VM
  memsize         = "1024" #  Ram
  numvcpus        = "1" #     Cpu
  boot_disk_size  = "10" #    Disk Size (Giga)

  #  Guest to clone, ovf source, guest vm etc..
  #clone_from_vm      = "Templates/centos7"
  #URL du fichier ovf
  ovf_source        = "../tpl/DEB-TPL/DEB-TPL.ovf"
  ################################################

  network_interfaces {
    virtual_network = "VM Network" # Network de du provider
    mac_address = var.mac_addr # (Optionnel) Permet la reservation d'ip via DHCP
    #nic_type = "" #Type de Carte reseau (option avancee attention !!)
  }

  #Provisionning
  connection {
		type	=	"ssh"
		user	=	var.ssh_user
		host	=	var.ssh_host
    password = var.ssh_pwd
		#private_key = file(var.ssh_key) # A predefinir dans le template
   }

   provisioner "remote-exec" {
    inline = [
        # Modification du nom d'hote de la machine
        "echo ${var.hostname} > /etc/hostname",
        "sed -i s/LX-TPL/${var.hostname}/g /etc/hosts", # sed remplace un text par un autre dans un fichier

        "apt install -y sudo",
        # Ajout propre d'un nouvel utilisateur au groupe sudo, creation de son mot de passe et de son repertoire /home
        "useradd -m ${var.new_user} -d \"/home/${var.new_user}\" -s \"/bin/bash\" -G \"sudo\"",
        "echo ${var.new_user}:${var.new_user_pwd} | chpasswd",
        # Autorisation d'executer la commande sudo sans mot de passe
        "echo \"${var.new_user} ALL=(ALL) NOPASSWD: ALL\" | tee /etc/sudoers.d/${var.new_user}",

        # Creation des repertoires necessaires 
        "mkdir -p /home/${var.new_user}/Confluence",
        "mkdir -p /home/${var.new_user}/.ssh",

        # Ajout de la cle de chiffrement dans le .ssh de l'user
        "echo \"${var.ssh_pubkey}\" >> /home/${var.new_user}/.ssh/authorized_keys",

        # Suppression de l'ancienne partition et creation d'une nouvelle contenant l'espace
        # du nouveau disque choisi lors de la creation de la VM
        # Necessite un reboot pour etre prise en compte
        "echo d'\\n'5'\\n'd'\\n'2'\\n'n'\\n'e'\\n'2'\\n''\\n''\\n'n'\\n''\\n''\\n'n'\\n'w'\\n' | fdisk /dev/sda"
    ]
   }

    # Reboot impossible depuis le remote-exec sans generer d'erreur et perdre la connexion
    # Utilisation d'un "local-exec" executant le reboot de la VM sans generer d''erreur
    provisioner "local-exec" {
      #interpreter = [ "/bin/bash" ]
      #command = "ssh ${var.new_user}@${var.ssh_host} \"sudo reboot\"; ts=`date +%s`;let \"ts += ${var.time_to_wait} * 60\" && connect=1; while [[ $connect -gt 0 ]] && [[ `date +%s` -lt $ts ]];do ssh -o \"StrictHostKeyChecking=no\" ${var.new_user}@${var.ssh_host} \"echo 1\";connect=$?;if [[ $connect -gt 0 ]];then sleep 30;fi;done;"
      command = "ssh ${var.new_user}@${var.ssh_host} \"sudo reboot\""
    }

    provisioner "remote-exec" {
      inline = [
        # Apres reboot, il faut etendre le nouveau volume disponible,
        # Comme dans le gestionnaire de disques Windows mais version Linux
        "resize2fs /dev/mapper/DEB--TPL--vg-root",
        "pvresize /dev/sda5",
        "resize2fs /dev/s",
        "lvextend -l +100%FREE /dev/mapper/DEB--TPL--vg-root",
        "resize2fs /dev/mapper/DEB--TPL--vg-root",
        "df -h" # Affiche l'espace disponible sur le filesystem
      ]
    }

    # Telecharge les fichiers contenu dans le dossier local bin/
    # Et les envois sur la VM dans le repertoire indique
    provisioner "file" {
      source = "bin/"
      destination = "/home/${var.new_user}/Confluence"
    }


    provisioner "remote-exec" {
      inline= [
        # Devient proprietaire du repertoire et ce qu'il contient
        "chown -R ${var.new_user} /home/${var.new_user}/Confluence",
        "cd /home/${var.new_user}/Confluence",
        # Rend le binaire d'installation executable et egalement accessible en lecture
        # Sauf pour le proprietaire
        "chmod 755 ./atlassian-confluence-7.19.9-x64.bin",

        # Execute le binaire en tant qu'utilisateur (celui qu'on vient de creer)
        # Car actuellement nous sommes root
        "su ${var.new_user} /bin/bash -c \" sudo ./atlassian-confluence-7.19.9-x64.bin -q -varfile response.varfile\"",

        # Ajoute le nouvel utilisateur au groupes cree par le binaire
        "usermod -aG www-data,confluence ${var.new_user}"
        #"systemctl restart confluence"
      ]
    }
}
