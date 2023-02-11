aws_region = "us-east-1"
image_id = "ami-0b5eea76982371e91"
web_instance_type = "t3.micro"
key_pair = "ec2-keypair"
db_instance_type = "t2.micro"
s3_logs_bucket = "grandpa-whiskey-logs"
user_data = <<EOF
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
