variable "web_server_name" {
    description = "Name of the web server"
    type = string
    default = "Test1"     
  
}
variable "primary_region" {
    description = "Primary region used for all resources."
    type = string
    default = "ap-south-1"
  
}

variable "instance_ami" {
    
    description = "AMI used for EC2 instance."
    type = string
    default = "ami-0dee22c13ea7a9a67"
}

variable "instance_type" {
  
  description = "Type of the EC2 instance."
  type = string
  default = "t2.micro"

}