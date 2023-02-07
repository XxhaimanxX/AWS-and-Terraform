output "lb_url" {
    description = "The public DNS of the LB"
    value = aws_lb.lb.dns_name
}
output "key_name" {
  description = "Key pair name"
  value = var.key_pair
}
output "s3_access_logs_arn" {
  description = "S3 access log name"
  value = aws_s3_bucket.b.arn
}
output "vpc_id" {
  description = "VPC ID"
  value = aws_vpc.main.id
}