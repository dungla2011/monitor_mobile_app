\etc\nginx\sites-enabled\ping24.io

Cả apache và nginx đều ko cần thêm  header , chome app fluter vẫn vào ok

# HTTP server - redirect to HTTPS
server {
    listen 80;
    listen [::]:80;
    server_name ping24.io;

    # Redirect all HTTP to HTTPS
    return 301 https://$server_name$request_uri;
}

# HTTPS server
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name ping24.io;

    # SSL Configuration
    ssl_certificate /etc/letsencrypt/live/ping24.io/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/ping24.io/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

    # Document Root
    root /var/www/html/public;
    index index.php index.html index.htm;

    # Logging
    access_log /var/log/nginx/ping24.io.access.log;
    error_log /var/log/nginx/ping24.io.error.log;

	# Nginx ko cần đoạn này để Chrome Debug Flutter vẫn có thể truy cập được Auth Google
    # CORS Headers
#    add_header 'Access-Control-Allow-Origin' '*' always;
#    add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS, PUT, DELETE' always;
#    add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range,Authorization' always;

    # Disable directory listing
    autoindex off;

    # Alias for /slink
    location /slink {
        alias /var/glx/upload_file_glx/user_files/slink;
        autoindex off;
    }

    # Main location block
    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    # PHP-FPM Configuration
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
        fastcgi_intercept_errors on;
        fastcgi_buffer_size 16k;
        fastcgi_buffers 4 16k;
        fastcgi_connect_timeout 300;
        fastcgi_send_timeout 300;
        fastcgi_read_timeout 300;
    }

    # Deny access to .htaccess files
    location ~ /\.ht {
        deny all;
    }

    # Deny access to hidden files
    location ~ /\. {
        deny all;
        access_log off;
        log_not_found off;
    }


}
