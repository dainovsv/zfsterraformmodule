module "network_and_db_mod" {
  source = "./db-module"
  snapshot_identifier_id = var.snapshot_identifier_id
  database_password = var.database_password
}

resource "aws_autoscaling_group" "SimpleZFSAutoSaclingGroup" {
  capacity_rebalance        = "false"
  default_cooldown          = "300"
  desired_capacity          = "1"
  force_delete              = "false"
  health_check_grace_period = "300"
  health_check_type         = "EC2"

  # launch_template {
  #   id      = aws_launch_template.ZFSSimpleAppTemplate.id
  #   version = "$Latest"
  # }
  launch_configuration      = aws_launch_configuration.ZFS_LAUNCH_CONFIGURATION.id
  max_instance_lifetime     = "0"
  max_size                  = "1"
  metrics_granularity       = "1Minute"
  min_size                  = "1"
  name                      = "SimpleZFSAutoSaclingGroup"
  protect_from_scale_in     = "false"
  target_group_arns         = [aws_lb_target_group.ALB_ZFS_TARGET_GROUP.arn]
  vpc_zone_identifier       = [module.network_and_db_mod.subnet1_ID, module.network_and_db_mod.subnet2_ID]
  wait_for_capacity_timeout = "10m"


}



resource "aws_launch_configuration" "ZFS_LAUNCH_CONFIGURATION" {
  name_prefix     = "ZFS_LAUNCH_CONFIGURATION"
  image_id        = var.image_id
  instance_type   = "t2.small"
  security_groups = [aws_security_group.LAUCH_WIZARD_ZFS.id]
  key_name        = var.keypair_name
  user_data       = <<EOF
         <script>
           echo Current date and time >> %SystemRoot%\Temp\test.log
           echo %DATE% %TIME% >> %SystemRoot%\Temp\test.log
           json -I -f %SystemRoot%/../inetpub/wwwroot/ZFSsampleApp/appsettings.json -e "this.ConnectionStrings.DefaultConnection='Server=${module.network_and_db_mod.db_endpoint};Database=aspnet-ZFSWebAppPOC-8A6458F2-6992-47F2-9B57-CE6120E89588;User Id=admin;Password=ZurichINS;'"
           </script>
         <persist>true</persist>
    EOF
}






# resource "aws_launch_template" "ZFSSimpleAppTemplate" {
#   default_version         = "1"
#   image_id                = var.image_id
#   instance_type           = "t2.small"
#   key_name                = "zfs"
#   name                    = "ZFSSimpleAppTemplate"
#   security_group_names  = [aws_security_group.LAUCH_WIZARD_ZFS.name]

#    capacity_reservation_specification {
#     capacity_reservation_preference = "open"
#   }

#   cpu_options {
#     core_count       = 4
#     threads_per_core = 2
#   }

#   credit_specification {
#     cpu_credits = "standard"
#   }

#   disable_api_termination = true

#   ebs_optimized = true

#   metadata_options {
#     http_endpoint               = "enabled"
#     http_tokens                 = "required"
#     http_put_response_hop_limit = 1
#     instance_metadata_tags      = "enabled"
#   }

#   monitoring {
#     enabled = true
#   }

#   network_interfaces {
#     associate_public_ip_address = true
#   }

#   #placement {
#   #  availability_zone = "us-west-2a"
#   #}

#   instance_initiated_shutdown_behavior = "terminate"


# }

resource "aws_lb" "ALB_ZFS" {
  desync_mitigation_mode     = "defensive"
  drop_invalid_header_fields = "false"
  enable_deletion_protection = "false"
  enable_http2               = "true"
  enable_waf_fail_open       = "false"
  idle_timeout               = "60"
  internal                   = "false"
  ip_address_type            = "ipv4"
  load_balancer_type         = "application"
  name                       = "SimpleZFSAutoSaclingGroup-1"
  security_groups            = [aws_security_group.LAUCH_WIZARD_ZFS.id]


  subnets = [module.network_and_db_mod.subnet1_ID, module.network_and_db_mod.subnet2_ID]

  tags = {
    Terraform = "Yes"
  }
}

resource "aws_lb_listener" "ALB_ZFS_LISTENER" {
  default_action {
    target_group_arn = aws_lb_target_group.ALB_ZFS_TARGET_GROUP.arn
    type             = "forward"
  }

  load_balancer_arn = aws_lb.ALB_ZFS.arn
  port              = "80"
  protocol          = "HTTP"

  tags = {
    Terraform = "Yes"
  }
}

