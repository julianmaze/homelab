#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd.service
systemctl enable httpd.service
EC2_AVAIL_ZONE=$(curl -s http://169.254.169.54/latest/meta-data/placement/availability-zone)
echo "<h1>Hello world from $(hostname -f) in AZ $EC2_AVAIL_ZONE</h1>" > /var/www/html/index.html

34.220.9.74 oregon
54.219.62.188 N. California
35.183.101.227 Canada