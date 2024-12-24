variable "vpc_cidr"{
    type = string
    default = "30.20.0.0/16"
}

variable "vpc_tenancy"{
    type = string
    default = "default"
}

variable "vpc_tags"{
    type = map(string)
   default = {
      "name" = "sample_vpc"
    }

}
