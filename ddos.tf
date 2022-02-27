provider "aws" {
    region = "us-east-2"
    access_key = ""#input_your
    secret_key = ""#input_your
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

variable "kozaks" {
  description = "Скільки козаків пустити вбій(к-сть інстансів)"
  type = number
  default = "1"
}


resource "aws_instance" "ddos"  {
  count = var.kozaks
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.webSG.id}"]
  key_name = "aws_key"
  provisioner "file" {
    source      = "/home/ubuntu/DDoS_terraform_aws/script.sh"
    destination = "/tmp/script.sh"
  }
  connection {
    type = "ssh"
    host = self.public_ip
    user = "ubuntu"
    private_key = file("/home/ubuntu/DDoS_terraform_aws/aws_key")
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/script.sh",
      "sudo bash /tmp/script.sh &",
    ]
  }
}


resource "aws_key_pair" "deploy"{
  key_name = "aws_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCpCfKMTNs1r0o73dXjnkriqqcDgMDbaog8xI+yeSp7o5B5rur5ODavFXtGTcRV+8wIxv9iZ4bpv7pPAUHx+/OK/ACg1z/s3jTxVchI517e4e5ZKfUCbgydZOnBIBUYfRXECCUnZXe0SBRmQO0h8                                                                                                                                                                                                                                                                                                                                                 disuke/FqyKDIaSOjp1kYlMI+b9DyWIRFK3GIdwmaZd0D2tu4pGg8lhDL94qE3P0c+pm2UfL6cjVWFIlfLgBli7KzmAjHzbcnI9f9vuwOt/X0p3hSDkrbUvk9w9LEKi7KjJ4y/dscSjD//ukqOE8wO3C6Yvpt7UEGJGtco82RWm0AsYHVHzDdVKG8nrCDotJVSK++kHeB                                                                                                                                                                                                                                                                                                                                                 /YfQItsH2/pj+/8XnMng7aupqZubUDQedtHkxVN1YLM3/aUqBCBlyK3lgeeRUBu6X78Pfbc9FQQLaaKzFZCunrVa9O5W7dMPrWYrmCi+C17sp/qJPR+5F0GzU481g/dbROxpmKuUCJ942B+PHNoKka+dYDW9S/sFMDEmfu/JMoN18Ot4aDultAR1+E7VlVoB+Km0SD6jH                                                                                                                                                                                                                                                                                                                                                 wplbh4j36yTDW/g23xnovxNpcJWviFaxjkxRdnHZxSvRmKbUicBarWlZB36yGlpuzqmXSNm2ASisEgT6ZvgeyvMjZjsqmY9Nir8xmMeipbOGPQnXxTMTaASON3l90pSmrT2i4LQ== ubuntu@ip-172-31-19-247"
}
