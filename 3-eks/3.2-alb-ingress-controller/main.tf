provider "aws" {
  region = data.terraform_remote_state.eks.outputs.region
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.aws_iam_authenticator.token
}

module "load_balancer_controller" {
  source = "git::https://github.com/DNXLabs/terraform-aws-eks-lb-controller.git"

  cluster_identity_oidc_issuer     = data.terraform_remote_state.eks.outputs.cluster_oidc_issuer_url
  cluster_identity_oidc_issuer_arn = data.terraform_remote_state.eks.outputs.oidc_provider_arn
  cluster_name                     = data.terraform_remote_state.eks.outputs.cluster_name

}

# used in case of manual creation of service account, not by eks module
# Based on: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster#example-iam-role-for-eks-cluster

## to let k8s work with AWS resources
#resource "aws_iam_openid_connect_provider" "example" {
#  client_id_list  = ["sts.amazonaws.com"]
#  thumbprint_list = [data.tls_certificate.example.certificates[0].sha1_fingerprint]
#  url             = data.terraform_remote_state.eks.outputs.cluster_oidc_issuer_url
#}
#
## who can assume role
#data "aws_iam_policy_document" "example_assume_role_policy" {
#  statement {
#    actions = ["sts:AssumeRoleWithWebIdentity"]
#    effect  = "Allow"
#
#    condition {
#      test     = "StringEquals"
#      variable = "${replace(aws_iam_openid_connect_provider.example.url, "https://", "")}:sub"
#      values   = ["system:serviceaccount:kube-system:aws-node"]
#    }
#
#    principals {
#      identifiers = [aws_iam_openid_connect_provider.example.arn]
#      type        = "Federated"
#    }
#  }
#}
#
## role to work with AWS resources that will be linked to k8s service account
#resource "aws_iam_role" "role_for_k8s_ingress_controller" {
#  assume_role_policy = data.aws_iam_policy_document.example_assume_role_policy.json
#  name               = "role_for_k8s_ingress_controller"
#}
#
#resource "aws_iam_policy" "policy_for_k8s_ingress_controller" {
#  name        = "policy_for_k8s_ingress_controller"
#  description = "from https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.3/deploy/installation/"
#  policy      = file("iam-policy.json")
#}
#
#resource "aws_iam_role_policy_attachment" "role_and_policy_attach" {
#  role       = aws_iam_role.role_for_k8s_ingress_controller.id
#  policy_arn = aws_iam_policy.policy_for_k8s_ingress_controller.arn
#}
#
#resource "kubernetes_service_account" "example" {
#  metadata {
#    name        = "aws-alb-ingress-controller"
#    annotations = {
#      "eks.amazonaws.com/role-arn" : "${aws_iam_role.role_for_k8s_ingress_controller.arn}"
#    }
#  }
#}



