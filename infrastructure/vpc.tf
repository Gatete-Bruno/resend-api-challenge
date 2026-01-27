# ============================================================================
# VPC
# ============================================================================

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-vpc"
    }
  )
}

# ============================================================================
# Internet Gateway
# ============================================================================

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-igw"
    }
  )
}

# ============================================================================
# Public Subnets
# ============================================================================

resource "aws_subnet" "public" {
  count                   = length(local.azs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.${count.index + 1}.0/24"
  availability_zone       = local.azs[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    local.common_tags,
    {
      Name                              = "${var.project_name}-public-subnet-${count.index + 1}"
      "kubernetes.io/role/elb"          = "1"
      "kubernetes.io/role/internal-elb" = "1"
    }
  )
}

# ============================================================================
# Elastic IPs for NAT Gateways
# ============================================================================

resource "aws_eip" "nat" {
  count  = var.enable_nat_gateway ? length(local.azs) : 0
  domain = "vpc"

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-eip-${count.index + 1}"
    }
  )

  depends_on = [aws_internet_gateway.main]
}

# ============================================================================
# NAT Gateways
# ============================================================================

resource "aws_nat_gateway" "main" {
  count         = var.enable_nat_gateway ? length(local.azs) : 0
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-nat-${count.index + 1}"
    }
  )

  depends_on = [aws_internet_gateway.main]
}

# ============================================================================
# Private Subnets
# ============================================================================

resource "aws_subnet" "private" {
  count             = length(local.azs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index + 101}.0/24"
  availability_zone = local.azs[count.index]

  tags = merge(
    local.common_tags,
    {
      Name                              = "${var.project_name}-private-subnet-${count.index + 1}"
      "kubernetes.io/role/internal-elb" = "1"
    }
  )
}

# ============================================================================
# Route Table for Public Subnets
# ============================================================================

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block      = "0.0.0.0/0"
    gateway_id      = aws_internet_gateway.main.id
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-public-rt"
    }
  )
}

# ============================================================================
# Route Table Associations for Public Subnets
# ============================================================================

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# ============================================================================
# Route Tables for Private Subnets
# ============================================================================

resource "aws_route_table" "private" {
  count  = var.enable_nat_gateway ? length(local.azs) : 0
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[count.index].id
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-private-rt-${count.index + 1}"
    }
  )
}

# ============================================================================
# Route Table Associations for Private Subnets
# ============================================================================

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = var.enable_nat_gateway ? aws_route_table.private[count.index].id : aws_route_table.public.id
}

# ============================================================================
# Security Group for EKS Control Plane
# ============================================================================

resource "aws_security_group" "eks_control_plane" {
  name        = "${var.project_name}-eks-control-plane-sg"
  description = "Security group for EKS control plane"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-eks-control-plane-sg"
    }
  )
}

# ============================================================================
# Security Group for EKS Nodes
# ============================================================================

resource "aws_security_group" "eks_nodes" {
  name        = "${var.project_name}-eks-nodes-sg"
  description = "Security group for EKS nodes"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "udp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-eks-nodes-sg"
    }
  )
}

# ============================================================================
# Allow EKS Control Plane to communicate with Nodes
# ============================================================================

resource "aws_security_group_rule" "eks_control_plane_to_nodes" {
  type                     = "ingress"
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_nodes.id
  source_security_group_id = aws_security_group.eks_control_plane.id
}
