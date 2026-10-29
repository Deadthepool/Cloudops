
resource "aws_ssm_document" "cloudops_deploy_api" {
  name            = "CloudOpsDeployApi"
  document_type   = "Command"
  document_format = "JSON"

  content = file("${path.module}/Modules/ssm-deploy-document.json")
}
