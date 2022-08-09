# 2.1 create vpc 
resource "aws_vpc" "prod-vpc" {
    cidr_block = "10.0.0.0/16"
    instance_tenancy = "default" # there are three options: shared(default) - multiple aws accounts may share the same physical hardware, dedicated - instance runs on single-tenant hardware but changes on reboot, dedicated host - most expensive, instance runs on single-tenant hardware and does not change despite reboot 

    # required for eks, that's all you need to know 
    enable_dns_support = true 
    enable_dns_hostnames = true 

    # defaults, that's all you need to know 
    enable_classiclink = false 
    enable_classiclink_dns_support = false 

    tags = {
        Name = "prod-vpc"
    }
}

# 2.2 create internet gateway 
resource "aws_internet_gateway" "gw" {
    vpc_id = aws_vpc.prod-vpc.id

    tags = {
        Name = "internet-gateway"
    }
}

# 2.3 create route table for public subnet
resource "aws_route_table" "public" {
    # The VPC ID.
    vpc_id = aws_vpc.main.id

    route {
        # The CIDR block of the route.
        cidr_block = "0.0.0.0/0"

        # Identifier of a VPC internet gateway or a virtual private gateway.
        gateway_id = aws_internet_gateway.main.id
    }

    # A map of tags to assign to the resource.
    tags = {
        Name = "public"
    }
}

# 2.3 create route table for private subnet 1
resource "aws_route_table" "private1" {
    # The VPC ID.
    vpc_id = aws_vpc.main.id

    route {
        # The CIDR block of the route.
        cidr_block = "0.0.0.0/0"

        # Identifier of a VPC NAT gateway.
        nat_gateway_id = aws_nat_gateway.gw1.id
    }

    # A map of tags to assign to the resource.
    tags = {
        Name = "private1"
    }
}

# 2.3 create route table for private subnet 2
resource "aws_route_table" "private2" {
    # The VPC ID.
    vpc_id = aws_vpc.main.id

    route {
        # The CIDR block of the route.
        cidr_block = "0.0.0.0/0"

        # Identifier of a VPC NAT gateway.
        nat_gateway_id = aws_nat_gateway.gw2.id
    }

    # A map of tags to assign to the resource.
    tags = {
        Name = "private2"
    }
}

# 2.4 create subnet - public 1 
resource "aws_subnet" "public-subnet-1" {
    vpc_id = aws_vpc.prod-vpc.id 
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1a" # hardcode value for this since aws would choose one for you if you don't 

    # required for eks - instances launched into the subnet should be assigned a public ip address 
    map_public_ip_on_launch = true 

    tags = {
        Name                        = "public-us-east-1a"
        "kubernetes.io/cluster/eks" = "shared"
        "kubernetes.io/role/elb"    = 1
    }
}

# 2.4 create subnet - public 2
resource "aws_subnet" "public-subnet-2" {
    vpc_id = aws_vpc.prod-vpc.id 
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1b" # hardcode value for this since aws would choose one for you if you don't 

    # required for eks - instances launched into the subnet should be assigned a public ip address 
    map_public_ip_on_launch = true 

    tags = {
        Name                        = "public-us-east-1b"
        "kubernetes.io/cluster/eks" = "shared"
        "kubernetes.io/role/elb"    = 1
    }
}

# 2.4 create subnet - private 1 
resource "aws_subnet" "private-subnet-1" {
    vpc_id = aws_vpc.prod-vpc.id 
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1a" # hardcode value for this since aws would choose one for you if you don't 

    # required for eks - instances launched into the subnet should be assigned a public ip address 
    map_public_ip_on_launch = true 

    tags = {
        Name                              = "private-us-east-1a"
        "kubernetes.io/cluster/eks"       = "shared"
        "kubernetes.io/role/internal-elb" = 1
    }
}

# 2.4 create subnet - private 2 
resource "aws_subnet" "private-subnet-2" {
    vpc_id = aws_vpc.prod-vpc.id 
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1b" # hardcode value for this since aws would choose one for you if you don't 

    # required for eks - instances launched into the subnet should be assigned a public ip address 
    map_public_ip_on_launch = true 

    tags = {
        Name                              = "private-us-east-1b"
        "kubernetes.io/cluster/eks"       = "shared"
        "kubernetes.io/role/internal-elb" = 1
    }
}

