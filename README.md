# EC2 PKI

AWS EC2 base PKI, designed for use with AWS Client VPN. This CloudFormation template (pki.yaml) will launch an instance, install easyrsa3, create a PKI, server, and client certificates based on the parameters specified. All certificates are uploaded to a private S3 bucket and ACM.

## Getting Started
### Prerequisites
You will need an AWS account with a VPC and a subnet with Internet access (via IGW or NAT-Gateway)

### Launching The Template
To run the template:
- Download or clone pki.yaml
- Navigate to CloudFormation in your desired region
- Launch a new stack using pki.yaml

### Outputs
Following launch, you will have the following:
- And EC2 instance (stopped) containing your PKI/CA
- A server and client certificate uploaded to ACM in the same region
- A private S3 bucket named "client-vpn-files-i-xxxxxxxxxx"

## Next Steps
Using the certificates, you can now create a Client VPN endpoint with Mutual Authentication (https://docs.aws.amazon.com/vpn/latest/clientvpn-admin/cvpn-working-endpoints.html#cvpn-working-endpoint-create)

(Optional) Manually create certificates for additional clients: 

From the EC2 instance run the command "./easyrsa build-client-full username.domain.tld nopass". Note: The additional client certificates do not need to be uploaded to ACM, providing they are signed with the same CA as the initial client certificate"
