# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "Instance type to be used for the worker nodes"
  type = string
}

variable "env" {
  description = "Working environment"
  type = string  
}

variable "min_nodes" {
  description = "Minimum ammount of worker nodes"
  type = number
}

variable "max_nodes" {
  description = "Maximum ammount of worker nodes"
  type = number
}

variable "desired_nodes" {
  description = "Desired ammount of worker nodes"
  type = number
}