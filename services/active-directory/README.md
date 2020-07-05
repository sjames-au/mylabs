Model requires using an SSH tunnel or something like ssshuttle
Two commands

`terraform apply`
`TF_STATE=. ansible-playbook -i=/usr/local/bin/terraform-inventory ansible/ad.yml`
Note: TF_STATE is a workaround as per https://github.com/adammck/terraform-inventory/issues/131 on terraform-inventory v0.9