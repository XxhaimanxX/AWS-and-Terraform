#Creating VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "main_vpc"
  }
}
#Changing default security group
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
#Creating public subnet
resource "aws_subnet" "public_sub" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public Subnet"
  }
}
#Creating public subnet
resource "aws_subnet" "public_sub2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public Subnet"
  }
}
#Creating private subnet
resource "aws_subnet" "private_sub" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Private Subnet"
  }
}
#Creating private subnet
resource "aws_subnet" "private_sub2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.4.0/24"
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

resource "aws_network_interface" "net_interface" {
    subnet_id = aws_subnet.private_sub.id
    count = 2
}
resource "aws_network_interface" "net_interface2" {
    subnet_id = aws_subnet.private_sub2.id
    count = 2
}