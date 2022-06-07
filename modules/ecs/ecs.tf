resource "aws_ecr_repository" "etz-middleware-image" {
  name = var.ecr-name
}

resource "aws_ecs_cluster" "etz-middleware-cluster" {
  name = var.ecs_cluster_name
}

resource "aws_autoscaling_group" "ecs-autoscaling" {
  max_size = 1
  min_size = 3

  tag {
    key                 = "AmazonECSManaged"
    propagate_at_launch = true
    value               = true
  }
}

resource "aws_ecs_capacity_provider" "ecs-capacity" {
  name = "ecs-capacity-provided"
  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.ecs-autoscaling.arn
    managed_termination_protection = "ENABLED"

    managed_scaling {
      maximum_scaling_step_size = 1000
      minimum_scaling_step_size = 1
      status = "ENABLED"
      target_capacity = 10
    }
  }
}


#resource "aws_ecs_cluster_capacity_providers" "ecs-cluster-capacity" {
#  name = aws_ecs_cluster.etz-middleware-cluster.name
#  capacity_providers = ["FARGATE"]
#
#
#
#default_capacity_provider_strategy {
#  base              = 1
#  weight            = 100
#  capacity_provider = "FARGATE"
#  }
#}

/*====
App Load Balancer and target group
======*/

resource "aws_alb" "etz-middleware_alb" {
  name            = "${var.ecs_cluster_name}-ALB"
  internal        = false
  security_groups = [aws_security_group.ecs-cluster-sg.id]
  subnets         = var.public_subnets

  tags = {
    Name = "${var.ecs_cluster_name}-ALB"
  }
}

resource "aws_alb_listener" "ecs_alb_https_listener" {
  load_balancer_arn = aws_alb.etz-middleware_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = var.certificate_arn
  default_action {
    type             = "forward"
    #    target_group_arn = aws_alb_target_group.ecs_default_target.arn
    target_group_arn = aws_alb_target_group.ecs_etz-middleware_target_group.arn
  }
}

resource "aws_alb_target_group" "ecs_default_target" {
  name      = "${var.ecs_cluster_name}-TG"
  port      = 80
  protocol  = "HTTP"
  vpc_id    = var.vpc_id

  tags = {
    Name = "${var.ecs_service_name}-TG"
  }
}



/*====
ECS task definitions
======*/

data "template_file" "ecs_task_definition_template" {
  template = file("task_definition.json")

  vars = {
    task_definition_name  = var.ecs_service_name
    ecs_service_name      = var.ecs_service_name
    image                 = var.docker_image_url
    docker_image_url      = aws_ecr_repository.etz-middleware-image.repository_url
    log_group             = aws_cloudwatch_log_group.etz-middleware_log_group.name
    memory                = var.memory
    docker_container_port = var.docker_container_port
    spring_profile        = var.spring_profile
    region                = var.region


  }
}

/* the task definition for the app service */

resource "aws_ecs_task_definition" "etz-middleware-task-definition" {
  container_definitions     = data.template_file.ecs_task_definition_template.rendered
  family                    = var.ecs_service_name
  cpu                       = 512
  memory                    = var.memory
  requires_compatibilities  = ["FARGATE"]
  network_mode              = "awsvpc"
  task_role_arn             = aws_iam_role.fargate_iam_role.arn
  execution_role_arn        = aws_iam_role.fargate_iam_role.arn
}

resource "aws_iam_role" "fargate_iam_role" {
  name               = "${var.ecs_service_name}-IAM-role"
  assume_role_policy = file("ecs-task-execution-role.json")
}

resource "aws_iam_role_policy" "fargate_iam_policy" {
  policy = file("ecs-task-execution-role-policy.json")
  role   = aws_iam_role.fargate_iam_role.id

}

resource "aws_ecs_service" "ecs_service" {
  name = var.ecs_service_name
  task_definition   = aws_ecs_task_definition.etz-middleware-task-definition.arn
  desired_count     = var.desired_task_number
  cluster           = aws_ecs_cluster.etz-middleware-cluster.name
  launch_type       = "FARGATE"

  network_configuration {
    subnets           = var.private_subnets
    security_groups   = [aws_security_group.app_security_group.id]
    assign_public_ip  = true
  }

  load_balancer {
    container_name    = var.ecs_service_name
    container_port    = var.docker_container_port
    target_group_arn  = aws_alb_target_group.ecs_etz-middleware_target_group.arn
  }



}

resource "aws_alb_target_group" "ecs_etz-middleware_target_group" {
  name         = "${var.ecs_service_name}-TG"
  port         = var.docker_container_port
  protocol     = "HTTP"
  vpc_id       = var.vpc_id
  target_type  = "ip"

  health_check {
    path                = "/actuator/health"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = "60"
    timeout             = "30"
    unhealthy_threshold = "3"
    healthy_threshold   = "3"
  }
  tags = {
    Name = "${var.ecs_service_name}-TG"
  }
}

#resource "aws_alb_listener_rule" "ecs_alb_listener_rule" {
#  listener_arn = aws_alb_listener.ecs_alb_https_listener.arn
#  priority     = 100
#  action {
#    type = "forward"
#    target_group_arn = aws_alb_target_group.ecs_etz-middleware_target_group.arn
#  }
#  condition {}
#
#  }

resource "aws_cloudwatch_log_group" "etz-middleware_log_group" {
  name = "${var.ecs_service_name}-LogGroup"
}


