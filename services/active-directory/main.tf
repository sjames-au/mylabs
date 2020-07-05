provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}

terraform {
  required_version = ">= 0.12"
}

data "terraform_remote_state" "vpc" {
  backend = "local"

  config = {
    path = "${path.module}/../../global/vpc/terraform.tfstate"
  }
}

# TODO Review Filter
# TODO Establish a windows admin jump box, switch to "core"
# Get most recent AMI for Windows 2019 (DesktopXP)
data "aws_ami" "win_2019_full" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["Windows_Server-2019-English-Full-Base*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# TODO Confirm you need to set an IP address or if services would recover if changes
# TODO Add generation of per host or service key
resource "aws_instance" "activedirectory" {
  ami                         = data.aws_ami.win_2019_full.id
  instance_type               = "t2.micro"
  subnet_id                   = data.terraform_remote_state.vpc.outputs.vpc_staging_mgmt_sn_a_id
  associate_public_ip_address = false
  key_name                    = var.bastion_key
  vpc_security_group_ids      = [aws_security_group.activedirectory-ingress-sg.id]
  user_data                   = data.template_file.init.rendered
  get_password_data           = true # Set to true when required
  private_ip                  = "172.17.57.4"
}

### INLINE - Bootsrap Windows Server  ###
# user_data
#
# Enables WinRM with a self-signed certificate
# Enables Basic Auth for Ansible
# Enables Windows Firewall for port 5986
#
# TODO Add variable to limit Firewall to local VPC
# TODO Review potential to use a signed certificate (will require private CA)
# TODO Research better authentication option
data "template_file" "init" {
  template = <<EOF
  <powershell>
  $Dnsname =  ([System.Net.Dns]::GetHostByName(($env:computerName))).Hostname
  $Cert = New-SelfSignedCertificate -CertStoreLocation Cert:\LocalMachine\My -DnsName $Dnsname -Verbose
  $Password = ConvertTo-SecureString -String $DnsName -Force -AsPlainText -Verbose

  Export-Certificate -Cert $Cert -FilePath .\$DnsName.cer -Verbose
  Export-PfxCertificate -Cert $Cert -FilePath .\$DnsName.pfx -Password $Password -Verbose

  $CertThumbprint = $Cert.Thumbprint

  Enable-PSRemoting -Force -Verbose

  # Require basic auth for ansible, but we are using SSL
  Set-Item WSMan:\localhost\Service\Auth\Basic $true -Force -Verbose
  New-Item -Path WSMan:\localhost\Listener -Transport HTTPS -Address * -CertificateThumbPrint $CertThumbprint -Force -Verbose
  Restart-Service WinRM -Verbose

  New-NetFirewallRule -DisplayName "Windows Remote Management (HTTPS-In)" -Name "WinRMHTTPSIn" -Profile Any -LocalPort 5986 -Protocol TCP -Verbose

  </powershell>
  EOF
}


output "private_ip" {
  value       = aws_instance.activedirectory.private_ip
  description = "The public IP of the server"
}

output "ansible_user" {
  value = "Administrator"
}

output "ansible_password" {
  description = "Initial password for the new instance"
  value       = rsadecrypt(aws_instance.activedirectory.password_data, file("${path.module}/../../tmp/${var.bastion_key}.pem"))
}

output "ansible_connection" {
  value = "winrm"
}

# TODO requires some sort of CA to improve this
output "ansible_winrm_server_cert_validation" {
  value = "ignore"
}