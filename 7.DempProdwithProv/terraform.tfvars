
resourcename = "Azurermresourcegroup"
location = "North Europe"
storagename = "tfvknstorage"
tags = {"env"="demo", "owner"="vijay", "purpose"="tfdemo"}
tag2 = {resource="virtualmachine",costcentre="demotfcourse"}
containername = "tfdemocontainer"
dnsname = ["vijay.com","vijay1.com","vijay2.com","vijay3.com"]
networkrule = [
    {
    name                       = "test123"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    },

    {
    name                       = "test1234"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "443"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    },
    
    {
    name                       = "test1235"
    priority                   = 102
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "3389"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    }
]

environment = "sandbox"
account_type = "standard_GRS"
loc = ["east","us"]
address_space = ["10.0.0.0/16","10.0.0.1/32","10.0.0.1/24","10.0.2.0/23"]