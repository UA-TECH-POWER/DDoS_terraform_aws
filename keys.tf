resource "tls_private_key" "kozak" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "kozak" {
  content  = tls_private_key.kozak.private_key_pem
  filename = "${abspath(path.root)}/kozak_rsa"
  file_permission = "0400"
}
