variable "cluster_name" {
  default = "dev-local"
}

variable "region" {
  default = "us-east-1"
}

variable "kubernetes_version" {
  default = "1.29"
}

variable "desired_size" {
  default = "1"
}

variable "min_size" {
  default = "1"
}

variable "max_size" {
  default = "2"
}
