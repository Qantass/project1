output "instance_ip" {
  description = "The public ip for ssh access"
  value       = aws_instance.tomcat.public_ip
}
output "data_aws_availability_zones" {
    value = data.aws_availability_zones.work.names
}
output "data_aws_region_name" {
    value = data.aws_region.current.name
}
output "data_latest_ubuntu_ami_id" {
    value = data.aws_ami.latest_ubuntu.id
}
#output "aws_eip" {
#  value = aws_eip.tomcat.public_ip
#}

