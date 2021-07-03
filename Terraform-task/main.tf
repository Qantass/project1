#---------------------------------------------------------------
terraform {
  backend "s3" {
    bucket = "testingcreation"
    key    = "task.tfstate"
    region = "us-east-2"
    profile = "terraform"
  }
}

#---------------------------LOCALS------------------------------

locals {
  ssh_user = "ubuntu"
  key_name = "Taskkey"
  private_key_path = "`/var/lib/jenkins/Taskkey.pem"
}

#----------------------- A  W  S ---------------------------
provider "aws" {
    profile = "terraform"
    region = "us-east-2"
}


#---------------------- V  P  C -------------------------------
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Main VPC"
  }
}
#---------------------------SUBNET------------------------------------
resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.10.0/24"
  availability_zone = "us-east-2a"
  tags = {
    Name = "public-subnet"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.20.0/24"
  availability_zone = "us-east-2a"
  tags = {
    Name = "private-subnet"
  }
}
#-------------------------Network------------------------------
resource "aws_network_interface" "tomcat" {
  subnet_id   = aws_subnet.public.id
  private_ips = ["10.0.10.10"]

  tags = {
    Name = "tomcat_internal_network_interface"
  }
}

resource "aws_network_interface" "db" {
  subnet_id   = aws_subnet.private.id
  private_ips = ["10.0.20.10"]

  tags = {
    Name = "db_network_interface"
  }
}
#----------------------------GW-----------------------------
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Main GW"
  }
}
#-----------------------------EIP-------------------------------
resource "aws_eip" "nat_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.gw]
  tags = {
    Name = "NAT Gateway EIP"
  }
}
#resource "aws_eip" "tomcat" {
#  instance = aws_instance.tomcat.id
#  vpc      = true
#
#  associate_with_private_ip = "10.0.10.20"
#  depends_on                = [aws_internet_gateway.gw]
#}
#resource "aws_eip" "db" {
#  instance = aws_instance.db.id
# vpc      = true
#  associate_with_private_ip = "10.0.20.20"
#  depends_on                = [aws_internet_gateway.gw]
# tags = {
#    Name = "db Gateway EIP"
#  }
#}
#-----------------------------NAT-----------------------------------
resource "aws_nat_gateway" "nat"{
  allocation_id = aws_eip.nat_eip.id
  subnet_id = aws_subnet.public.id

  tags = {
    Name = "Main NAT Gateway"
  }
}
#---------------------------Route table ----------------------------
#----------------------------PUBLIC---------------------------------
resource "aws_route_table" "public"{
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "Public Route Table"
  }
}
resource "aws_route_table_association" "public"{
  subnet_id = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}
#------------------------PRIVATE------------------------------------
resource "aws_route_table" "private"{
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat.id
  }
  tags = {
    Name = "Private Route Table"
  }
}
resource "aws_route_table_association" "private"{
  subnet_id = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

#------------------ SECURITY GROUP ----------------------------------------
resource "aws_security_group" "db" {
  name = "DB_Security_group"
  description = "My DB_Security_group"
  vpc_id = aws_vpc.main.id

  dynamic "ingress" {
      for_each = ["3306", "22"]
      content {
          from_port =ingress.value
          to_port = ingress.value
          protocol = "tcp"
          cidr_blocks = ["10.0.0.0/16"]

        }
}
   ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "tomcat" {
  name = "TomCAT_Security_group"
  description = "My TomCAT_Security_group"
  vpc_id = aws_vpc.main.id

  dynamic "ingress" {
      for_each = ["80", "8080", "22"]
      content {
          from_port =ingress.value
          to_port = ingress.value
          protocol = "tcp"
          cidr_blocks = ["0.0.0.0/0"]

        }
}
   ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



#---------------------------SERVER---------------------------------------

resource "aws_instance" "db" {
    ami = data.aws_ami.latest_ubuntu.id      # Linux Ubuntu Server 20.04 LTS 
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.db.id]
    subnet_id   = aws_subnet.private.id
    associate_public_ip_address = true
    private_ip = "10.0.20.20"
    key_name = local.key_name
  
  tags = {
    Name = "MySQL Server"
  }

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_instance" "tomcat" {
    ami = data.aws_ami.latest_ubuntu.id      # Linux Ubuntu Server 20.04 LTS
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.tomcat.id]
    subnet_id   = aws_subnet.public.id
    associate_public_ip_address = true
    private_ip = "10.0.10.20"
    key_name = local.key_name
  
    
  tags = {
    Name = "TomCat Server"
  }

  lifecycle {
    create_before_destroy = true
  }
}
