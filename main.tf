provider "aws" {
    region = "us-east-1"
}

#Create ec2 instance named "db" and give it a name
resource "aws_instance" "db"{
    ami = "ami-08a52ddb321b32a8c"
    instance_type = "t2.micro"

    tags = {
        Name = "DB Server"
    }
}

#Create ec2 instance named "web" and give it a name
resource "aws_instance" "web"{
    ami = "ami-08a52ddb321b32a8c"
    instance_type = "t2.micro"
    security_groups = [aws_security_group.web_traffic.name]
    user_data = file("server-script.sh")

    tags = {
        Name = "Web Server"
    }
}

#create EIP for the web instance
resource "aws_eip" "web_ip" {
    instance = aws_instance.web.id
}

#create variables for ports traffic
variable "ingress"{
    type = list(number)
    default = [80,443]
}

variable "egress"{
    type = list(number)
    default = [80,443]
}

#create security group named "web_traffic" and give it a name
resource "aws_security_group" "web_traffic" {
    name = "Allow Web Traffic"

#create dynamic blocks for the ingress rules    
    dynamic "ingress" {
        iterator = port
        for_each = var.ingress
        content {
            from_port = port.value
            to_port = port.value
            protocol = "TCP"
            cidr_blocks = ["0.0.0.0/0"]
        }
      
    }

#create dynamic blocks for the egress rules 
    dynamic "egress" {
        iterator = port
        for_each = var.egress
        content {
            from_port = port.value
            to_port = port.value
            protocol = "TCP"
            cidr_blocks = ["0.0.0.0/0"]
        }
      
    }
}

#Outputs
output "PrivateIP"{
    value = aws_instance.db.private_ip
}

output "PublicIP"{
    value = aws_eip.web_ip.public_ip
}