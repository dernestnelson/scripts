#!/bin/bash

rg=$1
vnet=$2
sub=$3
firewall=$4
netgate=$5

az group create -n $rg -l southcentralus

az network vnet create --name $vnet -g $rg --address-prefixes 100.0.0.0/24 -l southcentralus

az network vnet subnet create --address-prefixes 100.0.0.0/26 --vnet-name $vnet -n sub1 -g $rg
az network vnet subnet create --address-prefixes 100.0.0.64/26 --vnet-name $vnet -n sub2 -g $rg
az network vnet subnet create --address-prefixes 100.0.0.128/26 --vnet-name $vnet -n sub3 -g $rg
az network vnet subnet create --address-prefixes 100.0.0.192/26 --vnet-name $vnet -n AzureFirewallSubnet -g $rg

az network firewall create --name $firewall -g $rg

az network firewall network-rule create --collection-name fw_http --destination-addresses * \
--destination-ports 80 --firewall-name $firewall --name http_rule --protocols tcp -g $rg --source-addresses * --priority 100
az network firewall network-rule create --collection-name fw_http --destination-addresses * \
--destination-ports 443 --firewall-name $firewall --name https_rule --protocols tcp -g $rg --source-addresses * --priority 100
az network firewall network-rule create --collection-name fw_ssh --destination-addresses * \
--destination-ports 22 --firewall-name $firewall --name ssh_uta --protocols any -g $rg --source-addresses 129.107.80.0/24 --priority 200

az network vnet-gateway create --name $netgate -g $rg --public-ip-addresses netgateIP --vnet $vnet \

az network nsg create --name nsg_public -g $rg
az network nsg create --name nsg_private -g $rg

az network nsg rule create --name in_rule --nsg-name nsg_public -g $rg --priority 100 \
--direction inbound --source-address-prefixes 0.0.0.0/1 --source-port-ranges 22 80 443 --destination-address-prefixes 100.0.0.0/26 \
--destination-port-ranges 22 80 443 --protocol *

az network nsg rule create --name out_rule --nsg-name nsg_public -g $rg --priority 100 \
--direction outbound --source-address-prefixes VirtualNetwork --source-port-ranges * \
--destination-address-prefixes * --destination-port-ranges * --protocol *

az network nsg rule create --name in_rule --nsg-name nsg_private -g $rg --priority 100 \
--direction inbound --source-address-prefixes 100.0.0.0/26 --source-port-ranges * \
--destination-address-prefixes * --destination-port-ranges * --protocol *

az network nsg rule create --name out_rule --nsg-name nsg_private -g $rg --priority 100 \
--direction outbound --source-address-prefixes 100.0.0.64/26 --source-port-ranges * \
--destination-address-prefixes * --destination-port-ranges 80 443 --protocol *

