data "terraform_remote_state" "eks" {
  backend = "local"

  config = {
    path = "../3.1-cluster/terraform.tfstate"
  }
}

data "aws_eks_cluster" "cluster" {
  name = data.terraform_remote_state.eks.outputs.cluster_name
}

data "aws_eks_cluster_auth" "aws_iam_authenticator" {
  name = data.aws_eks_cluster.cluster.name
}

# used in case of manual creation of service account, not by eks module
#data "tls_certificate" "example" {
#  url = data.terraform_remote_state.eks.outputs.cluster_oidc_issuer_url
#}