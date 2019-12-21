# EC2 PKI

AWS EC2 base PKI, designed for use with AWS Client VPN. This CloudFormation template (pki.yaml) will launch an instance, install easyrsa3, create a PKI, server, and client certificates based on the parameters specified. All certificates are uploaded to a private S3 bucket and ACM.

## Getting Started
### Prerequisites

The only pre-requisites are and AWS account, with a VPC and a subnet with Internet access (via IGW or NAT-Gateway)
