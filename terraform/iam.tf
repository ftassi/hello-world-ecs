resource "aws_iam_role" "ecs_execution_role" {
  name               = "hello-ecs-execution-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  inline_policy {
    name = "hello-ecs-execution-policy"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Action": ["*"],
    "Effect": "Allow",
    "Resource": [ "arn:aws:ecr:eu-west-1:519316597947:repository/hello-ecs" ]
  }]
}
EOF
  }
  tags = {
    Name = "hello-ecs-iam-role"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_execution_role-policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}
