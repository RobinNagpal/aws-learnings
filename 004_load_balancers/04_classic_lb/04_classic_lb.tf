resource "aws_elb" "application_load_balancer" {
  name               = "test-lb-tf"
  availability_zones = [
    "us-east-2a",
    "us-east-2b",
    "us-east-2c"
  ]

  listener {
    instance_port     = 3000
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

}

resource "aws_lb_target_group" "target_group" {
  name        = "target-group"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_default_vpc.default_vpc.id
  # Referencing the default VPC
}

resource "aws_ecs_service" "my_first_service" {
  name            = "my-first-service"
  # Naming our first service
  cluster         = aws_ecs_cluster.my_cluster.id
  # Referencing our created Cluster
  task_definition = aws_ecs_task_definition.my_first_task.arn

  desired_count = 3
  # Setting the number of containers to 3

  launch_type = "EC2"

  load_balancer {
    elb_name = aws_elb.application_load_balancer.name
    # Referencing our target group
    container_name   = aws_ecs_task_definition.my_first_task.family
    container_port   = 3000
  }
}


output "lb_url" {
  value = aws_elb.application_load_balancer.dns_name
}
