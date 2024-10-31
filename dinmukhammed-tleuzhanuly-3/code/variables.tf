variable "location" {
  type        = string
  description = "The Azure region where resources will be created"
  default     = "eastus"
}

variable "project" {
  type        = string
  description = "Project name or abbreviation"
  default     = "hm3"
}

variable "suffix" {
  type        = string
  description = "Suffix to append to resource names for uniqueness"
  default     = "03"
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to add to all resources"
  default     = {}
}
