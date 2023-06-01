provider "aws" {

  region = "us-east-1"
}

resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "streaky12062001" {
  key_name   = "streaky11122"
  public_key = tls_private_key.example.public_key_openssh
}


# Create VPC
resource "aws_vpc" "example" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
}

# Create subnets
resource "aws_subnet" "subnet1" {
  vpc_id            = aws_vpc.example.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "subnet2" {
  vpc_id            = aws_vpc.example.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1c"
}

resource "aws_internet_gateway" "example" {
  vpc_id = aws_vpc.example.id
}

# Create a route table
resource "aws_route_table" "example" {
  vpc_id = aws_vpc.example.id
}

# Create an internet gateway route
resource "aws_route" "internet_gateway_route" {
  route_table_id         = aws_route_table.example.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.example.id
}

# Associate the route table with the subnet
resource "aws_route_table_association" "subnet1_association" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.example.id
}


resource "aws_security_group" "example" {
  vpc_id      = aws_vpc.example.id
  name        = "example-security-group"
  description = "Example Security Group"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 4000
    to_port     = 4000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #not allowed
  #   ingress {
  #     from_port   = 5432 # Allow PostgreSQL connections
  #     to_port     = 5432
  #     protocol    = "tcp"
  #     cidr_blocks = ["0.0.0.0/0"]
  #   }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "example-sg"
  }
}


resource "aws_security_group_rule" "example_http_ingress" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.example.id
}



resource "aws_security_group_rule" "example_https_ingress" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.example.id
}

resource "aws_db_parameter_group" "example" {
  name        = "example-db-parameter-group"
  family      = "postgres12"
  description = "Example DB parameter group"
}

resource "aws_db_subnet_group" "examples" {
  name        = "streaky-db-subnet-group"
  description = "Streaky DB subnet group"
  subnet_ids  = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]
}

resource "aws_db_instance" "example" {
  # count = var.create_rds ? 1 : 0


  identifier              = "example-rds-instance"
  engine                  = "postgres"
  username                = "postgres"
  password                = "MyPassword2023"
  engine_version          = "12.7"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  max_allocated_storage   = 100
  storage_type            = "gp2"
  storage_encrypted       = true
  backup_retention_period = 0
  publicly_accessible     = true
  skip_final_snapshot     = true
  vpc_security_group_ids  = [aws_security_group.example.id]
  db_subnet_group_name    = aws_db_subnet_group.examples.name
  parameter_group_name    = "example-db-parameter-group"
  deletion_protection     = false
}

