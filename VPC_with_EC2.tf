provider "aws" {
    region = "us-east-2"
    access_key = "AKIAYROCPBDXUKBPXVIC"
    secret_key = "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"
}
resource "aws_instance" "terraform-test" {
    ami = "ami-024e6efaf93d85776"
    key_name = "key1"
    instance_type = "t2.micro"
    subnet_id =  aws_subnet.demo-subnet.id
    vpc_security_group_ids = [aws_security_group.demo-sg.id]
    associate_public_ip_address = "true"

user_data = <<-EOF
    #!/bin/bash
    sudo apt-get update
    Sudo apt-get install -y apache2
    sudo systemctl start apache2
  EOF
  
  tags = {
    Name = "Terraform -demo"
  }    
}

//Create VPC
resource "aws_vpc" "demo-vpc" {
     cidr_block ="10.10.0.0/16"

   tags = {
    Name = "demo-VPC"
  }   
}
//Create Subnet
resource "aws_subnet" "demo-subnet" {
     vpc_id     = aws_vpc.demo-vpc.id
     cidr_block = "10.10.1.0/24"

  tags = {
    Name = "demo-subnet"
  }
}
//Create Internet Gateway
resource "aws_internet_gateway" "demo-igw" {
  vpc_id = aws_vpc.demo-vpc.id

  tags = {
    Name = "demo-igw"
  }
}
//Create Route Table
resource "aws_route_table" "demo-routetable" {
  vpc_id = aws_vpc.demo-vpc.id

route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demo-igw.id
  }


  tags = {
    Name = "demo-routetable"
  }
}
//Subnet Assocaition
resource "aws_route_table_association" "demo-subnet-association" {
  subnet_id      = aws_subnet.demo-subnet.id
  route_table_id = aws_route_table.demo-routetable.id
}

//Security Group
resource "aws_security_group" "demo-sg" {
  name        = "demo-sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.demo-vpc.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}
