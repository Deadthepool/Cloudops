data "aws_iam_role" "github_actions_ecr" {
  name = "GitHubActions-ECR-Cloudops"
}

resource "aws_iam_policy" "cloudops_ssm_deploy" {
  name        = "CloudOpsSSMDeployPolicy"
  description = "Allows GitHub Actions to deploy CloudOps API through a restricted SSM document"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "RunCloudOpsDeploymentOnControlPlane"
        Effect = "Allow"
        Action = "ssm:SendCommand"
        Resource = [
          "arn:aws:ssm:ap-south-1:145400477016:document/CloudOpsDeployApi",
          "arn:aws:ec2:ap-south-1:145400477016:instance/i-0cb51ae1571643d04"
        ]
      },
      {
        Sid      = "ReadDeploymentCommandResults"
        Effect   = "Allow"
        Action   = "ssm:GetCommandInvocation"
        Resource = "*"
      }
    ]
  })

  tags = {
    Project   = "CloudOps"
    ManagedBy = "Terraform"
  }
}

resource "aws_iam_role_policy_attachment" "github_actions_ssm_deploy" {
  role       = data.aws_iam_role.github_actions_ecr.name
  policy_arn = aws_iam_policy.cloudops_ssm_deploy.arn
}
