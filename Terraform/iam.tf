resource "aws_iam_role" "kubernetes_node" {
  name = "CloudOpsKubernetesNodeRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Project   = "cloudops"
    ManagedBy = "Terraform"
  }
}

resource "aws_iam_role_policy" "ecr_read" {
  name = "CloudOpsECRReadOnly"
  role = aws_iam_role.kubernetes_node.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken"
        ]

        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"

        ]

        Resource = "arn:aws:ecr:ap-south-1:145400477016:repository/cloudops-api"
      }
    ]
  })

}

resource "aws_iam_instance_profile" "kubernetes_node" {
  name = "CloudOpsKubernetesNodeProfile"
  role = aws_iam_role.kubernetes_node.name

  tags = {
    Project   = "CloudOps"
    ManagedBy = "Terraform"
  }
}

resource "aws_iam_role_policy_attachment" "ssm_managed_instance_core" {
  role       = aws_iam_role.kubernetes_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}