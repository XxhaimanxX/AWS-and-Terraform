#Creating EC2 instances
resource "aws_instance" "whiskey_web"{
    ami = var.image_id
    instance_type = var.web_instance_type
    user_data = "${data.template_file.user_data.rendered}"
    availability_zone = "us-east-1a"
    key_name = var.key_pair
    network_interface {
        device_index = 0
        network_interface_id = aws_network_interface.net_interface[0].id
    }
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
resource "aws_instance" "whiskey_web2"{
    ami = var.image_id
    instance_type = var.web_instance_type
    user_data = "${data.template_file.user_data.rendered}"
    availability_zone = "us-east-1b"
    key_name = var.key_pair
    network_interface {
        device_index = 0
        network_interface_id = aws_network_interface.net_interface2[0].id
    }
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
resource "aws_instance" "DB_server" {
  ami = var.image_id
  instance_type = var.db_instance_type
  availability_zone = "us-east-1a"
  key_name = var.key_pair
  network_interface {
      device_index = 0
      network_interface_id = aws_network_interface.net_interface[1].id
  }
  tags = {
    "Owner" = "DBA"
    "server name" = "DB Server"
  }
}
resource "aws_instance" "DB_server2" {
  ami = var.image_id
  instance_type = var.db_instance_type
  availability_zone = "us-east-1b"
  key_name = var.key_pair
  network_interface {
      device_index = 0
      network_interface_id = aws_network_interface.net_interface2[1].id
  }
  tags = {
    "Owner" = "DBA"
    "server name" = "DB Server"
  }
}