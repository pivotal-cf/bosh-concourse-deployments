
variable "google_project_id" {
    type = "string"
}

variable "google_credentials_json" {
    type = "string"
}

variable "trusted_cidr" {
    type = "string"
}

variable "director_cidr" {
    type = "string"
    default = "10.0.0.0/24"
}

variable "bosh_external_tag" {
    type = "string"
    default = "bosh-external"
}

variable "bosh_internal_tag" {
    type = "string"
    default = "bosh-internal"
}

variable "network_name" {
    type = "string"
    default = "concourse"
}

variable "subnetwork_name" {
    type = "string"
    default = "concourse"
}

variable "zone" {
    type = "string"
    default = "us-west1-b"
}

variable "region" {
    type = "string"
    default = "us-west1"
}