resource "aws_lb_target_group" "ALB_ZFS_TARGET_GROUP" {
  deregistration_delay = "300"

  health_check {
    enabled             = "true"
    healthy_threshold   = "5"
    interval            = "30"
    matcher             = "200"
    path                = "/"
    port                = "80"
    protocol            = "HTTP"
    timeout             = "5"
    unhealthy_threshold = "5"
  }

  load_balancing_algorithm_type = "round_robin"
  name                          = "SimpleZFSAutoSaclingGroup-1"
  port                          = "80"
  protocol                      = "HTTP"
  protocol_version              = "HTTP1"
  slow_start                    = "0"

  stickiness {
    cookie_duration = "86400"
    enabled         = "false"
    type            = "lb_cookie"
  }

  target_type = "instance"
  vpc_id      = module.network_and_db_mod.vpc_ID

  tags = {
    Terraform = "Yes"
  }
}



resource "aws_network_acl" "ZFS_ACL" {
  egress {
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = "0"
    icmp_code  = "0"
    icmp_type  = "0"
    protocol   = "-1"
    rule_no    = "100"
    to_port    = "0"
  }

  ingress {
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = "0"
    icmp_code  = "0"
    icmp_type  = "0"
    protocol   = "-1"
    rule_no    = "100"
    to_port    = "0"
  }

  subnet_ids = [module.network_and_db_mod.subnet2_ID, module.network_and_db_mod.subnet3_ID, module.network_and_db_mod.subnet1_ID]
  vpc_id     = module.network_and_db_mod.vpc_ID


  tags = {
    Terraform = "Yes"
  }
}

resource "aws_network_interface" "ALB_ENI_1" {
  description        = "ELB app/SimpleZFSAutoSaclingGroup-1/3f1c9137a6b527fa"
  ipv4_prefix_count  = "0"
  ipv6_address_count = "0"
  ipv6_prefix_count  = "0"
  private_ip         = "172.31.11.50"
  security_groups    = [aws_security_group.LAUCH_WIZARD_ZFS.id]
  source_dest_check  = "true"
  subnet_id          = module.network_and_db_mod.subnet1_ID
}

# resource "aws_network_interface" "RDS_ENI" {
#   description = "RDSNetworkInterface"
#   #interface_type     = "interface"
#   ipv4_prefix_count  = "0"
#   ipv6_address_count = "0"
#   ipv6_prefix_count  = "0"
#   private_ip         = "172.31.46.43"
#   security_groups    = [aws_security_group.LAUCH_WIZARD_ZFS.id]
#   source_dest_check  = "true"
#   subnet_id          = data.terraform_remote_state.local.outputs.aws_subnet_SUBNET1_id
# }

resource "aws_network_interface" "ALB_ENI_2" {
  ipv4_prefix_count  = "0"
  ipv6_address_count = "0"
  ipv6_prefix_count  = "0"
  private_ip         = "172.31.22.43"
  security_groups    = [aws_security_group.LAUCH_WIZARD_ZFS.id]
  source_dest_check  = "true"
  subnet_id          = module.network_and_db_mod.subnet2_ID
}

resource "aws_network_interface" "ALB_ENI_3" {
  description = "ELB app/SimpleZFSAutoSaclingGroup-1/3f1c9137a6b527fa"
  #interface_type     = "interface"
  ipv4_prefix_count  = "0"
  ipv6_address_count = "0"
  ipv6_prefix_count  = "0"
  private_ip         = "172.31.28.119"
  security_groups    = [aws_security_group.LAUCH_WIZARD_ZFS.id]
  source_dest_check  = "true"
  subnet_id          = module.network_and_db_mod.subnet3_ID
}





resource "aws_security_group" "LAUCH_WIZARD_ZFS" {
  description = "launch-wizard-2"

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
    from_port   = "443"
    protocol    = "tcp"
    self        = "false"
    to_port     = "443"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "80"
    protocol    = "tcp"
    self        = "false"
    to_port     = "80"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "8172"
    protocol    = "tcp"
    self        = "false"
    to_port     = "8172"
  }

  name   = "launch-wizard-2"
  vpc_id = module.network_and_db_mod.vpc_ID

  tags = {
    Terraform = "Yes"
  }
}



