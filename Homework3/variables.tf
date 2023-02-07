variable "image_id" {
  type = string
  default = "ami-0b5eea76982371e91"
}
variable "web_instance_type" {
    type = string
    default = "t3.micro"
}
variable "db_instance_type" {
    type = string
    default = "t2.micro"
}
variable "key_pair" {
  type = string
  default = "ec2-keypair"
}
variable "user_data" {
  type = string
  default = <<EOF
  #! /bin/bash
  sudo yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
  sudo yum update -y
  sudo yum install -y epel-release
  sudo yum install nginx -y
  sudo systemctl start nginx
  sudo systemctl enable nginx
  echo "<h1>Welcome to Grandpa's Whiskey ($(hostname -f))</h1>" | sudo tee /usr/share/nginx/html/index.html > /dev/null
  echo "* * * * * /usr/bin/aws s3 cp /var/log/nginx/access.log s3://grandpa-whiskey-logs/access.log" | sudo tee mycron
  crontab mycron
  EOF
}
variable "aws_profile" {
  type = string
  default = "admin"
}
variable "aws_region" {
  type = string
  default = "us-east-1"
}
variable "s3_logs_bucket" {
  type = string
  default = "grandpa-whiskey-logs"
}
variable "vpc_cidr_block" {
  type = string
  default = "10.0.0.0/16"
}
variable "public_sub_cidr_block" {
  type = string
  default = "10.0.1.0/24"
}
variable "public_sub2_cidr_block" {
  type = string
  default = "10.0.2.0/24"
}
variable "private_sub_cidr_block" {
  type = string
  default = "10.0.3.0/24"
}
variable "private_sub2_cidr_block" {
  type = string
  default = "10.0.4.0/24"
}