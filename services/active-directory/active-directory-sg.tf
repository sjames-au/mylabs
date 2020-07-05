resource "aws_security_group" "activedirectory-ingress-sg" {
  name        = "activedirectory-ingress-sg"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_staging_id
  description = "Rules required for Active Directory clients and administration"
  ## Ingress rules
  #
  # NOTE NTP Is not included in this ruleset
  # source: https://support.microsoft.com/en-us/help/832017#method1
  ingress {
    description = "Active Directory Web Services (ADWS) TCP 9389 and Active Directory Management Gateway Service TCP 9389"
    from_port   = 9389
    to_port     = 9389
    protocol    = "tcp"
    cidr_blocks = [data.terraform_remote_state.vpc.outputs.vpc_cidr_block]
  }
  ingress {
    description = "Global Catalog TCP 3269"
    from_port   = 3269
    to_port     = 3269
    protocol    = "tcp"
    cidr_blocks = [data.terraform_remote_state.vpc.outputs.vpc_cidr_block]
  }
  ingress {
    description = "Global Catalog TCP 3268"
    from_port   = 3268
    to_port     = 3268
    protocol    = "tcp"
    cidr_blocks = [data.terraform_remote_state.vpc.outputs.vpc_cidr_block]
  }
  ingress {
    description = "LDAP Server TCP 389"
    from_port   = 389
    to_port     = 389
    protocol    = "tcp"
    cidr_blocks = [data.terraform_remote_state.vpc.outputs.vpc_cidr_block]
  }
  ingress {
    description = "LDAP Server UDP 389"
    from_port   = 389
    to_port     = 389
    protocol    = "udp"
    cidr_blocks = [data.terraform_remote_state.vpc.outputs.vpc_cidr_block]
  }
  ingress {
    description = "LDAP SSL TCP 636"
    from_port   = 636
    to_port     = 636
    protocol    = "tcp"
    cidr_blocks = [data.terraform_remote_state.vpc.outputs.vpc_cidr_block]
  }
  ingress {
    description = "IPsec ISAKMP UDP 500"
    from_port   = 500
    to_port     = 500
    protocol    = "udp"
    cidr_blocks = [data.terraform_remote_state.vpc.outputs.vpc_cidr_block]
  }
  ingress {
    description = "NAT-T UDP 4500" # TODO What is this?
    from_port   = 4500
    to_port     = 4500
    protocol    = "udp"
    cidr_blocks = [data.terraform_remote_state.vpc.outputs.vpc_cidr_block]
  }
  ingress {
    description = "RPC TCP 135"
    from_port   = 135
    to_port     = 135
    protocol    = "tcp"
    cidr_blocks = [data.terraform_remote_state.vpc.outputs.vpc_cidr_block]
  }
  ingress {
    description = "SMB TCP 445"
    from_port   = 445
    to_port     = 445
    protocol    = "tcp"
    cidr_blocks = [data.terraform_remote_state.vpc.outputs.vpc_cidr_block]
  }

  ingress {
    description = "RPC randomly allocated high TCP ports (Modern Windows)"
    from_port   = 49152
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [data.terraform_remote_state.vpc.outputs.vpc_cidr_block]
  }

  # TODO Review as this may be more than required
  ingress {
    description = "ICMP Required for MS LDAP Clients"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [data.terraform_remote_state.vpc.outputs.vpc_cidr_block]
  }

  ingress {
    description = "WIndows RDP Service Access"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = [data.terraform_remote_state.vpc.outputs.vpc_cidr_block]
  }

}