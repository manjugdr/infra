resource "aws_security_group" "efs_sg" {
  name   = "${var.project_name}-${var.environment}-efssg"
  vpc_id = var.vpc_id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-efssg"
  }
}
resource "aws_security_group_rule" "efs_sg_ingress_rules" {
  for_each          = var.efssg_ingress_rules
  type              = "ingress"
  from_port         = each.value.from
  to_port           = each.value.to
  protocol          = each.value.proto
  cidr_blocks       = [each.value.cidr]
  description       = each.value.desc
  security_group_id = aws_security_group.efs_sg.id
}


