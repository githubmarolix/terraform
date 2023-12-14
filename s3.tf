
#s3-task
#/*create s3 bucket& create ec2instance and autoassign publicip and enable cloudwatch monitoring
#and attach the rootvolume about 15 *

# AWS PROVIDER
provider "aws" {
  region     = "us-east-1"
  access_key = "AKIAVJUDS7PZA7OREAIM"
  secret_key = "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"
}
# AWS VPC
resource "aws_vpc" "reddy" {
 cidr_block = "10.0.0.0/16"
 instance_tenancy = "default"
 
  tags = {
    Name = "reddy"
  }
}

# AWS SUBNET
resource "aws_subnet" "reddy-subnet-1" {
 vpc_id = aws_vpc.reddy.id
 cidr_block = "10.0.0.0/24"
 availability_zone = "us-east-1b"
 map_public_ip_on_launch = "true"

  tags = {
    Name = "reddy-subnet-1"
  }
}

# AWS INTERNET GATEWAY
resource "aws_internet_gateway" "reddy-igw" {
  vpc_id = aws_vpc.reddy.id

  tags = {
    Name = "reddy-igw"
  }
}

# ROUTE TABLE
resource "aws_route_table" "reddy-rt1" {
  vpc_id = aws_vpc.reddy.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.reddy-igw.id
  }
  
  tags = {
   Name = "reddy-rt1"
  }
}

#ROUTE TABLE ASSOSIATION
resource "aws_route_table_association" "reddy-assosiation" {
  route_table_id = aws_route_table.reddy-rt1.id
  subnet_id      = aws_subnet.reddy-subnet-1.id
}

#S3 BUCKET
resource "aws_s3_bucket" "reddy-s3" {
  bucket = "reddy1431"

  tags = {
    Name        = "reddy-s3"
    Environment = "Dev"
  }
}

#AWS INSTANCE
resource "aws_instance" "reddy-instance" {
  ami                     = "ami-0230bd60aa48260c6"
  subnet_id               = aws_subnet.reddy-subnet-1.id
  instance_type           = "t2.micro"
  monitoring              = "true"
  root_block_device {
   volume_type             = "gp2"
   volume_size             = "15"
  }
  tags = {
    Name = "reddy-instance"
  }
}



 