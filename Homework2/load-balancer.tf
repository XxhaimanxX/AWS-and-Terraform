resource "aws_lb" "lb" {
  name = "my-lb-tf"
  load_balancer_type = "application"
  subnets = [aws_subnet.public_sub.id,aws_subnet.public_sub2.id]
}
resource "aws_lb_target_group" "instance_tg" {
  name = "instance-tg"
  port = 80
  protocol = "HTTP"
  target_type = "instance"
  vpc_id = aws_vpc.main.id
  health_check {
    enabled = true
    path = "/index.html"
    protocol = "HTTP"
  }
}
resource "aws_lb_listener" "lb-listener" {
  load_balancer_arn = aws_lb.lb.arn
  port = 80
  protocol = "HTTP"
  default_action {
    target_group_arn = aws_lb_target_group.instance_tg.arn
    type = "forward"
  }
}
resource "aws_lb_target_group_attachment" "tg_att" {
  target_group_arn = aws_lb_target_group.instance_tg.arn
  target_id = aws_instance.whiskey_web.id
}
resource "aws_lb_target_group_attachment" "tg_att2" {
  target_group_arn = aws_lb_target_group.instance_tg.arn
  target_id = aws_instance.whiskey_web2.id
}