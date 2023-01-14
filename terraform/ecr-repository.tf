resource "aws_ecr_repository" "hello-ecs-repository" {
  name = "hello-ecs"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}