resource "aws_instance" "example" {
  ami                         = "ami-007855ac798b5175e"
  instance_type               = "t2.medium"
  key_name                    = aws_key_pair.streaky12062001.key_name
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.subnet1.id
  vpc_security_group_ids      = [aws_security_group.example.id]

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
      #--------------nginx---------------------------------------------
      #   "sudo apt-get install -y ca-certificates nginx",
      #   "sudo systemctl enable nginx",
      #   "sudo systemctl start nginx",
      #   "sudo systemctl stop nginx", # Stop Nginx temporarily for Certbot configuration
      #   #   "sudo sed -i 's/80 default_server/80 default_server;\\n\\treturn 301 https:\\/\\/$host$request_uri/' /etc/nginx/sites-available/default",
      #   "sudo sed -i 's/80 default_server/80 default_server;\\n\\tlisten 443 ssl;\\n\\tssl_certificate \\/etc\\/ssl\\/certs\\/ssl_certificate.crt\\n\\tssl_certificate_key \\/etc\\/ssl\\/private\\/ssl_private_key.key\\n/' /etc/nginx/sites-available/default",
      #   "sudo systemctl start nginx",
      #   "sudo apt-get install -y certbot python3-certbot-nginx",
      #   "sudo certbot --nginx --email pawandwivedi@rebaton.in -d streaky.app", // Replace `your-domain.com` with your actual domain name# Replace `your-domain.com` with your actual domain name
      #   "sudo systemctl reload nginx",                                         # Reload Nginx after obtaining the SSL certificate
      #------------------------------------------------------------------------     
      # "sudo apt-get update && sudo apt-get install npm",
      "sudo yarn install -g n",
      "sudo npm install pm2 -g",
      "sudo n latest",
      #   "sudo sed -i 's/80 default_server;/80 default_server;\\n\\n    location \\/ {\\n        proxy_pass http:\\/\\/localhost:4000;\\n        proxy_http_version 1.1;\\n        proxy_set_header Upgrade $http_upgrade;\\n        proxy_set_header Connection 'upgrade';\\n        proxy_set_header Host $host;\\n        proxy_cache_bypass $http_upgrade;\\n    }\\n/' /etc/nginx/sites-available/default",
      #   "sudo sed -i 's/80 default_server;/80 default_server;\n\n    location \\/ {\n        proxy_pass http:\\/\\/localhost:4000;\n        proxy_http_version 1.1;\n        proxy_set_header Upgrade $http_upgrade;\n        proxy_set_header Connection \"upgrade\";\n        proxy_set_header Host $host;\n        proxy_cache_bypass $http_upgrade;\n    }\n/' /etc/nginx/sites-available/default",
      #   "sudo sed -i 's/80 default_server;/80 default_server;\n\n    location \\/ {\n        proxy_pass http:\\/\\/localhost:4000;\n        proxy_http_version 1.1;\n        proxy_set_header Upgrade $http_upgrade;\n        proxy_set_header Connection \"upgrade\";\n        proxy_set_header Host $host;\n        proxy_cache_bypass $http_upgrade;\n    }\n/' /etc/nginx/sites-available/default",
      #   "sudo systemctl reload nginx",
      "git clone https://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@github.com/redutech/streaky.git",
      "cd streaky",
      #   "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash",
      #   "nvm install --lts",
      "yarn install",
      "cd apps/api",
      "sudo npm install -g env-cmd",
      "touch .dev.env",
      "touch .env",
      "echo 'DB_HOST=${local.endpoint_without_port}' >> .env && echo 'DB_HOST=${local.endpoint_without_port}' >> .dev.env",
      "echo 'DB_PORT=5432' >> .env && echo 'DB_PORT=5432' >> .dev.env",
      "echo 'DB_USER=postgres' >> .env && echo 'DB_USER=postgres' >> .dev.env",
      "echo 'DB_PASSWORD=${aws_db_instance.example.password}' >> .env && echo 'DB_PASSWORD=${aws_db_instance.example.password}' >> .dev.env",
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
      "PGPASSWORD=${aws_db_instance.example.password} psql -h ${local.endpoint_without_port} -U ${aws_db_instance.example.username} -c 'CREATE DATABASE streaky'",
      "PGPASSWORD=${aws_db_instance.example.password} psql -h ${local.endpoint_without_port} -U postgres -d streaky -c 'CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\";'",
      "cd streaky",
      "npm run build",
      "cd dist/apps/api && pm2 start npm --name streaky-api -- run start:dev",
      "sudo pm2 save",
      "pm2 start streaky-api"
      #------------------------------------------------nginx seprate

    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = aws_instance.example.public_ip
      private_key = tls_private_key.example.private_key_pem
    }
  }
#   provisioner "file" {
#     content     = tls_private_key.example.private_key_pem
#     destination = "/home/ubuntu/.ssh/id_rsa"

#     connection {
#       type        = "ssh"
#       user        = "ubuntu"
#       host        = aws_instance.example.public_ip
#       private_key = tls_private_key.example.private_key_pem
#     }
#   }
}

# resource "null_resource" "certbot" {
#   provisioner "local-exec" {
#     command     = "sudo apt install -y python3-certbot-nginx && sudo certbot --nginx"
#     interpreter = ["bash", "-c"]

#   }
#   depends_on = [aws_instance.example]
# }


resource "aws_eip" "example" {
  instance = aws_instance.example.id
}

resource "aws_eip_association" "example" {
  instance_id   = aws_instance.example.id
  allocation_id = aws_eip.example.id
}

locals {
  endpoint_parts        = split(":", aws_db_instance.example.endpoint)
  endpoint_without_port = local.endpoint_parts[0]
}


output "database_endpoint" {
  value = aws_db_instance.example.endpoint
}

output "public_ip" {
  value = aws_instance.example.public_ip
}
