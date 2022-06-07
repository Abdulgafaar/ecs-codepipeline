variable "region" {
  default = "eu-west-1"
}

variable "codestar_connections" {
  type = string
}
variable "repository_url" {}
variable "ecs_cluster_name" {}

variable "run_task_security_group_ids" {
  type        = string
  description = "The security group Ids attached where the single run task will be executed"
}

variable "run_task_subnet_id" {
  type 		  = string
  description = "The subnet Id where single run task will be executed"

}
variable "ecs_service_name" {
  type        = string
  description = "The ECS service that will be deployed"
}

variable "codepileline_role_arn" {}

variable "codebuild_role_arn" {}