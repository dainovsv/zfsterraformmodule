resource "aws_db_instance" "ZFS_DB" {
  snapshot_identifier  = (var.snapshot_identifier_id != null) ? var.snapshot_identifier_id : null
  instance_class       = (var.snapshot_identifier_id != null) ? null : "db.t3.small"  
  allocated_storage    = (var.snapshot_identifier_id != null) ? null : 30  
  engine               = (var.snapshot_identifier_id != null) ? null : "sqlserver-ex"
  name                 = (var.snapshot_identifier_id != null) ? null : "ZFSPOCDB"
  username             = (var.snapshot_identifier_id != null) ? null : "admin" 
  password             = (var.snapshot_identifier_id != null) ? null : var.database_password 
  publicly_accessible = true
  db_subnet_group_name = aws_db_subnet_group.SUBNET_GROUP_FOR_RDS.name
  vpc_security_group_ids = [aws_security_group.LAUCH_WIZARD_ZFS_DB.id]
}

resource "aws_internet_gateway" "IGW_ZFS" {
  vpc_id = aws_vpc.VPC_ZFS.id
}

resource "aws_main_route_table_association" "VPC_ZFS" {
  route_table_id = aws_route_table.ROUTE_TABLE_ZFS.id
  vpc_id         = aws_vpc.VPC_ZFS.id
}

resource "aws_route_table" "ROUTE_TABLE_ZFS" {
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW_ZFS.id
  }

  vpc_id = aws_vpc.VPC_ZFS.id

  tags = {
    Terraform = "Yes"
  }
}


resource "aws_db_subnet_group" "SUBNET_GROUP_FOR_RDS" {
  name       = "zfssubnetgrouppoc"
  subnet_ids = [aws_subnet.SUBNET1.id, aws_subnet.SUBNET2.id]

  tags = {
    Terraform = "Yes"
  }
}




resource "aws_security_group" "LAUCH_WIZARD_ZFS_DB" {
  description = "launch-wizard-db"

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "0"
    protocol    = "-1"
    self        = "false"
    to_port     = "0"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "3389"
    protocol    = "tcp"
    self        = "false"
    to_port     = "3389"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "1433"
    protocol    = "tcp"
    self        = "false"
    to_port     = "1433"
  }

  name   = "launch-wizard-db"
  vpc_id = aws_vpc.VPC_ZFS.id

  tags = {
    Terraform = "Yes"
  }
}


resource "aws_subnet" "SUBNET1" {
  assign_ipv6_address_on_creation                = "false"
  cidr_block                                     = "172.31.16.0/20"
  enable_dns64                                   = "false"
  availability_zone                              = "eu-central-1a"
  enable_resource_name_dns_a_record_on_launch    = "false"
  enable_resource_name_dns_aaaa_record_on_launch = "false"
  ipv6_native                                    = "false"
  map_public_ip_on_launch             = "true"
  private_dns_hostname_type_on_launch = "ip-name"
  vpc_id                              = aws_vpc.VPC_ZFS.id

  tags = {
    Terraform = "Yes"
  }
}

resource "aws_subnet" "SUBNET2" {
  assign_ipv6_address_on_creation                = "false"
  cidr_block                                     = "172.31.32.0/20"
  availability_zone                              = "eu-central-1b"
  enable_dns64                                   = "false"
  enable_resource_name_dns_a_record_on_launch    = "false"
  enable_resource_name_dns_aaaa_record_on_launch = "false"
  ipv6_native                                    = "false"
  map_public_ip_on_launch             = "true"
  private_dns_hostname_type_on_launch = "ip-name"
  vpc_id                              = aws_vpc.VPC_ZFS.id

  tags = {
    Terraform = "Yes"
  }
}

resource "aws_subnet" "SUBNET3" {
  assign_ipv6_address_on_creation                = "false"
  cidr_block                                     = "172.31.0.0/20"
  availability_zone                              = "eu-central-1c"
  enable_dns64                                   = "false"
  enable_resource_name_dns_a_record_on_launch    = "false"
  enable_resource_name_dns_aaaa_record_on_launch = "false"
  ipv6_native                                    = "false"
  map_public_ip_on_launch             = "true"
  private_dns_hostname_type_on_launch = "ip-name"
  vpc_id                              = aws_vpc.VPC_ZFS.id

  tags = {
    Terraform = "Yes"
  }
}

resource "aws_vpc" "VPC_ZFS" {
  assign_generated_ipv6_cidr_block = "false"
  cidr_block                       = "172.31.0.0/16"
  enable_classiclink               = "false"
  enable_classiclink_dns_support   = "false"
  enable_dns_hostnames             = "true"
  enable_dns_support               = "true"
  instance_tenancy                 = "default"

  tags = {
    Terraform = "Yes"
  }
}


