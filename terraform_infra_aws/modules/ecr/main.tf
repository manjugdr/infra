# Iterate over the repository names to create each ECR repository
resource "aws_ecr_repository" "private_repo" {
  for_each = toset(var.repository_names)

  name = each.value
  
  image_scanning_configuration {
    scan_on_push = true
  }

  image_tag_mutability = "MUTABLE"
  tags = {
    Name = "${var.project_name}-${var.environment}-ecr-${each.value}"
  }
}
