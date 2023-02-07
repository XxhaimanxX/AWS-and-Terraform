###########
## Provider
###########
provider "aws" {
    profile = var.aws_profile
    region = var.aws_region
}

###########
## Remote State
###########

terraform {
  backend "s3" {
    bucket = "tfstate-grandpa-whiskey"
    key = "terraform.tfstate"
    region = "us-east-1"
    profile = "admin"
  }
}

###########
## EC2 Instances
###########

resource "aws_instance" "whiskey_web"{
    ami = var.image_id
    instance_type = var.web_instance_type
    user_data = var.user_data
    availability_zone = "us-east-1a"
    key_name = var.key_pair
    iam_instance_profile = aws_iam_instance_profile.web_log_profile.name
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
    user_data = var.user_data
    availability_zone = "us-east-1b"
    key_name = var.key_pair
    iam_instance_profile = aws_iam_instance_profile.web_log_profile.name
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

###########
## S3 Bucket
###########

resource "aws_s3_bucket" "b" {
  bucket = var.s3_logs_bucket

  tags = {
    Name = "My bucket"
  }
}

###########
## IAM Role
###########

resource "aws_iam_role_policy" "web_log_policy" {
  name = "web_log_policy"
  role = aws_iam_role.web_log_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "VisualEditor0"
        Effect = "Allow"
        Action = "s3:PutObject"
        Resource = "${aws_s3_bucket.b.arn}/*"
      },
    ]
  })
}

resource "aws_iam_role" "web_log_role" {
  name = "web_log_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_instance_profile" "web_log_profile" {
  name = "web_log_profile"
  role = aws_iam_role.web_log_role.name
}

###########
## Load Balancer + TG
###########

resource "aws_lb" "lb" {
  name = "my-lb-tf"
  load_balancer_type = "application"
  subnets = [aws_subnet.public_sub.id,aws_subnet.public_sub2.id]
  security_groups = ["${aws_security_group.allow_http.id}"]
}
resource "aws_lb_target_group" "instance_tg" {
  name = "instance-tg"
  port = 80
  protocol = "HTTP"
  target_type = "instance"
  vpc_id = aws_vpc.main.id
  stickiness {
    type = "lb_cookie"
    cookie_duration = 60
  }
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

###########
## VPC
###########

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "main_vpc"
  }
}

#Creating public subnet
resource "aws_subnet" "public_sub" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_sub_cidr_block
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public Subnet"
  }
}
#Creating public subnet
resource "aws_subnet" "public_sub2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_sub2_cidr_block
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public Subnet"
  }
}
#Creating private subnet
resource "aws_subnet" "private_sub" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_sub_cidr_block
  availability_zone = "us-east-1a"

  tags = {
    Name = "Private Subnet"
  }
}
#Creating private subnet
resource "aws_subnet" "private_sub2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_sub2_cidr_block
  availability_zone = "us-east-1b"

  tags = {
    Name = "Private Subnet"
  }
}
#Creating Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}
#Creating Elastic IP
resource "aws_eip" "eip_nat" {
  depends_on = [aws_internet_gateway.gw]
}
#Creating NAT Gateway
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.eip_nat.id
  subnet_id     = aws_subnet.public_sub.id

  tags = {
    Name = "gw NAT"
  }

  depends_on = [aws_internet_gateway.gw]
}
#Creating Private Route Table
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main.id

  route{
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gw.id
  }
}
#Creating Public Route Table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id

  route{
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}
#Attaching subnets to route table
resource "aws_route_table_association" "private_association" {
  subnet_id      = aws_subnet.private_sub.id
  route_table_id = aws_route_table.private_route_table.id
}
#Attaching subnets to route table
resource "aws_route_table_association" "private_association2" {
  subnet_id      = aws_subnet.private_sub2.id
  route_table_id = aws_route_table.private_route_table.id
}
resource "aws_route_table_association" "public_association" {
  subnet_id      = aws_subnet.public_sub.id
  route_table_id = aws_route_table.public_route_table.id
}
resource "aws_route_table_association" "public_association2" {
  subnet_id      = aws_subnet.public_sub2.id
  route_table_id = aws_route_table.public_route_table.id
}
#Creating network interfaces
resource "aws_network_interface" "net_interface" {
    subnet_id = aws_subnet.private_sub.id
    security_groups = ["${aws_security_group.allow_http.id}" , "${aws_security_group.allow_ssh.id}"]
    count = 2
}
resource "aws_network_interface" "net_interface2" {
    subnet_id = aws_subnet.private_sub2.id
    security_groups = ["${aws_security_group.allow_http.id}" , "${aws_security_group.allow_ssh.id}"]
    count = 2
}

###########
## Security groups
###########

resource "aws_security_group" "allow_http" {
  name  =  "allow_http"
  description = "Allow HTTP requests"
  vpc_id = aws_vpc.main.id
}

resource "aws_security_group" "allow_ssh" {
  name  =  "allow_ssh"
  description = "Allow SSH requests"
  vpc_id = aws_vpc.main.id
}

resource "aws_security_group_rule" "allow_http_ingress" {
  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.allow_http.id}"
}

resource "aws_security_group_rule" "allow_ssh_ingress" {
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.allow_ssh.id}"
}

resource "aws_security_group_rule" "allow_all_egress" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = -1
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.allow_http.id}"
}

###########
## Volumes
###########

resource "aws_ebs_volume" "gp2_disk"{
    availability_zone = "us-east-1a"
    size = 10
    encrypted = true
    type = "gp2"
}
resource "aws_ebs_volume" "gp2_disk2"{
    availability_zone = "us-east-1b"
    size = 10
    encrypted = true
    type = "gp2"
}
resource "aws_volume_attachment" "gp2_disk_att"{
    device_name = "/dev/sdh"
    volume_id = aws_ebs_volume.gp2_disk.id
    instance_id = aws_instance.whiskey_web.id
}
resource "aws_volume_attachment" "gp2_disk_att1"{
    device_name = "/dev/sdh"
    volume_id = aws_ebs_volume.gp2_disk2.id
    instance_id = aws_instance.whiskey_web2.id
}