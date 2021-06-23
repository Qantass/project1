data "aws_availability_zones" "work" {}
data "aws_region" "current" {}
#data "aws_vpc" "task_vpc" {}

data "aws_ami" "latest_ubuntu" {
    owners = ["099720109477"]
    most_recent = true
    filter {
        name = "name"
        value = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
    }
}