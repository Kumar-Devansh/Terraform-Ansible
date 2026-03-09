output "ec2_public_ip" {
  value = [
    for key in aws_instance.my_ec2_instance : key.public_ip
  ]
}