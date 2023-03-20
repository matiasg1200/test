# Sysops test
This repo is a wip aimed to accomplish the tasks of the sysops test.

## EKS Infrastrecutre
Terraform code under the **provision-eks-cluster** directory uses the files from the [Learn Terraform - Provision an EKS Cluster](https://github.com/hashicorp/learn-terraform-provision-eks-cluster) repo as starting point adding *.tfvars files to distinguish deploys beteween different environemnts (dev, stage, production).

### Usage:
To deploy an EKS Cluster use terraform apply passing on the corresponding *.tfvars file for the target environemnt
> note that this project is using local terraform state at this point so after cloning the repo you will need to initialize terraform on your working directory.

For example: 

`terraform apply -var-file=dev.tfvars`

This will deploy a *dev-vpc* and a *dev-cluster* attached to it.

## Argo CD 


## Kubernetes
At this point the Kubernetes objects have not been added to the Terraform code yet so under the Kubernetes directory there are manifests for both applications (api-application is still wip)(nginx is not rounting requestes to /statics).

Once the EKS Cluster is running Kubernetes workloads can be deployed using `kubectl apply -f {desired_file}`. 

To connect to the Cluster update kube/config file running the following command:

`aws eks --region us-east-1 update-kubeconfig --name cluster_name`
>cluster_name will be one of: dev-cluster, stage-cluster or production-cluster

