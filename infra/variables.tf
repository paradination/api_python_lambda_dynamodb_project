variable "project" { type = string }
variable "env" { type = string }
variable "region" { type = string }

variable "tags" {
  type    = map(string)
  default = {}
}

variable "api_key_enabled" {
  type    = bool
  default = true
}
