# Provider Block
provider "aws" {
  version = "~> 2.0"
  region  = "us-east-2"
}

# Resource Block to create an EC2 instance
resource "aws_instance" "My_ec2"{
  ami                    = "ami-03a0c45ebc70f98ea"
  instance_type          = "t2.micro"
  key_name               = "Ubuntu1621"
  security_groups        = ["security_ports"]
  availability_zone      = "us-east-2c"

# Increasing the root volume for Ec2 instance
  root_block_device{
    volume_size = 12
    volume_type = "gp2"
    encrypted = true
    delete_on_termination = true
  }
  
# Launching apache2 web server and configuring index.html
  user_data = <<-EOF
            #!/bin/bash
            sudo apt-get update -y
            sudo apt-get install apache2 -y
            service apache2 start
            echo "My Terraform Instance!" > /var/www/html/index.html
            EOF

    tags = {
        Name = "Terraform"
}
}

# Resource Block to create security groups
resource "aws_security_group" "security_ports" {
  name        = "security_ports"
  description = "Allowing ssh and http traffic"

# Allowing port 22 for SSH
  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["49.37.209.97/32"]
  }

# Allowing port 80 for http
  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  egress  {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  tags = {
    Name = "security_ports"
  }
}

# Resource Block to create IAM users
resource "aws_iam_user" "user01"{
  name = "user01"
}
resource "aws_iam_user" "user02"{
  name = "user02"
}

# Resource Block to create an IAM group for users
resource "aws_iam_group" "user-group"{
  name = "user-group"
}

# Resource Block to assign users to the created group
resource "aws_iam_group_membership" assignment {
  name = "assignment"
  users = [
    aws_iam_user.user01.name,
    aws_iam_user.user02.name
  ]
  group = aws_iam_group.user-group.name
}

# Resource Block to attach a s3 bucket policy to the group
resource "aws_iam_policy_attachment" "attachment"{
  name = "attachment"
  groups = [aws_iam_group.user-group.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}
# Resource Block to Create a S3 bucket and restrict it
resource "aws_s3_bucket" "s3-bucket-01-unique"{
  bucket = "s3-bucket-01-unique"
  acl = "private"
  tags = {
    Name = "demo"
  }
}


