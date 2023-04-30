### WIP

# EKS - ArgoCD
The goal of this project is to deploy an EKS cluster with ArgoCD and two sample web apps using Terraform. 

## Terraform Workflow
Current Terraform workflow is divided into two steps:

    1. Deploy EKS Cluster -> provision-eks-cluster/main.tf
    2. Install ArgoCD and deploy statics and api applications -> kubernetes/kubernetes.tf

## EKS Infrastrecutre
Terraform code under the **provision-eks-cluster** directory uses the files from the [Learn Terraform - Provision an EKS Cluster](https://github.com/hashicorp/learn-terraform-provision-eks-cluster) repo as starting point adding *.tfvars files to distinguish deploys beteween different environemnts (dev, stage, production).

### Usage:
To deploy an EKS Cluster use terraform apply passing on the corresponding *.tfvars file for the target environemnt
> note that this project is using local terraform state at this point so after cloning the repo you will need to initialize terraform on your working directory.

For example: 

`terraform apply -var-file=dev.tfvars`

This will deploy a *dev-vpc* and a *dev-cluster* attached to it.

## Kubernetes
Terraform code under the **kubernetes** directory deploys and install [ArgoCD](https://argoproj.github.io/cd/) on the Cluster and deploys an ingress controller to route requests between the statics and api services.
This configuration uses the [Kubectl provider](https://registry.terraform.io/providers/gavinbunney/kubectl/latest) provider and `terraform_remote_state` pointing at the Terraform resoruces deployed during EKS Cluster creation.

### Connect to the Cluster
To connect to the Cluster update kube/config file running the following command:

`aws eks --region us-east-1 update-kubeconfig --name cluster_name`
>cluster_name will be one of: dev-cluster, stage-cluster or production-cluster

