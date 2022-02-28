output "ssh_command" {
  value = formatlist("ssh ubuntu@%s -i ${abspath(path.root)}/kozak_rsa", aws_instance.ddos.*.public_ip)
}

#output "work-ok" {
#  value = formatlist("ssh -oStrictHostKeyChecking=no -i ${abspath(path.root)}/kozak_rsa -fubuntu@%s 'screen -list'", aws_instance.ddos..public_ip)
#}
