
resource "aws_security_group" "control_plane" {
  name        = "cloudops-kube-control-plane"
  description = "Restricted access for CloudOps Kubernetes control plane"
  vpc_id      = aws_vpc.cloudops.id

  egress {
    description = "Outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "cloudops-kube-control-plane"
    Project   = "CloudOps"
    ManagedBy = "Terraform"
  }
}

resource "aws_security_group" "worker" {
  name        = "cloudops-kube-worker"
  description = "Restricted access for CloudOps Kubernetes worker"
  vpc_id      = aws_vpc.cloudops.id

  egress {
    description = "Outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "cloudops-kube-worker"
    Project   = "CloudOps"
    ManagedBy = "Terraform"
  }
}

resource "aws_vpc_security_group_ingress_rule" "control_plane_ssh" {
  security_group_id = aws_security_group.control_plane.id
  description       = "SSH from administrator IP"
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = "210.18.128.88/32"
}

resource "aws_vpc_security_group_ingress_rule" "control_plane_api_admin" {
  security_group_id = aws_security_group.control_plane.id
  description       = "Kubernetes API from administrator IP"
  ip_protocol       = "tcp"
  from_port         = 6443
  to_port           = 6443
  cidr_ipv4         = "210.18.128.88/32"
}

resource "aws_vpc_security_group_ingress_rule" "worker_ssh" {
  security_group_id = aws_security_group.worker.id
  description       = "SSH from administrator IP"
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = "210.18.128.88/32"
}

resource "aws_vpc_security_group_ingress_rule" "worker_nodeport_admin" {
  security_group_id = aws_security_group.worker.id
  description       = "NodePort application access from administrator IP"
  ip_protocol       = "tcp"
  from_port         = 30000
  to_port           = 32767
  cidr_ipv4         = "210.18.128.88/32"
}

resource "aws_vpc_security_group_ingress_rule" "api_from_worker" {
  security_group_id            = aws_security_group.control_plane.id
  referenced_security_group_id = aws_security_group.worker.id
  description                  = "Kubernetes API from worker"
  ip_protocol                  = "tcp"
  from_port                    = 6443
  to_port                      = 6443
}

resource "aws_vpc_security_group_ingress_rule" "kubelet_from_control_plane" {
  security_group_id            = aws_security_group.worker.id
  referenced_security_group_id = aws_security_group.control_plane.id
  description                  = "Kubelet API from control plane"
  ip_protocol                  = "tcp"
  from_port                    = 10250
  to_port                      = 10250
}

resource "aws_vpc_security_group_ingress_rule" "control_plane_etcd" {
  security_group_id            = aws_security_group.control_plane.id
  referenced_security_group_id = aws_security_group.control_plane.id
  description                  = "etcd communication within control plane"
  ip_protocol                  = "tcp"
  from_port                    = 2379
  to_port                      = 2380
}

resource "aws_vpc_security_group_ingress_rule" "control_plane_kubelet" {
  security_group_id            = aws_security_group.control_plane.id
  referenced_security_group_id = aws_security_group.control_plane.id
  description                  = "Kubelet communication within control plane"
  ip_protocol                  = "tcp"
  from_port                    = 10250
  to_port                      = 10250
}

resource "aws_vpc_security_group_ingress_rule" "control_plane_scheduler" {
  security_group_id            = aws_security_group.control_plane.id
  referenced_security_group_id = aws_security_group.control_plane.id
  description                  = "Scheduler and controller manager within control plane"
  ip_protocol                  = "tcp"
  from_port                    = 10257
  to_port                      = 10259
}

resource "aws_vpc_security_group_ingress_rule" "flannel_from_control_plane" {
  security_group_id            = aws_security_group.worker.id
  referenced_security_group_id = aws_security_group.control_plane.id
  description                  = "Flannel VXLAN traffic from control plane"
  ip_protocol                  = "udp"
  from_port                    = 8472
  to_port                      = 8472
}

resource "aws_vpc_security_group_ingress_rule" "flannel_from_worker" {
  security_group_id            = aws_security_group.control_plane.id
  referenced_security_group_id = aws_security_group.worker.id
  description                  = "Flannel VXLAN traffic from worker"
  ip_protocol                  = "udp"
  from_port                    = 8472
  to_port                      = 8472
}

resource "aws_vpc_security_group_ingress_rule" "flannel_worker_self" {
  security_group_id            = aws_security_group.worker.id
  referenced_security_group_id = aws_security_group.worker.id
  description                  = "Flannel VXLAN traffic within worker group"
  ip_protocol                  = "udp"
  from_port                    = 8472
  to_port                      = 8472
}
