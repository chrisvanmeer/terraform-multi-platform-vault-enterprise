provider "aws" {
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

resource "random_shuffle" "aws_zones" {
  input        = data.aws_availability_zones.available.names
  result_count = 1
}

resource "random_pet" "keyname" {

}

resource "aws_key_pair" "key" {
  key_name   = "${random_pet.keyname.id}-vault-key"
  public_key = file(var.ssh_pub_key_file)
}
resource "aws_instance" "aws_vault" {
  ami               = data.aws_ami.ubuntu.id
  availability_zone = random_shuffle.aws_zones.result[0]
  instance_type     = var.aws_instance_type
  key_name          = aws_key_pair.key.key_name
  count             = var.vault_instance_count
  user_data         = file("${path.module}/install.sh")

  tags = {
    Name = "aws-vault-${count.index}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo adduser --disabled-password --gecos '' ${var.ssh_user}",
      "sudo mkdir -p /home/${var.ssh_user}/.ssh",
      "sudo touch /home/${var.ssh_user}/.ssh/authorized_keys",
      "sudo echo '${file(var.ssh_pub_key_file)}' > authorized_keys",
      "sudo mv authorized_keys /home/${var.ssh_user}/.ssh",
      "sudo chown -R ${var.ssh_user}:${var.ssh_user} /home/${var.ssh_user}/.ssh",
      "sudo chmod 700 /home/${var.ssh_user}/.ssh",
      "sudo chmod 600 /home/${var.ssh_user}/.ssh/authorized_keys",
      "sudo usermod -aG sudo ${var.ssh_user}",
      "sudo echo '${var.ssh_user} ALL=(ALL) NOPASSWD:ALL' | sudo tee -a /etc/sudoers.d/90-cloud-init-users"
    ]

    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ubuntu"
      private_key = file(var.ssh_priv_key_file)
    }
  }

}