# 2.4.1 associate public subnet 1 with dedicated route table for public subnet
resource "aws_route_table_association" "public1" {
  subnet_id = aws_subnet.public_1.id

  route_table_id = aws_route_table.public.id
}

# 2.4.1 associate public subnet 2 with dedicated route table for public subnet
resource "aws_route_table_association" "public2" {
  subnet_id = aws_subnet.public_2.id

  route_table_id = aws_route_table.public.id
}

# 2.4.1 associate private subnet 1 with dedicated route table for private subnet 1
resource "aws_route_table_association" "private1" {
  subnet_id = aws_subnet.private_1.id

  route_table_id = aws_route_table.private1.id
}

# 2.4.1 associate private subnet 1 with dedicated route table for private subnet 2
resource "aws_route_table_association" "private2" {
  subnet_id = aws_subnet.private_2.id

  route_table_id = aws_route_table.private2.id
}

# 2.5 create nat gateway 1 for public subnet 1  
resource "aws_nat_gateway" "nat-gw-1" {
    # eip you will assign to the nat gateway 
    allocation_id = aws_eip.eip-nat-gateway-1

    # which subnet will you place this nat gateway 
    subnet_id = aws_subnet.public-subnet-1

    tags = {
        Name = "NAT 1"
    }
}

# 2.5 create nat gateway 2 for public subnet 2 
resource "aws_nat_gateway" "nat-gw-2" {
    # eip you will assign to the nat gateway 
    allocation_id = aws_eip.eip-nat-gateway-2

    # which subnet will you place this nat gateway 
    subnet_id = aws_subnet.public-subnet-2

    tags = {
        Name = "NAT 2"
    }
}

# 2.5.1 create an eip to be allocated/assigned to nat gateway 1
resource "aws_eip" "eip-nat-gateway-1" {
    vpc = true 
    network_interface = aws_network_interface.web-server-nic.id 
    associate_with_private_ip = "10.0.1.50"
    depends_on = [aws_internet_gateway.gw] # aws_internet_gateway should be created first before this 
}

# 2.5.1 create an eip to be allocated/assigned to nat gateway 2
resource "aws_eip" "eip-nat-gateway-1" {
    vpc = true 
    network_interface = aws_network_interface.web-server-nic.id 
    associate_with_private_ip = "10.0.1.50"
    depends_on = [aws_internet_gateway.gw] # aws_internet_gateway should be created first before this 
}

# # 2.6 create security group 
# resource "aws_security_group" "allow_web" {
#     name        = "allow_web"
#     description = "Allow web inbound traffic"
#     vpc_id      = aws_vpc.prod-vpc.id 

#     # traffic entering the cloud 
#     ingress {
#         description      = "HTTP"
#         from_port        = 443
#         to_port          = 443
#         protocol         = "tcp"
#         cidr_blocks      = ["0.0.0.0/0"] # 0.0.0.0/0 means any ip address can enter port specified in this ingress 
#     }

#     # traffic entering the cloud 
#     ingress {
#         description      = "HTTP"
#         from_port        = 80
#         to_port          = 80
#         protocol         = "tcp"
#         cidr_blocks      = ["0.0.0.0/0"] # 0.0.0.0/0 means any ip address can enter port specified in this ingress 
#     }

#     # traffic entering the cloud 
#     ingress {
#         description      = "SSH"
#         from_port        = 2
#         to_port          = 2
#         protocol         = "tcp"
#         cidr_blocks      = ["0.0.0.0/0"] # 0.0.0.0/0 means any ip address can enter port specified in this ingress 
#     }

#     # traffic exiting the cloud 
#     egress {
#         from_port        = 0
#         to_port          = 0
#         protocol         = "-1"
#         cidr_blocks      = ["0.0.0.0/0"]
#         ipv6_cidr_blocks = ["::/0"]
#     }

#     tags = {
#         Name = "allow_web"
#     }
# }

# # 2.7 create network interface with an ip in the subnet 
# resource "aws_network_interface" "web-server-nic" {
#     subnet_id       = aws_subnet.subnet-1.id
#     private_ips     = ["10.0.0.50"]
#     security_groups = [aws_security_group.web.id]
# }

# # 2.7.1 assign an elastic ip to the network interface 
# resource "aws_eip" "eip-network-interface" {
#     vpc = true 
#     network_interface = aws_network_interface.web-server-nic.id 
#     associate_with_private_ip = "10.0.1.50"
#     depends_on = [aws_internet_gateway.gw] # aws_internet_gateway should be created first before this 
# }