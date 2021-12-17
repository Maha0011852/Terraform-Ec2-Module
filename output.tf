# Printing the output of the instance's public IP
output "Here_is_my_Public_IP"{
  value = aws_instance.My_ec2.public_ip
}