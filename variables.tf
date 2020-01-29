variable "source_environments" {
  default = []
}

variable "tags" {
  default = {}
}

variable "delimiter" {
  default = ""
}
variable "namespace" {
  default = ""
}

variable "name" {
  default = ""
}

variable "stage" {
  default = ""
}

variable "attributes" {
  default = []
}

variable "environment" {
  default = ""
}

variable "sse_algorithm" {
  type        = string
  default     = "AES256"
  description = "The server-side encryption algorithm to use. Valid values are `AES256` and `aws:kms`"
}

variable "kms_master_key_arn" {
  type        = string
  default     = ""
  description = "The AWS KMS master key ARN used for the `SSE-KMS` encryption. This can only be used when you set the value of `sse_algorithm` as `aws:kms`. The default aws/s3 AWS KMS master key is used if this element is absent while the `sse_algorithm` is `aws:kms`"
}

variable "noncurrent_version_transition_days" {
  type        = number
  default     = 30
  description = "Number of days to persist in the standard storage tier before moving to the glacier tier infrequent access tier"
}

variable "noncurrent_version_expiration_days" {
  type        = number
  default     = 90
  description = "Specifies when noncurrent object versions expire"
}

variable "versioning_enabled" {
  default = true
}

variable "force_destroy" {
  default = false
}