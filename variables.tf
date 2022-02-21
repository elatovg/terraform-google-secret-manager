/**
 * Copyright 2022 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

variable "project_id" {
  type        = string
  description = "The project ID to manage the Secret Manager resources"
}

variable "secrets" {
  type = list(object({
    name                  = string
    automatic_replication = bool
    user_managed_replication = list(object({
      location     = string
      kms_key_name = string
    }))
    labels = map(string)
    topics = list(object({
      name = string
    }))
    rotation = object({
      next_rotation_time = string
      rotation_period    = string
    })
    secret_data = string
  }))
  description = "The list of the secrets"
  default     = []
}

variable "add_kms_permissions" {
  type        = list(string)
  description = "The list of the crypto keys to give secret manager access to"
  default     = []
}

variable "add_pubsub_permissions" {
  type        = list(string)
  description = "The list of the pubsub topics to give secret manager access to"
  default     = []
}
