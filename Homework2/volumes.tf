#Creating and attaching volumes to the web servers
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