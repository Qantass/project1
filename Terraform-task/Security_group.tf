#------------------ SECURITY GROUP ----------------------------------------
resource "aws_security_group" "db" {
  name = "DB_Security_group"
  description = "My DB_Security_group"
  vpc_id = "${aws_vpc.main.id}"

  dynamic "ingress" {
      for_each = ["80", "8080", "3360"]
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