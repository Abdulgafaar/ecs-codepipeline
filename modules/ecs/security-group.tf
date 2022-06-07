resource "aws_security_group" "ecs-cluster-sg" {
  name     = "${var.ecs_cluster_name}-SG"
  description = "Security group for ECS to communicate in and out"
  vpc_id = var.vpc_id

  ingress {
    from_port = 9021
    protocol  = "TCP"
    to_port   = 65535
    cidr_blocks = [var.vpc_cidr_block]
  }
  ingress {
    from_port = 22
    protocol  = "TCP"
    to_port   = 22
    cidr_blocks = [var.internet_cidr_block]
  }

  egress {
    from_port = 0
    protocol  = "-1"
    to_port   = 0
    cidr_blocks = [var.internet_cidr_block]
  }

  tags = {
    Name = "${var.ecs_cluster_name}-SG"
  }
}

resource "aws_security_group" "ecs-alb-sg" {
  name = "${var.ecs_cluster_name}-ALB-SG"
  description = "Security group for ALB to traffic for ECS cluster"
  vpc_id = var.vpc_id

  ingress {
    from_port = 443
    protocol  = "TCP"
    to_port   = 443
    cidr_blocks = [var.internet_cidr_block]
  }

  egress {
    from_port = 0
    protocol  = "-1"
    to_port   = 0
    cidr_blocks = [var.internet_cidr_block]
  }
}

resource "aws_security_group" "app_security_group" {
  name = "${var.ecs_service_name}-SG"
  description = "Security group for app to communicate in and out"
  vpc_id = var.vpc_id

  ingress {
    from_port = 9021
    protocol  = "tcp"
    to_port   = 9021
    cidr_blocks = [var.vpc_cidr_block]
  }

  egress {
    from_port = 0
    protocol  = "-1"
    to_port   = 0
    cidr_blocks = [var.internet_cidr_block]
  }
  tags = {
    Name = "${var.ecs_service_name}-SG"
  }
}