output "db_endpoint" {
  value = trimsuffix(aws_db_instance.ZFS_DB.endpoint, ":1433")
}

output "subnet1_ID" {
  value = aws_subnet.SUBNET1.id
}

output "subnet2_ID" {
  value = aws_subnet.SUBNET2.id
}

output "subnet3_ID" {
  value = aws_subnet.SUBNET3.id
}

output "vpc_ID" {
  value = aws_vpc.VPC_ZFS.id
}