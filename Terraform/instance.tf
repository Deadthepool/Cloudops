variable "ami_id" {
  description = "Amazon Linux 2023 AMI ID in ap-south-1"
  type        = string
  default     = "ami-0fc5120b2d80d4749"

}

variable "key_name" {
  description = "Existing ec2 key pair for SSH connection"
  type        = string
  default     = "cloudops-kube-lab"

}

resource "aws_instance" "control_plane" {
  ami                         = var.ami_id
  instance_type               = "t3.medium"
  key_name                    = var.key_name
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.control_plane.id]
  iam_instance_profile        = aws_iam_instance_profile.kubernetes_node.name
  associate_public_ip_address = true
  user_data                   = file("${path.module}/Modules/userdata.sh")

  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = {
    Name      = "cloudops-kube-control-plane"
    Project   = "CloudOps"
    Role      = "KubernetesControlPlane"
    ManagedBy = "Terraform"
  }
}

resource "aws_instance" "worker" {
  ami                         = var.ami_id
  instance_type               = "t3.medium"
  key_name                    = var.key_name
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.worker.id]
  iam_instance_profile        = aws_iam_instance_profile.kubernetes_node.name
  associate_public_ip_address = true
  user_data                   = file("${path.module}/Modules/userdata.sh")

  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = {
    Name      = "Cloudops-kube-worker"
    Project   = "CloudOps"
    Role      = "KubernetesWorker"
    ManagedBy = "terraform"
  }
}