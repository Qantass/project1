output "MySQL_server_public_ip" {
    value = aws_eip.static_sql.public_ip
}
output "TomCat_server_public_ip" {
    value = aws_eip.static_tom.public_ip
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