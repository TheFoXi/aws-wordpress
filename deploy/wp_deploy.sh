#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# Root permission check
if [[ $(id -u) -ne 0 ]]; then
    echo "You must run this script as root! Use: sudo ./wp_deploy.sh"
    exit 1
fi

echo "WordPress initial setup"

# MySQL Configurator
echo "MySQL configurator"
read -rp "Enter MySQL database name (default [wordpress]): " DB_NAME
DB_NAME=${DB_NAME:-wordpress}

read -rp "Enter MySQL database user name (default [wp_user]): " DB_USER
DB_USER=${DB_USER:-wp_user}

read -rp "Enter MySQL database password (default [SuperSecurePassword123]): " DB_PASSWORD
DB_PASSWORD=${DB_PASSWORD:-SuperSecurePassword123}

while true; do
    read -rp "Enter MySQL database hostname (terraform > rds_endpoint): " DB_HOST
    if [[ -n "$DB_HOST" ]]; then
        break
    fi
    echo -e "\n MySQL hostname is required. Get rds_endpoint from terraform output.\n"
done

# Redis Configurator
echo "Redis configurator"
while true; do
    read -rp "Enter Redis hostname (terraform > redis_endpoint): " REDIS_HOST
    if [[ -n "$REDIS_HOST" ]]; then
        break
    fi
    echo -e "\n Redis hostname is required. Get redis_endpoint from terraform output.\n"
done
read -rp "Enter Redis port (default [6379]): " REDIS_PORT
REDIS_PORT=${REDIS_PORT:-6379}

# WordPress Configurator
echo "WordPress configurator"
while true; do
    read -rp "Enter EC2 IP (terraform > ec2_public_ip): " AWS_IP
    if [[ -n "$AWS_IP" ]]; then
        break
    fi
    echo -e "\n EC2 IP is required. Get ec2_public_ip from terraform output.\n"
done

read -rp "Enter WordPress admin name (default [admin]): " WP_ADMIN_USER
WP_ADMIN_USER=${WP_ADMIN_USER:-admin}

read -rp "Enter WordPress admin password (default [AdminPass!123]): " WP_ADMIN_PASS
WP_ADMIN_PASS=${WP_ADMIN_PASS:-AdminPass!123}

read -rp "Enter WordPress admin email (default [admin@example.com]): " WP_ADMIN_EMAIL
WP_ADMIN_EMAIL=${WP_ADMIN_EMAIL:-admin@example.com}

SITE_URL="http://${AWS_IP}"

# Display Configuration
cat <<EOF
Configuration Set:
DB_NAME=$DB_NAME
DB_USER=$DB_USER
DB_PASSWORD=$DB_PASSWORD
DB_HOST=$DB_HOST
REDIS_HOST=$REDIS_HOST
REDIS_PORT=$REDIS_PORT
AWS_IP=$AWS_IP
SITE_URL=$SITE_URL
WP_ADMIN_USER=$WP_ADMIN_USER
WP_ADMIN_PASS=$WP_ADMIN_PASS
WP_ADMIN_EMAIL=$WP_ADMIN_EMAIL
EOF

# Confirm Configuration
read -rp "This Configuration is OK? [y/N]: " config_status
config_status=${config_status:-y}
if [[ "$config_status" =~ ^[Nn]$ ]]; then
    echo "Exiting"
    exit 1
fi

# System update and dependency installation
echo "Updating system and installing dependencies..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y nginx mysql-client php8.3-fpm php8.3-mysql php8.3-cli php8.3-xml php8.3-curl php8.3-gd php8.3-mbstring php8.3-zip unzip curl jq

# Installing WP-CLI
echo "Installing WP-CLI..."
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp

# Downloading and deploying WordPress
echo "Downloading and deploying WordPress..."
cd /var/www
sudo wget https://wordpress.org/latest.tar.gz
sudo tar -xzf latest.tar.gz
sudo mv wordpress/* html/
sudo chown -R www-data:www-data /var/www/html
sudo chmod -R 755 /var/www/html
sudo rm -r latest.tar.gz wordpress

# Creating wp-config.php
echo "Creating wp-config.php..."
cd /var/www/html
sudo rm index.nginx-debian.html
sudo -u www-data wp config create \
  --dbname="${DB_NAME}" \
  --dbuser="${DB_USER}" \
  --dbpass="${DB_PASSWORD}" \
  --dbhost="${DB_HOST}"

# Adding settings for Redis and caching
echo "Adding settings for Redis and caching..."
sudo -u www-data wp config set WP_REDIS_HOST "${REDIS_HOST}"
sudo -u www-data wp config set WP_REDIS_PORT "${REDIS_PORT}"
sudo -u www-data wp config set WP_CACHE true --raw

# Installing WordPress
echo "Installing WordPress..."
sudo -E -u www-data wp core install \
  --path=/var/www/html \
  --url="${SITE_URL}" \
  --title="WordPress Site" \
  --admin_user="${WP_ADMIN_USER}" \
  --admin_password="${WP_ADMIN_PASS}" \
  --admin_email="${WP_ADMIN_EMAIL}" \
  --skip-email

sudo mkdir -p /var/www/.wp-cli/cache/
sudo chown -R www-data:www-data /var/www/.wp-cli
sudo chmod -R 755 /var/www/.wp-cli

# Installing and activating required plugins
echo "Installing and activating required plugins..."
sudo -u www-data wp plugin install redis-cache classic-editor --activate
sudo -u www-data wp plugin update --all

# Enabling Redis Object Cache
echo "Enabling Redis Object Cache..."
sudo -u www-data wp redis enable

# Configuring Nginx
echo "Configuring Nginx..."
sudo tee /etc/nginx/sites-available/wordpress > /dev/null <<EOF
server {
    listen 80;
    server_name ${AWS_IP};
    root /var/www/html;
    index index.php index.html index.htm;

    access_log /var/log/nginx/wordpress_access.log;
    error_log /var/log/nginx/wordpress_error.log;

    location / {
        try_files \$uri \$uri/ /index.php?\$args;
    }

    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.3-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }
    location = /xmlrpc.php {
            deny all;
    }

    # Protecting configuration files
    location ~* /wp-config.php {
        deny all;
    }

    # Deny access to hidden files (e.g. .htaccess, .git)
    location ~ /\. {
        deny all;
        access_log off;
        log_not_found off;
    }

    # Caching static files
    location ~* \.(css|js|jpg|jpeg|png|gif|ico|woff|woff2|ttf|svg|mp4|webp)$ {
        expires 30d;
        log_not_found off;
    }
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
    gzip_vary on;

}
EOF

# Increese server_names_hash_bucket_size to 128.
sudo sed -i '/http {/a \    server_names_hash_bucket_size 128;' /etc/nginx/nginx.conf
# Activating Nginx configuration
echo "Activating Nginx configuration..."
sudo ln -sf /etc/nginx/sites-available/wordpress /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
sudo systemctl restart php8.3-fpm

echo "WordPress successfully installed! Admin access: ${SITE_URL}/wp-admin"
