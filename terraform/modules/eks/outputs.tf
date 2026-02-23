# Name of the cluster
output "Brians_cluster" {
  value = aws_eks_cluster.this.name
}

# API endpoint for kubectl / cluster access
output "cluster_endpoint" {
  value = aws_eks_cluster.this.endpoint
}

# Security group automatically created for cluster
output "cluster_security_group_id" {
  value = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}

# IAM role ARN of the worker nodes
output "node_role_arn" {
  value = aws_iam_role.eks_node_role.arn

}
