resource "aws_alb" "application_load_balancer" {
  name               = "test-lb-tf"
  # Naming our load balancer
  load_balancer_type = "application"
  subnets            = [
    # Referencing the default subnets
    aws_default_subnet.default_subnet_a.id,
    aws_default_subnet.default_subnet_b.id,
    aws_default_subnet.default_subnet_c.id
  ]
  # Referencing the security group
  security_groups    = [
    aws_security_group.load_balancer_security_group.id]
}

# Creating a security group for the load balancer:
resource "aws_security_group" "load_balancer_security_group" {
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
    # Allowing traffic in from all sources
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
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

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_alb.application_load_balancer.arn
  # Referencing our load balancer
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
    # Referencing our tagrte group
  }
}

resource "aws_ecs_service" "my_first_service" {
  name            = "my-first-service"
  # Naming our first service
  cluster         = aws_ecs_cluster.my_cluster.id
  # Referencing our created Cluster
  task_definition = aws_ecs_task_definition.my_first_task.arn
  # Referencing the task our service will spin up
  launch_type     = "FARGATE"
  desired_count   = 3
  # Setting the number of containers to 3

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.arn
    # Referencing our target group
    container_name   = aws_ecs_task_definition.my_first_task.family
    container_port   = 3000
    # Specifying the container port
  }

  network_configuration {
    subnets          = [
      aws_default_subnet.default_subnet_a.id,
      aws_default_subnet.default_subnet_b.id,
      aws_default_subnet.default_subnet_c.id]
    assign_public_ip = true
    # Providing our containers with public IPs
    security_groups  = [
      aws_security_group.service_security_group.id]
    # Setting the security group
  }
}


resource "aws_security_group" "service_security_group" {
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    # Only allowing traffic in from the load balancer security group
    security_groups = [
      aws_security_group.load_balancer_security_group.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
}


output "lb_url" {
  value = aws_alb.application_load_balancer.dns_name
}
