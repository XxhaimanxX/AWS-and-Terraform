provider "aws" {
    region = "us-east-1"
}
resource "aws_instance" "whiskey_web"{
    ami = "ami-0b5eea76982371e91"
    instance_type = "t3.micro"
    count = 2
    vpc_security_group_ids = [aws_security_group.ec2-sg.id]
    user_data = "${data.template_file.user_data.rendered}"
    availability_zone = "us-east-1a"
    key_name = "ec2-keypair"
    root_block_device{
        volume_size = 10
        volume_type = "gp2"
    }
    tags = {
        Owner = "admin"
        "Server name" = "Nginx server"
        Purpose = "whiskey"
    }
}
data "template_file" "user_data" {
  template = "${file("install_nginx.sh")}"
}
resource "aws_ebs_volume" "gp2_disk"{
    availability_zone = "us-east-1a"
    size = 10
    count = 2
    encrypted = true
    type = "gp2"
}
resource "aws_volume_attachment" "gp2_disk_att"{
    device_name = "/dev/sdh"
    volume_id = aws_ebs_volume.gp2_disk[0].id
    instance_id = aws_instance.whiskey_web[0].id
}
resource "aws_volume_attachment" "gp2_disk_att1"{
    device_name = "/dev/sdh"
    volume_id = aws_ebs_volume.gp2_disk[1].id
    instance_id = aws_instance.whiskey_web[1].id
}
resource "aws_security_group" "ec2-sg"{
    ingress{
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress{
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress{
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks   = ["87.70.104.141/32"]
    }
    egress{
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
    }
}