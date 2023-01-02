variable "domain" {
  type        = string
  sensitive   = false
  description = "Target Email-Domain."
}

variable "zone_id" {
  type        = string
  sensitive   = true
  description = "Zone ID of the provided domains."
}


variable "verification" {
  type        = string
  sensitive   = true
  description = "Domain verification string."
  default     = null
}
