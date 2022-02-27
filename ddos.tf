provider "aws" {
    region = "us-east-2"
    # access_key = ""#input_your
    # secret_key = ""#input_your
}

data "aws_ami" "ubuntu" {

    most_recent = true

    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
    }

    filter {
        name = "virtualization-type"
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
    self = false
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
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]

  }
}

resource "aws_instance" "ddos"  {
  count = var.kozaks

  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.webSG.id}"]
  key_name               = aws_key_pair.kozak.key_name
  provisioner "file" {
    source      = "${abspath(path.root)}/script.sh"
    destination = "/tmp/script.sh"
  }
  connection {
    type = "ssh"
    host = self.public_ip
    user = "ubuntu"
    private_key = tls_private_key.kozak.private_key_pem
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/script.sh",
      "sudo bash /tmp/script.sh &",
    ]
  }
}


resource "aws_key_pair" "kozak"{
  key_name = "kozak"
  public_key = tls_private_key.kozak.public_key_openssh
}
