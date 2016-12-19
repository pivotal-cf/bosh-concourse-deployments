
variable "project_id" {
    type = "string"
}

variable "gcp_credentials_json" {
    type = "string"
}

variable "trusted_cidr" {
    type = "string"
}

variable "region" {
    type = "string"
    default = "us-west1"
}

variable "network" {
    default = "concourse"
}

variable "concourse_subnet" {
  type = "map"
  default = {
    internal_cidr   = "10.0.0.0/24"
    name            = "concourse"
    zone            = "us-west1-b"
    region          = "us-west1"
    allow_mbus_access_to_natbox = 0
    allow_mbus_access_to_jumpbox = 0
    allow_ssh_access_to_jumpbox = 0
  }
}

variable "asia_subnet" {
  type = "map"
  default = {
    internal_cidr   = "10.0.1.0/24"
    name            = "asia"
    zone            = "asia-east1-b"
    region          = "asia-east1"
    allow_mbus_access_to_natbox = 0
  }
}
