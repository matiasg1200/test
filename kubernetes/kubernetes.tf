terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.48.0"
    }

    kubectl = {
      source = "gavinbunney/kubectl"
      version = "1.14.0"
    }
  }
}

data "terraform_remote_state" "eks" {
  backend = "local"

  config = {
    path = "../provision-eks-cluster/terraform.tfstate"
  }
}

# Retrieve EKS cluster information
provider "aws" {
  region = data.terraform_remote_state.eks.outputs.region
}

data "aws_eks_cluster" "cluster" {
  name = data.terraform_remote_state.eks.outputs.cluster_name
}

provider "kubectl" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = [
      "eks",
      "get-token",
      "--cluster-name",
      data.aws_eks_cluster.cluster.name
    ]
  }
}

#Create data objects for each namespaces
data "kubectl_file_documents" "argocd-namespace" {
    content = file("./namespaces/argocd-namespace.yaml")
} 

data "kubectl_file_documents" "echoserver-namespace" {
    content = file("./namespaces/echoserver-namespace.yaml")
}

data "kubectl_file_documents" "nginx-namespace" {
    content = file("./namespaces/nginx-namespace.yaml")
}

#Create data objects to install argocd
data "kubectl_file_documents" "argocd" {
    content = file("./argocd/install.yaml")
}

#Create data objects to deploy apps
data "kubectl_file_documents" "echoserver-app" {
    content = file("./argocd/apps/echoserver.yaml")
}

data "kubectl_file_documents" "statics-app" {
    content = file("./argocd/apps/statics.yaml")
}

#Create data objects to deploy ingress
data "kubectl_file_documents" "ingress" {
    content = file("./manifests/ingress.yaml")
}

#Apply namespaces
resource "kubectl_manifest" "argocd-namespace" {
    count     = length(data.kubectl_file_documents.argocd-namespace.documents)
    yaml_body = element(data.kubectl_file_documents.argocd-namespace.documents, count.index)
    
}

resource "kubectl_manifest" "echoserver-namespace" {
    count     = length(data.kubectl_file_documents.echoserver-namespace.documents)
    yaml_body = element(data.kubectl_file_documents.echoserver-namespace.documents, count.index)
    
}

resource "kubectl_manifest" "nginx-namespace" {
    count     = length(data.kubectl_file_documents.nginx-namespace.documents)
    yaml_body = element(data.kubectl_file_documents.nginx-namespace.documents, count.index)
    
}

#Install Argocd
resource "kubectl_manifest" "argocd" {
    depends_on = [
      kubectl_manifest.argocd-namespace,
    ]
    count     = length(data.kubectl_file_documents.argocd-namespace.documents)
    yaml_body = element(data.kubectl_file_documents.argocd-namespace.documents, count.index)
    
}

#Deploy apps
resource "kubectl_manifest" "echoserver-app" {
    depends_on = [
      kubectl_manifest.argocd,
    ]
    count     = length(data.kubectl_file_documents.echoserver-app.documents)
    yaml_body = element(data.kubectl_file_documents.echoserver-app.documents, count.index)
    override_namespace = "echoserver"
}

resource "kubectl_manifest" "statics-app" {
    depends_on = [
      kubectl_manifest.argocd,
    ]
    count     = length(data.kubectl_file_documents.statics-app.documents)
    yaml_body = element(data.kubectl_file_documents.statics-app.documents, count.index)
    override_namespace = "nginx"
}

#Deploy ingress
resource "kubectl_manifest" "ingress" {
    depends_on = [
      kubectl_manifest.echoserver-app,
      kubectl_manifest.statics-app,
    ]
    count     = length(data.kubectl_file_documents.ingress.documents)
    yaml_body = element(data.kubectl_file_documents.ingress.documents, count.index)
}