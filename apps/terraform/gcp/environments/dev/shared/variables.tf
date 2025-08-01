variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "zone" {
  description = "GCP zone"
  type        = string
}

# IAM設定用変数
variable "dev_team_group" {
  description = "Development team Google group email"
  type        = string
}

variable "labels" {
  description = "Labels for resources"
  type        = map(string)
  default     = {}
} 
