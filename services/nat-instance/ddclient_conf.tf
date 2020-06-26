resource "local_file" "ddclient-conf" {
  sensitive_content = data.template_file.ddclient-tmpl.rendered
  filename          = "tmp/ddclient.conf"
  file_permission   = "0600"
}

data "template_file" "ddclient-tmpl" {
  template = <<EOF
use=ip
protocol=dyndns2
server=${var.bastion_ddns_server}
ssl=yes
login=${data.onepassword_item_login.aws-gw1_dyndns.username}
password=${data.onepassword_item_login.aws-gw1_dyndns.password}
${var.bastion_fqdn}
  EOF
}