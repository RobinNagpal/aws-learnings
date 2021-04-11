resource "aws_ecs_cluster" "my_cluster" {
  name       = "my-cluster"
  # Naming the cluster
}

data template_file task_definition {
  template = file("${path.module}/03_container_definition.json")
  vars = {
    cloudwatch_group = var.cloudwatch_group
  }
}

resource "aws_cloudwatch_log_group" "log_group" {
  name = var.cloudwatch_group

  tags = {
    Environment = "production"
  }
}
resource "aws_ecs_task_definition" "my_first_task" {
  family                   = "my-first-task"
  # Naming our first task
  container_definitions    = data.template_file.task_definition.rendered

  requires_compatibilities = [
    "FARGATE"]
  # Stating that we are using ECS Fargate
  network_mode             = "awsvpc"
  # Using awsvpc as our network mode as this is required for Fargate
  memory                   = 512
  # Specifying the memory our container requires
  cpu                      = 256
  # Specifying the CPU our container requires
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn

  depends_on = [
    aws_cloudwatch_log_group.log_group
  ]

}

resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "ecsTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = [
      "sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = [
        "ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
