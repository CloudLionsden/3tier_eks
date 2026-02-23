##########################################################
# IAM ROLE FOR EKS CLUSTER
##########################################################

# EKS cluster requires an IAM role so that the cluster itself can manage AWS resources
# This role is assumed by the EKS service
resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.cluster_name}-role"

  # Trust policy: allows EKS to assume this role
  assume_role_policy = data.aws_iam_policy_document.eks_assume_role.json
}

# Create the trust relationship policy for EKS
data "aws_iam_policy_document" "eks_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]                     # Allows service to assume role
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]           # EKS service can assume this role
    }
  }
}

# Attach necessary AWS managed policies to the cluster role
# These policies allow EKS to manage resources in your VPC
resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSVPCResourceController" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}

##########################################################
# EKS CLUSTER
##########################################################

# This is the Kubernetes control plane (master nodes) managed by AWS
# It runs in private subnets to improve security
resource "aws_eks_cluster" "this" {
  name     = var.cluster_name                   # Name of the EKS cluster
  role_arn = aws_iam_role.eks_cluster_role.arn # IAM role created above

  # Tell EKS which subnets the worker nodes will run in
  vpc_config {
    subnet_ids = var.private_subnet_ids        # Only private app subnets
  }

  # Ensure IAM roles are created before cluster
  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy
  ]
}

##########################################################
# IAM ROLE FOR NODE GROUP (WORKER NODES)
##########################################################

# Nodes need an IAM role so they can register with the cluster and access AWS resources
resource "aws_iam_role" "eks_node_role" {
  name = "${var.cluster_name}-node-role"

  # EC2 instances will assume this role
  assume_role_policy = data.aws_iam_policy_document.eks_node_assume_role.json
}

# Trust relationship for worker nodes (EC2 instances)
data "aws_iam_policy_document" "eks_node_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]      # EC2 instances can assume this role
    }
  }
}

# Attach AWS managed policies to nodes
# Required for them to communicate with cluster and pull Docker images
resource "aws_iam_role_policy_attachment" "node_AmazonEKSWorkerNodePolicy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKS_CNI_Policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "node_AmazonEC2ContainerRegistryReadOnly" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

##########################################################
# MANAGED NODE GROUP
##########################################################

# Node group runs the actual Kubernetes worker nodes (EC2 instances)
# These nodes will run your containers (app tier)
resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.this.name   # Which cluster to join
  node_group_name = "${var.cluster_name}-nodes"
  node_role_arn   = aws_iam_role.eks_node_role.arn  # Role nodes assume
  subnet_ids      = var.private_subnet_ids          # Run only in private app subnets

  scaling_config {
    desired_size = 2  # Start with 2 nodes
    min_size     = 1  # Minimum nodes for scaling down
    max_size     = 3  # Maximum nodes for scaling up
  }

  # Ensure IAM role exists before creating nodes
  depends_on = [
    aws_iam_role_policy_attachment.node_AmazonEKSWorkerNodePolicy
  ]
}
