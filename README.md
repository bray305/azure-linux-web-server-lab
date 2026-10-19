# Azure Linux Web Server Lab
## Overview
I used Terraform to create Azure infrastructure for an Ubuntu virtual machine. I connected through SSH, installed Nginx, and created a custom HTML webpage.

## Tools Used
- Microsoft Azure
- Terraform
- Ubunata Linux
- Nginx
- SSH
- Azure CLI
- HTML

## Infrastructure

- Azure resource group containing the lab resources
- Virtual network and subnet
- Ubuntu virtual machine and network interface
- Static public IP address
- Network Security Group with inbound rules:
  - SSH on port 22 from my public IP
  - HTTP on port 80 from my public IP

## Validation

- Confirmed Nginx was active.
- Tested HTTP locally on the VM and received 200 OK.
- Opened the custom webpage from my laptop.
- Stopped Nginx, observed the failure, and started it again.
- Rebooted the VM and confirmed Nginx started automatically.

## Troubleshooting

### Package installation was blocked

Ubuntu automatic updates held the package manager lock.
I checked the update logs, waited for the updates to finish,
then retried the Nginx installation.

### Website was unreachable from my laptop

Nginx worked locally, but the NSG did not have an HTTP rule.
I added a Terraform rule allowing my public IP to reach port 80,
reviewed the plan, and applied the change.

### HTTPS connection failed

I tested HTTPS before configuring it. The lab used HTTP on
port 80. Testing with http:// returned 200 OK.

## Learning Context

I completed this as a guided learning project while studying
for AZ-104. I am practicing explaining the infrastructure
and repeating the troubleshooting steps independently.