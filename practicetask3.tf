# AWS PROVIDER
provider "aws" {
 region = "us-east-1"
 access_key = "AKIASODJ43UVZDH6TK4N"
 secret_key = "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"
}
resource "aws_key_pair" "reddy1" {
  key_name   = "reddy"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCshq/AyYtpUuTlt8Dp33RM3FclicelDl+70jiDksCM1kd/nYFwY2JdNMaNQH+v9h15YkK6ovulG2l/FqTZ9IoXbY19TPg+sI0r9RijKCBO13rjMyLPo7HK9S9f9zzaGUZz+9OtVH0lHqHgGSu9dfL40M1TLa9y7f9AIyFzrrJ557B67tISFhRA9Jk0ijCIen6rHahApVyRMGEaP2SdVgGWnhNC2Y1iAmAQ8dRqS62a4NCaBFRtH93ihraXwO6TbM0FJVL62qY4yFlc+foV37cMtl79rjISrSkSmE1VDjPrO/7WZKJ3hyDguv/nmDuGKWDLi2v2kChpIsisyasD/QTzpEKJN/cQqRop1JTrJPXwlqnvxDstC3b13itWkyxqAZDX8hYUPxrs/vFjLkrOz+TRaAyUfN0dbi9/BJ5dkCBUQWW3alhFsKZdexPS0PPY9gaV2tu+XI/PsNXOyu8pjKzNulReRYAfZtL3f8h85OOG6X7Y4G9IH9Pt13pRzxTL30E= sys@DESKTOP-T844E1R"
}

# AWS VPC
resource "aws_vpc" "reddy" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "reddy"
  }
}

# AWS SUBNET

resource "aws_subnet" "reddy-subnet-1" {
  vpc_id     = aws_vpc.reddy.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-east-1a"
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

#AWS INSTANCE
resource "aws_instance" "reddy-instance" {
  ami                     = "ami-0230bd60aa48260c6"
  instance_type           = "t2.micro"
  key_name                = aws_key_pair.reddy1.id
  
    tags = {
    Name = "reddy-instance"
  }
}

#EBS-VOLUME
resource "aws_ebs_volume" "reddy-volume" {
  availability_zone = "us-east-1a"
  size              = 10

  tags = {
    Name = "reddy-volume"
  }
}

#EBS-VOLUME-ATTACHMENT
resource "aws_volume_attachment" "elb-attachment" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.reddy-volume.id
  instance_id = aws_instance.reddy-instance.id
}

#AWS ELASTIC IP
resource "aws_eip" "reddy-eip" {
  domain   = "vpc"
}
#AWS ELASTIC IP ASSOSIATION
resource "aws_eip_association" "reddy-eip-assosiation" {
  instance_id   = aws_instance.reddy-instance.id
  allocation_id = aws_eip.reddy-eip.id
}

output "instance_id" {
 value = aws_instance.reddy-instance.id
}
output "volume_id" {
 value = aws_ebs_volume.reddy-volume.id
}
output "subnet_id" {
 value = aws_vpc.reddy.id
}
output "eip_id" {
 value = aws_eip.reddy-eip.id
}
output "subnet_az" {
 value = aws_subnet.reddy-subnet-1.availability_zone
}
