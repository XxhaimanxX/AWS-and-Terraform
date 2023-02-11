module "servers" {
  source = "../modules/servers"
  web_instance_type = var.web_instance_type
  aws_region = var.aws_region
  db_instance_type = var.db_instance_type
  image_id = var.image_id
  key_pair = var.key_pair
  s3_logs_bucket = var.s3_logs_bucket
  user_data = var.user_data
}