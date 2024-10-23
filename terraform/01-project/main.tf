terraform {
    backend "s3" {
        bucket = "my-terraform-state-bucket-spy"
        key = "terraform/terraform.tfstate"
        region = "ap-south-1"
        dynamodb_table = "terraform-lock-table"
      
    }
  
}

provider "aws" {

    region = var.primary_region
  
}

resource "aws_instance" "test" {

    ami = var.instance_ami
    instance_type = var.instance_type
    tags = {
      name = var.web_server_name
    }

    provisioner "remote-exec" {

        inline = [ 
            "sudo apt-get udpate -y",
            "sudo apt-get install -y httpd",
            "sudo service httpd start"
         ]
      
    }
    
    connection {
      type = "ssh"
      user = "ec2-user"
      private_key = file("E:\\study\\aws\\my-key-pair-2.pem")
      host = self.public_ip
    }
  
}

output "public_ip_ec2" {

    description = "Public IP of EC2 instance."
    value = aws_instance.test.public_ip
  
}