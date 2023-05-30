data "terraform_remote_state" "security" {
  backend = "local"
  config = {
    path = "../../../Enviorments/${var.environment}/security/state.tfstate"
  }
}

data "terraform_remote_state" "rds" {
  backend = "local"
  config = {
    path = "../../../Enviorments/${var.environment}/rds/state.tfstate"
  }
}


data "terraform_remote_state" "eip" {
  backend = "local"
  config = {
    path = "../../../Enviorments/${var.environment}/eip/state.tfstate"
  }
}


resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "streaky12062001" {
  key_name   = "streaky11122"
  public_key = tls_private_key.example.public_key_openssh
}


resource "aws_instance" "example" {
  # count                       = 1
  ami                         = "ami-007855ac798b5175e"
  instance_type               = "t2.medium"
  key_name                    = aws_key_pair.streaky12062001.key_name
  associate_public_ip_address = true
  subnet_id                   = data.terraform_remote_state.security.outputs.aws_subnet_id
  vpc_security_group_ids      = [data.terraform_remote_state.security.outputs.aws_security_group_id]


  ebs_block_device {
    device_name = "/dev/sdf"
    volume_size = 20
    volume_type = "gp2"
  }
  tags = {
    Name = "example-instance"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update && sudo apt-get install curl -y",
      "curl -sL https://deb.nodesource.com/setup_16.x | sudo -E bash -",
      "sudo apt-get install -y nodejs",
      "curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -",
      "echo deb https://dl.yarnpkg.com/debian/ stable main | sudo tee /etc/apt/sources.list.d/yarn.list",
      "sudo apt-get update && sudo apt-get install yarn",
      #---nginx setup----
      "sudo apt install nginx -y",
      #  "sudo ufw allow 'Nginx Full",
      #  "sudo ufw enable",
      # "echo 'y' | sudo ufw allow 'Nginx Full'",
      # "echo 'y' | sudo ufw enable",
      "sudo systemctl enable nginx",
      "sudo systemctl start nginx",
      "sudo apt-get install -y certbot python3-certbot-nginx",
      "sudo nginx -t",
      "sudo yarn install -g n",
      "sudo npm install pm2 -g",
      "sudo n latest",
      "git clone https://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@github.com/redutech/streaky.git",
      "cd streaky",
      "yarn install",
      "cd apps/api",
      "sudo npm install -g env-cmd",
      "touch .dev.env",
      "touch .env",
      "echo '\nDB_HOST=${local.endpoint_without_port}' >> .env && echo '\nDB_HOST=${local.endpoint_without_port}' >> .dev.env",
      "echo 'DB_PORT=5432' >> .env && echo 'DB_PORT=5432' >> .dev.env",
      "echo 'DB_USER=postgres' >> .env && echo 'DB_USER=postgres' >> .dev.env",
      "echo 'DB_PASSWORD=${data.terraform_remote_state.rds.outputs.aws_db_password}' >> .env && echo  'DB_PASSWORD=${data.terraform_remote_state.rds.outputs.aws_db_password}' >> .dev.env",
      "echo 'DB_DATABASE=streaky' >> .env && echo 'DB_DATABASE=streaky' >> .dev.env",
      "echo 'AUTO_LOAD_MODEL=false' >> .env && echo 'AUTO_LOAD_MODEL=false' >> .dev.env",
      "echo 'SEND_OTP=false' >> .env && echo 'SEND_OTP=false' >> .dev.env",
      "echo 'API_PORT=4000' >> .env && echo 'API_PORT=4000' >> .dev.env",
      "echo 'JWT_PRIVATE_KEY=apps/keys/jwt-private.pem' >> .env && echo 'JWT_PRIVATE_KEY=apps/keys/jwt-private.pem' >> .dev.env",
      "echo 'JWT_PUBLIC_KEY=apps/keys/jwt-public.pem' >> .env && echo 'JWT_PUBLIC_KEY=apps/keys/jwt-public.pem' >> .dev.env",
      "echo 'JWT_EXPIRY=4h' >> .env && echo 'JWT_EXPIRY=4h' >> .dev.env",
      "echo 'JWT_REFRESH_EXPIRY=30d' >> .env && echo 'JWT_REFRESH_EXPIRY=30d' >> .dev.env",
      "echo 'JWT_ISSUER=Streaky' >> .env && echo 'JWT_ISSUER=Streaky' >> .dev.env",
      "echo 'JWT_ALGORITHM=RS256' >> .env && echo 'JWT_ALGORITHM=RS256' >> .dev.env",
      "echo 'SEND_OTP=false' >> .env && echo 'SEND_OTP=false' >> .dev.env",
      "cd ../../../",
      "sudo apt install postgresql-client-common",
      "sudo apt install postgresql-client -y",
      "PGPASSWORD=${data.terraform_remote_state.rds.outputs.aws_db_password} psql -h ${local.endpoint_without_port} -U ${data.terraform_remote_state.rds.outputs.rds_username} -c 'CREATE DATABASE streaky'",
      "PGPASSWORD=${data.terraform_remote_state.rds.outputs.aws_db_password} psql -h ${local.endpoint_without_port} -U postgres -d streaky -c 'CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\";'",
      "cd streaky",
      "npm run build",
      "cd dist/apps/api && pm2 start npm --name streaky-api -- run start:dev",
      "sudo pm2 save",
      "pm2 start streaky-api",

    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = aws_instance.example.public_ip
      private_key = tls_private_key.example.private_key_pem
      timeout     = "2m"
    }

  }

  lifecycle {
    ignore_changes = [
      ami,
      instance_type,
      key_name,
      associate_public_ip_address,
      subnet_id,
      vpc_security_group_ids,
    ]
  }
}

resource "aws_eip_association" "example" {
  instance_id   = aws_instance.example.id
  allocation_id = data.terraform_remote_state.eip.outputs.elastic_ip
}



locals {
  endpoint_parts        = split(":", data.terraform_remote_state.rds.outputs.database_endpoint)
  endpoint_without_port = local.endpoint_parts[0]
}

