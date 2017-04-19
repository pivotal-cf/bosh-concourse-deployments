
variable "project_id" {
    type = "string"
}

variable "gcp_credentials_json" {
    type = "string"
}

variable "trusted_cidr" {
    type = "string"
}

variable "network" {
    default = "concourse"
    description = "Existing network in which to create the asia subnetwork"
}

variable "internal_cidr" {
  default = "10.0.1.0/24"
}

variable "name" {
  default = "asia"
}

variable "zone" {
  default = "asia-east1-b"
}

variable "region" {
  default = "asia-east1"
}

variable "concourse_atc_tag" {
  default = "concourse-concourse-atc"
}

variable "allow_mbus_access_to_natbox" {
  default = 0
  description = "Allow mbus access (6868) from `trusted_cidr` to the Natbox. Set to 1 to enable."
}

variable "allow_mbus_access_to_jumpbox" {
  default = 0
  description = "Allow mbus access (6868) from `trusted_cidr` to the Jumpbox. Set to 1 to enable."
}

variable "allow_ssh_access_to_jumpbox" {
  default = 0
  description = "Allow SSH access from `trusted_cidr` to the Jumpbox. Set to 1 to enable."
}
