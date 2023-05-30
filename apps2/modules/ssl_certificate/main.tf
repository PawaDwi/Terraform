data "terraform_remote_state" "ec2" {
  backend = "local"
  config = {
    path = "../../../Enviorments/${var.environment}/ec2/state.tfstate"
  }
}


data "aws_instance" "example" {
  instance_id = data.terraform_remote_state.ec2.outputs.aws_instance_id
}

resource "null_resource" "ssl_certificate" {
  provisioner "remote-exec" {
    inline = [
      "sudo certbot --non-interactive --agree-tos --nginx --email pawandwivedi@redbaton.in -d api.prod.streaky.app", // Replace `your-domain.com` with your actual domain name
      "echo '# Default server configuration\nserver {\n    listen 80;\n    listen [::]:80;\n    server_name api.prod.streaky.app;\n\n    # Redirect HTTP to HTTPS\n    return 301 https://$host$request_uri;\n}\n\n# HTTPS server configuration\nserver {\n    listen 443 ssl;\n    listen [::]:443 ssl;\n    server_name api.prod.streaky.app;\n\n    # SSL certificate configuration\n    ssl_certificate /etc/letsencrypt/live/api.prod.streaky.app/fullchain.pem;\n    ssl_certificate_key /etc/letsencrypt/live/api.prod.streaky.app/privkey.pem;\n    include /etc/letsencrypt/options-ssl-nginx.conf;\n    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;\n\n    location /api/v1/ {\n        proxy_pass http://localhost:4000;\n        proxy_set_header Host $host;\n        proxy_set_header X-Real-IP $remote_addr;\n        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;\n        proxy_set_header X-Forwarded-Proto $scheme;\n    }\n\n    # Additional configuration for static files or other routes if needed\n    # ...\n\n    # Error handling\n    error_page 404 /404.html;\n    location = /404.html {\n        root /var/www/html;\n    }\n\n    # Custom error pages for other errors if desired\n    # ...\n\n    # Additional server configuration directives if needed\n    # ...\n}' | sudo tee /etc/nginx/sites-enabled/default > /dev/null",
      "sudo service nginx reload",
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = data.terraform_remote_state.ec2.outputs.public_ip
      private_key = data.terraform_remote_state.ec2.outputs.tls_private_key
      timeout     = "2m"
    }
  }

}
