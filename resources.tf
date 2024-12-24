# Create a VPC
resource "aws_vpc" "my_vpc" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = var.vpc_tenancy
  tags = var.vpc_tags
}

#created subnet
resource "aws_subnet" "public_subnet-1" {
  vpc_id  = aws_vpc.my_vpc.id
  cidr_block = "30.20.1.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]  

  tags = {

    Name = "public Subnet1 in AZ1"

  }
 
  }

resource "aws_subnet" "public_subnet-2" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "30.20.2.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]  

  tags = {

    Name = "public Subnet2 in AZ2"

  }
}

resource "aws_subnet" "private_subnet-1" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "30.20.3.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]  

  tags = {

    Name = "private Subnet1 in AZ1"

  }
}

resource "aws_subnet" "private_subnet-2" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "30.20.4.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]  

  tags = {

    Name = "private Subnet2 in AZ2"

  }
}

#create internate gatway
resource "aws_internet_gateway" "igw"{
    vpc_id = aws_vpc.my_vpc.id
}

#create publicRT
resource "aws_route_table" "publicRT"{
    vpc_id = aws_vpc.my_vpc.id
     route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    } 
tags ={
    name=   "RT for internate getway"
  }
}  

#create Associate for route table to  subnet for public subnet
resource "aws_route_table_association" "publicRT_assoc_subnet1" {
    subnet_id = aws_subnet.public_subnet-1.id
    route_table_id = aws_route_table.publicRT.id
  
}

resource "aws_route_table_association" "publicRT_assoc_subnet2" {
    subnet_id = aws_subnet.public_subnet-2.id
    route_table_id = aws_route_table.publicRT.id
  
}

#create elastic ip
resource "aws_eip" "ngw_eip1" {
  depends_on = [ aws_internet_gateway.igw ]
}

#create elastic ip
resource "aws_eip" "ngw_eip2" {
  depends_on = [ aws_internet_gateway.igw ]
}

#create NAT gateway in public subnet1
resource "aws_nat_gateway" "ngw_ps1" {
    allocation_id = aws_eip.ngw_eip1.id
    subnet_id = aws_subnet.public_subnet-1.id
    depends_on = [ aws_eip.ngw_eip1 ]
}

#create NAT gateway in public subnet2
resource "aws_nat_gateway" "ngw_ps2" {
    allocation_id = aws_eip.ngw_eip2.id
    subnet_id = aws_subnet.public_subnet-2.id
    depends_on = [ aws_eip.ngw_eip2 ]
}

#create private subnet1 route table
resource "aws_route_table" "privateRT_subnet1" {
    vpc_id = aws_vpc.my_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.ngw_ps1.id
    }
  tags ={
    name=   "private_RT_subnet_1"
  }
}

#Associate private route table to private subnet1
resource "aws_route_table_association" "privateRT_subnet1_associate" {
  subnet_id = aws_subnet.private_subnet-1.id
  route_table_id = aws_route_table.privateRT_subnet1.id
}

#create private subnet2 route table
resource "aws_route_table" "privateRT_subnet2" {
    vpc_id = aws_vpc.my_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.ngw_ps2.id
    }
  tags ={
    name=   "private_RT_subnet_2"
  }
}

#Associate private route table to private subnet2
resource "aws_route_table_association" "privateRT_subnet2_associate" {
  subnet_id = aws_subnet.private_subnet-2.id
  route_table_id = aws_route_table.privateRT_subnet2.id
}