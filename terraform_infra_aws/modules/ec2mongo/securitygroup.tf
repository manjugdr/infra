resource "aws_security_group" "ec2mongo_sg" {
  name   = "${var.project_name}-${var.environment}-ec2mongosg"
  vpc_id = var.vpc_id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-ec2mongosg"
  }
}

# Dynamically add the SSH rule based on the fetched EC2 private IP
locals {
  ec2mongosg_ingress_rules_with_ssh = merge(
    var.ec2mongosg_ingress_rules,
    { ssh_from_all = { from = 22, to = 22, proto = "tcp", cidr = "${var.bastionhost_privateip}/32", desc = "Allow SSH only from bastionhost" } }
  )
}

resource "aws_security_group_rule" "ec2mongo_sg_ingress_rules" {
  for_each          = local.ec2mongosg_ingress_rules_with_ssh
  type              = "ingress"
  from_port         = each.value.from
  to_port           = each.value.to
  protocol          = each.value.proto
  cidr_blocks       = [each.value.cidr]
  description       = each.value.desc
  security_group_id = aws_security_group.ec2mongo_sg.id
}