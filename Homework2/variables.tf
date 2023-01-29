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