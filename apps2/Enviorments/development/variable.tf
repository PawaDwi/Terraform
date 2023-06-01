variable "prodcidr" {
  type    = string
  default = "10.1.0.0/16"
}

variable "environment" {
  description = "The environment (staging, development, etc.)"
  type        = string
  default     = "development"
}
