output "ssh_command" {
  value = formatlist("ssh ubuntu@%s -i ${abspath(path.root)}/kozak_rsa", google_compute_instance.ddos.*.network_interface.0.access_config.0.nat_ip)
}
