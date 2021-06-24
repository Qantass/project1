#----------------------- A  W  S ---------------------------
provider "aws" {
    profile = "terra"
    region = "us-east-2"
}


#---------------------- V  P  C -------------------------------
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "db_vpc"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.10.0/24"
  availability_zone = "us-east-2a"
  tags = {
    Name = "tomcat-subnet"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.20.0/24"
  availability_zone = "us-east-2a"
  tags = {
    Name = "db-subnet"
  }
}

resource "aws_network_interface" "tomcat" {
  subnet_id   = aws_subnet.public_subnet.id
  private_ips = ["10.0.10.10"]

  tags = {
    Name = "tomacat_internal_network_interface"
  }
}

resource "aws_network_interface" "db" {
  subnet_id   = aws_subnet.private_subnet.id
  private_ips = ["10.0.20.10"]

  tags = {
    Name = "db_network_interface"
  }
}
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_eip" "tomcat" {
  instance = aws_instance.tomcat.id
  vpc      = true

  associate_with_private_ip = "10.0.10.20"
  depends_on                = [aws_internet_gateway.gw]
}
resource "aws_eip" "db" {
  instance = aws_instance.db.id
  vpc      = true

  associate_with_private_ip = "10.0.20.20"
  depends_on                = [aws_internet_gateway.gw]
}
#------------------ SECURITY GROUP ----------------------------------------
resource "aws_security_group" "db" {
  name = "DB_Security_group"
  description = "My DB_Security_group"
  vpc_id = "${aws_vpc.main.id}"

  dynamic "ingress" {
      for_each = ["3306"]
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
  vpc_id = "${aws_vpc.main.id}"

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



#------------------------------------------------------------------

resource "aws_instance" "mysql" {
    ami = data.aws_ami.latest_ubuntu.id      # Linux Ubuntu Server 20.04 LTS 
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.db.id]
    subnet_id   = aws_subnet.private_subnet.id
    private_ip = "10.0.20.20"
    key_name = aws_key_pair.id_rsa.id
  
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
    subnet_id   = aws_subnet.public_subnet.id
    private_ip = "10.0.10.20"
    key_name = aws_key_pair.id_rsa.id
  
    
  tags = {
    Name = "TomCat Server"
  }

  lifecycle {
    create_before_destroy = true
  }
}

