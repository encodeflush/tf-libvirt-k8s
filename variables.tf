variable "lb_node_count" {
    type = string
    default = "0"
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
    default = "worker"
}

variable "public_ssh_key" {
   type = string
   default = ""
}
