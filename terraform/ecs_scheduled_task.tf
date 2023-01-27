resource "aws_ecs_task_definition" "hello_ecs_task" {
  family = "hello-ecs-task"
  requires_compatibilities = ["FARGATE"]
  network_mode = "awsvpc"
  cpu = "256"
  memory = "512"
  execution_role_arn = aws_iam_role.ecs_execution_role.arn
  task_role_arn = aws_iam_role.ecs_execution_role.arn
  container_definitions = <<DEFINITION
[
  {
    "name": "hello-ecs",
    "image": "519316597947.dkr.ecr.eu-west-1.amazonaws.com/hello-ecs:latest",
    "cpu": 256,
    "memory": 512,
    "essential": true,
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "hello-ecs-log-group",
        "awslogs-region": "eu-west-1",
        "awslogs-stream-prefix": "hello-ecs"
      }
    }
  }
]
DEFINITION
}

resource "aws_ecs_cluster" "hello_ecs_cluster" {
  name = "hello-ecs-cluster"
  tags = {
    Name = "hello-ecs-cluster"
  }
}

resource "aws_ecr_repository" "hello-ecs-repository" {
  name = "hello-ecs"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}

module "eventbridge" {
  source = "terraform-aws-modules/eventbridge/aws"
  version = "1.17.1"
  create_bus = false
  create_role = true
  role_name = "hello-ecs-eventbridge-role"
  attach_ecs_policy = true
  ecs_target_arns = [aws_ecs_task_definition.hello_ecs_task.arn]
  rules = {
    hello_ecs = {
      description = "run every 1 minute"
      enabled = true
      schedule_expression = "rate(1 minute)"
    }
  }

  targets = {
    hello_ecs = [
      {
        name = "hello-ecs"
        arn = aws_ecs_cluster.hello_ecs_cluster.arn
        attach_role_arn = true

        ecs_target = {
          launch_type = "FARGATE"
          task_count = 1
          task_definition_arn = aws_ecs_task_definition.hello_ecs_task.arn
          network_configuration = {
            assign_public_ip = false
            security_groups = [aws_security_group.ecs_task.id]
            subnets = [aws_subnet.private.id]
          }
        }
      }
    ]
  }
}

resource "aws_cloudwatch_log_group" "hello_ecs_log_group" {
  name = "hello-ecs-log-group"
  retention_in_days = 30
  tags = {
    Name = "hello-ecs-log-group"
  }
}
