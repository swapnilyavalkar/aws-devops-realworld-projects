# EC2 Instance Module

variable "instance_ami" {
    description = "EC2 AMI"
    type = string
    default = "ami-0dee22c13ea7a9a67"
  
}

variable "instance_type" {
    description = "EC2 Instance Type"
    type = string
    default = "t2.micro"
}

variable "instance_name" {
    description = "name of ec2"
    type = string
    default = "Web-Server-1"
  
}
resource "aws_instance" "server-1" {
    ami = var.instance_ami
    instance_type = var.instance_type

    tags = {
        Name = "${terraform.workspace}-server"
    } 
}

output "instance_id" {
    value = aws_instance.server-1.id      
}

output "instance_pub_ip"{
    value = aws_instance.server-1.public_ip
}
