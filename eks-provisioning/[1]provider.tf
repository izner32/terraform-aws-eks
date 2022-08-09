/*
how-to-iac-with-aws

-> 1. configure provider: 3rd party service(aws,azure,etc.) you'll connect to
    -> 1.1 specify provider you will be using (e.g. aws)
    -> 1.2 [optional] specify version of terraform or the version of the provider
-> 2. configure network: specify virtual private network,firewall rule,etc. 
    -> 2.1. create vpc: virtual network dedicated to your account 
    -> 2.2. create internet gateway: allows communication between vpc and internet 
    -> 2.3. create subnet: range of ip addressess in your vpc; some resources lives on the subnet like ec2
        public subnet: can be accessed outside the vpc or be accessed by the internet 
        private subnet: cannot be accessed outside the vpc or cannot be accessed by the internet 
    -> 2.4. create nat gateway: enable instances in the private subnet to connect to internet but note that something/someone from internet can never access private instances, e.g. usecase: software installation inside an ec2 instance 
        2.4.1 -> assign an elastic ip to the nat gateway: elastic ip is a reserved public ip address 
    -> 2.5. create route table: determine where network traffic is directed, e.g. destination - 0.0.0.0/0, target - internetgateway | this means allow access from all public subnet(0.0.0.0/0) to internet gateway
        main route table 
        public subnet route table 
        private subnet route table: 
        
        -> 2.5.1 associate route table with subnet or vpc
    -> 2.6. create security group to allow ports 22,80,442  
    -> 2.7. create network interface: wtf is this  
        -> 2.7.1 assign an elastic ip to the network interface: elastic ip is a reserved public ip address    
-> 3. configure aws resource/service security: (IAM - policy(permission of user to aws specified resources/services), roles(collection of policy attached you can grant to users/groups), users(where you attach role), group(group of users))
    EKS (elastic kubernetes service)
        permission method 1: allow granting permission on kubernetes nodes directly in that case every k8 pod will get the same access to aws resources
            -> 3.1 create role 
                -> 3.1.1 create role meant for eks cluster 
                -> 3.1.2 create role meant for eks node group
            -> 3.2 create/attach policy 
                -> 3.2.1 (create then attach)/attach chosen policy to eks cluster role 
                -> 3.2.1 (create then attach)/attach chosen policy to eks node group role 
        permission method 2: allow granting permission based on the service acount used by the k8 pod 
            -> 3.1 create iam oidc provider 
                -> 3.1.1 create tls certificate for eks 
                -> 3.1.2 create iam oidc provider and attach the created tls certificate 
            -> 3.2 [optional] test the iam oidc provider before deploying autoscaler so as to save time 
                -> 3.2.1 create role 
                -> 3.2.2 create then attach policy to role  
-> 4. configure resource: aws services you'll use, in this case aws eks
    EKS 
        -> 4.1 create EKS cluster: cluster is basically where everything resides in k8
        -> 4.2 create EKS node group 
*/

# 1. create the aws provider
provider "aws" {
    region = "us-east-1"

    # iam account - account that'll connect to your aws 
    access_key = "asdf"
    secret_key = "asdf"
}

# 1.1 specify version of the provider 
terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 3.21"
        }
    }
}


