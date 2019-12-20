#!/bin/bash
yum -y install git jq
echo "git installed" >> /var/log/pki.log
git clone https://github.com/OpenVPN/easy-rsa.git
cd easy-rsa/easyrsa3
region=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq .region -r)
Server=$(aws ssm get-parameter --name /Pki/Server --region us-east-2  --query Parameter.Value --region $region | sed 's/"//g')
Client=$(aws ssm get-parameter --name /Pki/Client --region us-east-2  --query Parameter.Value --region $region | sed 's/"//g')
Cn=$(aws ssm get-parameter --name /Pki/CN --region us-east-2  --query Parameter.Value --region $region)
Country=$(aws ssm get-parameter --name /Pki/Country --region us-east-2  --query Parameter.Value --region $region)
Province=$(aws ssm get-parameter --name /Pki/Province --region us-east-2  --query Parameter.Value --region $region)
City=$(aws ssm get-parameter --name /Pki/City --region us-east-2  --query Parameter.Value --region $region)
Email=$(aws ssm get-parameter --name /Pki/Email --region us-east-2  --query Parameter.Value --region $region)
Ou=$(aws ssm get-parameter --name /Pki/OU --region us-east-2  --query Parameter.Value --region $region)
cp vars.example vars
echo "set_var EASYRSA_BATCH	   \"enabled"\" >> vars
echo "set_var EASYRSA_REQ_CN     $Cn"  >> vars
echo "set_var EASYRSA_REQ_COUNTRY     $Country"  >> vars
echo "set_var EASYRSA_REQ_PROVINCE     $Province" >> vars
echo "set_var EASYRSA_REQ_CITY     $City" >> vars
echo "set_var EASYRSA_REQ_EMAIL     $Email" >> vars
echo "set_var EASYRSA_REQ_OU     $Ou" >> vars
echo "vars copied and set" >> /var/log/pki.log
cat vars >> /var/log/pki.log
./easyrsa init-pki
./easyrsa build-ca nopass
./easyrsa build-server-full $Server nopass
./easyrsa build-client-full $Client nopass
echo "PKI, CA, certs built" >> /var/log/pki.log
mkdir ~/certs
cp pki/ca.crt ~/certs/
cp pki/issued/$Server.crt ~/certs/
cp pki/private/$Server.key ~/certs/
cp pki/issued/$Client.crt ~/certs/
cp pki/private/$Client.key ~/certs/
cd ~/certs/
instance_id=$(curl http://169.254.169.254/latest/meta-data/instance-id)
echo "1" >> /var/log/pki.log
prefix="client-vpn-files-"
echo "2" >> /var/log/pki.log
echo "3" >> /var/log/pki.log
bucketname="$prefix$instance_id"
echo "4" >> /var/log/pki.log
echo "Variables set" >> /var/log/pki.log
aws s3 mb s3://$bucketname --region $region
aws s3 cp ~/certs s3://$bucketname/certs/ --recursive --acl private
echo "S3 bucket creation and puts complete" >> /var/log/pki.log
aws acm import-certificate --certificate file://$Server.crt --private-key file://$Server.key --certificate-chain file://ca.crt --region $region
aws acm import-certificate --certificate file://$Client.crt --private-key file://$Client.key --certificate-chain file://ca.crt --region $region
echo "Client and server certs uploaded to ACM" >> /var/log/pki.log
aws ec2 stop-instances --instance-ids $instance_id --region $region
echo EOS >> /var/log/pki.log
