variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-2" # Seoul
}

variable "tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
  default = {
    Project     = "hybrid-k8s"
    ManagedBy   = "terraform"
  }
}