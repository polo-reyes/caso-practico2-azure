variable "location" {
  type = string
  description = "Región de Azure donde crearemos la infraestructura"
  default = "uksouth" 
}

variable "storage_account" {
  type = string
  description = "Nombre para la storage account"
  default = "debain_storage_account"
}

variable "public_key_path" {
  type = string
  description = "Ruta para la clave pública de acceso a las instancias"
  default="C:/Users/polor/Documents/Documentos/UNIR/azure/id_rsa.pub"
  #default = "~/.ssh/id_rsa.pub" # o la ruta correspondiente
}

variable "ssh_user" {
  type = string
  description = "Usuario para hacer ssh"
  default = "azureuser"
}

/*variable "vm_size" {
  type=string
  description="Tamaño de la máquina virtual"
  default="Standard_D2_v2" # GB, CPUs
}*/

variable "vm_sizes" {
  description="Tamaño de la máquina virtual"
  type=list(string)
  default = [ "Standard_D2s_v3", "Standard_A2_v2", "Standard_A2_v2" ]
}

variable "vms" {
  description = "VMs a crear"
  type=list(string)
  default = [ "master", "worker1", "NFS" ]
}