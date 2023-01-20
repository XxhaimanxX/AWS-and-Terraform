#! /bin/bash
sudo yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
sudo yum update -y
sudo yum install -y epel-release
sudo yum install nginx -y
sudo systemctl start nginx
sudo systemctl enable nginx
echo "<h1>Welcome to Grandpa's Whiskey</h1>" | sudo tee /usr/share/nginx/html/index.html > /dev/null