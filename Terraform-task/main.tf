#----------------------- A  W  S ---------------------------
provider "aws" {
    profile = "terraform"
    region = "us-east-2"
}
#-------------------------EIP -------------------------------
resource "aws_eip" "static_sql"{
  instance = aws_instance.mysql.id
  
}
resource "aws_eip" "static_tom"{
  instance = aws_instance.tomcat.id
  
}

#------------------------------------------------------------------

resource "aws_instance" "mysql" {
    ami = data.aws_ami.latest_ubuntu.id      # Linux Ubuntu Server 20.04 LTS 
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.db.id]
    
    
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
    vpc_security_group_ids = [aws_security_group.db.id]
    
  tags = {
    Name = "TomCat Server"
  }

  lifecycle {
    create_before_destroy = true
  }
}

#---------------------- V  P  C -------------------------------
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "db_vpc"
  }
}
