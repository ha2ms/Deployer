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

resource "esxi_guest" "Esx-Blk-02" {
  guest_name    = "Esx-Blk-02" # Nom de VM
  disk_store    = "Prod" # Datastore
  memsize       = "1024" # Ram
  numvcpus      = "1" # Cpu
  boot_disk_size     = "17"

  #  Specify an existing guest to clone, an ovf source, or neither to build a bare-metal guest vm.
  #
  #clone_from_vm      = "Templates/centos7"
  #URL du fichier ovf
  ovf_source        = "./tpl/Blk-Deb-Tpl.ovf"

  network_interfaces {
    virtual_network = "VM Network"
  }

  #Provisionning
  #connection {
	#	type	=	"ssh"
	#	user	=	var.ssh_user
	#	host	=	var.ssh_host
	#	private_key = file(var.ssh_key)
  # }
  #  provisioner "remote-exec" {
	#	inline= [
	 # Provisionning with linux commands
	 #]
}

