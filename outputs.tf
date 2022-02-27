output "ssh_command" {
  value = formatlist("ssh ubuntu@%s -i ${abspath(path.root)}/kozak_rsa", aws_instance.ddos.*.public_ip)
}
