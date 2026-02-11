packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "learn-packer-linux-aws-nginx"
  instance_type = "t2.micro"
  region        = "us-west-2"

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }

  ssh_username = "ubuntu"
}

build {
  name    = "learn-packer"
  sources = ["source.amazon-ebs.ubuntu"]

  provisioner "shell" {
    inline = [
      # Avoid interactive prompts
      "sudo DEBIAN_FRONTEND=noninteractive apt-get update -y",

      # Install nginx
      "sudo DEBIAN_FRONTEND=noninteractive apt-get install -y nginx",

      # Enable nginx at boot
      "sudo systemctl enable nginx",

      # Start nginx now (so we can verify during build)
      "sudo systemctl start nginx",

      # Show status for packer logs
      "systemctl status nginx --no-pager"
    ]
  }
}
