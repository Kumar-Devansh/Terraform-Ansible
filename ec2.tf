# key-pair for login

resource "aws_key_pair" "my_key" {
    key_name   = "terra-ec2-key"
    public_key = file("terra-ec2-key.pub")
    
}

# VPC & Security Group

data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "my_security_group" {
  name = "automate-sg"
  description = "This will add a TF generated security group to the default VPC"
#   vpc_id = module.vpc.vpc_id                                       # data.aws_vpc.default.id # Interpolation 
    vpc_id = data.aws_vpc.default.id
    # inbound rule 
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "SSH Open"
    }

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "HTTP Open"
    }
    #outbound rule 
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        description = "All access outbound open "
    }

  tags = {
    Name = "automate-sg"
  }

}

 # ec2 instance

    resource "aws_instance" "my_ec2_instance" {
        for_each = tomap({
            TWS-junoon-master = "ami-06e3c045d79fd65d9" #ubuntu 
            TWS-junoon-1 = "ami-06e3c045d79fd65d9"
            TWS-junoon-2 = "ami-06e3c045d79fd65d9"
        }) # These are meta arguments that allow us to create multiple instances with different configurations using a map. The key is the instance name and the value is the instance type. (Alt+z to wrap the code)
        # count = 2 # to create 2 instances (meta argument)

        depends_on = [ aws_security_group.my_security_group, aws_key_pair.my_key ] # to ensure that the security group and key pair are created before the EC2 instance

        key_name = aws_key_pair.my_key.key_name
        # subnet_id = module.vpc.public_subnets[0] # to launch the instance in the first public subnet of the VPC
        # vpc_security_group_ids = [aws_security_group.my_security_group.id]
        security_groups = [aws_security_group.my_security_group.name]
        instance_type = "t3.micro"
        ami = each.value 

        root_block_device {
            volume_size = 10
            volume_type = "gp2"
        }

        tags = {
            Name = each.key
        }
    }




