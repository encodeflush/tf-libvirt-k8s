
variable "lb_node_count" {
    type = string
    default = "1"
}

variable "ctrl_node_count" {
    type = string
    default = "1"
}

variable "data_node_count" {
    type = string
    default = "2"
}

variable "lb_node_name" {
    type = string
    default = "lb"
}

variable "ctrl_node_name" {
    type = string
    default = "ctrlr"
}

variable "data_node_name" {  
    type = string
    default = "node"
}

variable "public_ssh_key" {
   type = string
   default = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILxZOQyVqnZRUp8yl87IQP1iujVR8WBm+mYJDprw7tFk h.salahi@reply.de"
}
