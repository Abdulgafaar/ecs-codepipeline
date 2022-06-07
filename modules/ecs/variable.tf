variable "account" {}
variable "region" {}
variable "vpc_id" {}
variable "vpc_name" {}
variable "public_subnets" {
  type = list(string)
  description = "This is is the list of public subnets"
}
variable "private_subnets" {
  type = list(string)
  description = "This is is the list of private subnets"
}
variable "internet_cidr_block" {}
variable "vpc_cidr_block" {}
variable "certificate_arn" {
  description = "This is the ACM arn for the stack"
}
#variable "codestar_connections" {}
variable "docker_image_tag" {}
variable "docker_image_url" {}
variable "repo_branch_name" {}
variable "ecs_cluster_name" {
  type = string
}
variable "docker_container_port" {}
variable "ecs_service_name" {}
variable "memory" {}

variable "spring_profile" {}
variable "desired_task_number" {}
variable "ecr-name" {}

#variable resource_tags {
#  description = "This is an environment tags"
#  type        = map(string)
#  default = {
#    environment = "dev",
#    project     = "etz-middleware"
#  }
#}