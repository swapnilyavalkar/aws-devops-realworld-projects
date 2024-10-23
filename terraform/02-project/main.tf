provider "aws" {

    region = "ap-south-1"
  
}

data "aws_vpc" "vpc_default" {
    default = false
  
}

data "aws_subnet" "subnet" {

    vpc_id = data.aws_vpc.vpc_default.id
  
}

output "subnets" {
  value = data.aws_subnet.subnet.id
}

output "aws_vpc" {
    value = data.aws_vpc.vpc_default.id
}

module "ec2_instance" {
    source = "./modules/ec2_instance"
    instance_ami = "ami-0dee22c13ea7a9a67"
    instance_name = "Test1"
 
}

output "instance_id" {
  value = module.ec2_instance.instance_id
}

output "instance_pub_ip" {
value = module.ec2_instance.instance_pub_ip
}