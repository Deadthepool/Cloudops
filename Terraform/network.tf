resource "aws_vpc" "cloudops" {
  cidr_block           = "10.20.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name      = "cloudops-kube-vpc"
    Project   = "cloudops"
    ManagedBy = "Terraform"
  }
}
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.cloudops.id
  cidr_block              = "10.20.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    name      = "cloudops-kube-public-a"
    Project   = "cloudops"
    ManagedBy = "Terraform"
  }


}

resource "aws_internet_gateway" "cloudops" {
  vpc_id = aws_vpc.cloudops.id

  tags = {
    Name      = "cloudops-kube-igw"
    Project   = "cloudops"
    ManagedBy = "Terraform"
  }

}

resource "aws_route_table" "cloudops" {
  vpc_id = aws_vpc.cloudops.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cloudops.id
  }
  tags = {
    Name      = "cloudops-kube-rt"
    Project   = "cloudops"
    ManagedBy = "Terraform"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.cloudops.id

}