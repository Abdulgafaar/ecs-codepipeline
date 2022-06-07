region = "eu-west-1"
vpc_id = "vpc-073d4219b0119cf83"
vpc_name = "GA_NIGERIA_DEV"
vpc_cidr_block = "172.16.16.0/21"
public_subnets = ["subnet-009839f000b26599b","subnet-08fa63b3c69bad91b","subnet-0c3802dbc7e58f182"]
private_subnets = ["subnet-06f97a75149e13a64","subnet-0a2750e29c26a95b1","subnet-0759a490ffe57b87a"]
certificate_arn = "arn:aws:acm:eu-west-1:001393350085:certificate/0f497949-8a0b-4fff-99c1-fcfffb806b54"
ecs_service_name = "etz-middleware-service"
docker_image_tag = "dev"
docker_image_url = "001393350085.dkr.ecr.eu-west-1.amazonaws.com/etzmiddleware"
repo_branch_name = "dev"
account = "001393350085"
ecs_cluster_name = "etz-middleware-staging"
docker_container_port = 9021
memory = 1024
spring_profile = "dev"
desired_task_number = 1
internet_cidr_block = "0.0.0.0/0"
ecr-name = "etzmiddleware"
#resource_tags = ""