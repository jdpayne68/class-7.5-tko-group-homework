variable "project_id" {
  description = "saba-seir"
  type        = string
}

variable "region" {
  #Iowa. Corn. Clouds. Infrastructure.
  type    = string
  default = "us-central1"
}

variable "zone" {
  #A single node awakens here.
  type    = string
  default = "us-central1-a"
}

variable "student_name" {
  #Your deploy banner. Own your work.
  type    = string
  default = "Cautchy 'thatcautchyguy' Bailly"
}

variable "vm_name" {
  type    = string
  default = "cautch-says-node-lab2"
}