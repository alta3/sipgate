## Install NGINX from source

The nginx server needs to be compiled from source to include the **ssl_preread_module** which is no longer available on new versions of nginx. This module allows the nginx server to proxy 
1. apt install dependancies

    `sudo apt install -y build-essential tree perl libperl-dev libgd3 libgd-dev libgeoip1 libgeoip-dev geoip-bin libxml2 libxml2-dev libxslt1.1 libxslt1-dev` 

0. Install user nginx

    `sudo adduser --system --no-create-home --shell /bin/false --group --disabled-login nginx`

0. Install nginx from source, we need modules avaible only by compiling. Download the tarballs...

    `wget https://nginx.org/download/nginx-1.16.1.tar.gz && tar zxvf nginx-1.16.1.tar.gz`
    
 0. Download PCRE version 8.42
 
    `wget https://ftp.pcre.org/pub/pcre/pcre-8.42.tar.gz && tar xzvf pcre-8.42.tar.gz`
    
0. Download zlib version 1.2.11

    `wget https://www.zlib.net/zlib-1.2.11.tar.gz && tar xzvf zlib-1.2.11.tar.gz`

0. Download OpenSSL version 1.1.0h

    `wget https://www.openssl.org/source/openssl-1.1.0h.tar.gz && tar xzvf openssl-1.1.0h.tar.gz`  

0. Remove the tarballs as they are no longer needed.

    `rm -rf *.tar.gz`

0. cd into nginx-1.16.1

    `cd ~/nginx-1.16.1`

0. Copy NGINX manual page to /usr/share/man/man8/ directory

   `sudo cp ~/nginx-1.16.1/man/nginx.8 /usr/share/man/man8`
   
   `sudo gzip /usr/share/man/man8/nginx.8`
   
   `ls /usr/share/man/man8/ | grep nginx.8.gz`
   
0. man page working?

    `man nginx`
    
0. Build the whole nine yards. The following is ONE LINE OF CODE ....

    `./configure --prefix=/etc/nginx --sbin-path=/usr/sbin/nginx --modules-path=/usr/lib/nginx/modules --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock --user=nginx --group=nginx --build=Ubuntu --builddir=nginx-1.16.1 --with-select_module --with-poll_module --with-threads --with-file-aio --with-http_ssl_module --with-http_v2_module --with-http_realip_module --with-http_addition_module --with-http_xslt_module=dynamic --with-http_image_filter_module=dynamic --with-http_geoip_module=dynamic --with-http_sub_module --with-http_dav_module --with-http_flv_module --with-http_mp4_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_auth_request_module --with-http_random_index_module --with-http_secure_link_module --with-http_degradation_module --with-http_slice_module --with-http_stub_status_module --with-http_perl_module=dynamic --with-perl_modules_path=/usr/share/perl/5.26.1 --with-perl=/usr/bin/perl --http-log-path=/var/log/nginx/access.log --http-client-body-temp-path=/var/cache/nginx/client_temp --http-proxy-temp-path=/var/cache/nginx/proxy_temp --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp --http-scgi-temp-path=/var/cache/nginx/scgi_temp --with-mail=dynamic --with-mail_ssl_module --with-stream=dynamic --with-stream_ssl_module --with-stream_realip_module --with-stream_geoip_module=dynamic --with-stream_ssl_preread_module --with-compat --with-pcre=../pcre-8.42 --with-pcre-jit --with-zlib=../zlib-1.2.11 --with-openssl=../openssl-1.1.0h --with-openssl-opt=no-nextprotoneg --with-debug`

0. Run make

    `make`
    
0. run make install

    `sudo make install`

0. cd back to the home directory
    
    `cd`

0. Checkout the version you just installed

    `sudo nginx -V`

0. create the ngix user

    `sudo adduser --system --home /nonexistent --shell /bin/false --no-create-home --disabled-login --disabled-password --gecos "nginx user" --group nginx`

0. Create NGINX directories and set permissions

    `sudo mkdir -p /var/cache/nginx/client_temp /var/cache/nginx/fastcgi_temp /var/cache/nginx/proxy_temp /var/cache/nginx/scgi_temp /var/cache/nginx/uwsgi_temp`

    `sudo chmod 700 /var/cache/nginx/*`

    `sudo chown nginx:root /var/cache/nginx/*`

0. Create NGINX systemd unit file.

    `sudo vim /etc/systemd/system/nginx.service`

       [Unit]
       Description=nginx - high performance web server
       Documentation=https://nginx.org/en/docs/
       After=network-online.target remote-fs.target nss-lookup.target
       Wants=network-online.target

       [Service]
       Type=forking
       PIDFile=/var/run/nginx.pid
       ExecStartPre=/usr/sbin/nginx -t -c /etc/nginx/nginx.conf
       ExecStart=/usr/sbin/nginx -c /etc/nginx/nginx.conf
       ExecReload=/bin/kill -s HUP $MAINPID
       ExecStop=/bin/kill -s TERM $MAINPID
       
       [Install]
       WantedBy=multi-user.target

0. Enable NGINX to start on boot and start NGINX immediately.

    `sudo systemctl enable nginx.service`
    
    `sudo systemctl start nginx.service`

0. Check if NGINX will automatically initiate after a reboot.

    `sudo systemctl is-enabled nginx.service`
    
       # enabled

0. edit /etc/nginx/nginx.conf

    `sudo vim /etc/nginx/nginx.conf`  

       user  nginx;
       worker_processes  1;

       error_log  /var/log/nginx/error.log warn;
       pid        /var/run/nginx.pid;

       load_module /usr/lib/nginx/modules/ngx_stream_module.so;
       events {
           worker_connections  1024;
       }


       http {
           include       /etc/nginx/mime.types;
           default_type  application/octet-stream;

           log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                             '$status $body_bytes_sent "$http_referer" '
                             '"$http_user_agent" "$http_x_forwarded_for"';

           access_log  /var/log/nginx/access.log  main;

           sendfile        on;
           #tcp_nopush     on;

           keepalive_timeout  65;

           #gzip  on;

           include /etc/nginx/conf.d/*.conf;
       }

       stream {
           log_format basic '$remote_addr [$time_local] '
                            '$protocol $status $bytes_sent $bytes_received '
                            '$session_time';

           access_log  /var/log/nginx/stream.log basic;
           error_log /var/log/nginx/stream-error.log debug;

           upstream turns_ipv4_80 {
               server 10.16.1.195:3479;
           }

           upstream http_ipv4_80 {
               server 127.0.0.1:3480;
           }

           map $ssl_preread_protocol $upstream_ipv4_80 {
               default turns_ipv4_80;
               "" http_ipv4_80;
           }

           upstream turns_ipv6_80 {
               server [fe80::20c:29ff:fead:8b42]:3479;
           }

           upstream http_ipv6_80 {
               server [::1]:3480;
           }

           map $ssl_preread_protocol $upstream_ipv6_80 {
               default turns_ipv6_80;
               "" http_ipv6_80;
           }

           upstream turn_ipv4_443 {
               server 10.16.1.195:3478;
           }

           upstream https_ipv4_443 {
               server 127.0.0.1:3443;
           }

           map $ssl_preread_protocol $upstream_ipv4_443 {
               default https_ipv4_443;
               "" turn_ipv4_443;
           }

           upstream turn_ipv6_443 {
               server [fe80::20c:29ff:fead:8b42]:3478;
           }

           upstream https_ipv6_443 {
               server [::1]:3443;
           }

           map $ssl_preread_protocol $upstream_ipv6_443 {
               default https_ipv6_443;
               "" turn_ipv6_443;
           }

           server {
               listen 80;
               proxy_pass $upstream_ipv4_80;
               ssl_preread on;
               proxy_buffer_size 16k;
           }

           server {
               listen [::]:80;
               proxy_pass $upstream_ipv6_80;
               ssl_preread on;
               proxy_buffer_size 16k;
           }

           server {
               listen 443;
               proxy_pass $upstream_ipv4_443;
               ssl_preread on;
               proxy_buffer_size 16k;
           }

           server {
               listen [::]:443;
               proxy_pass $upstream_ipv6_443;
               ssl_preread on;
               proxy_buffer_size 16k;
           }
       }    

0. edit /etc/nginx/conf.d/default.conf

    `sudo vim /etc/nginx/conf.d/default.conf`

       server_tokens off;                                                                                                                                                                                                                                                                                                                                                           
       add_header X-Frame-Options SAMEORIGIN;
       add_header X-Content-Type-Options nosniff;
       add_header X-XSS-Protection "1; mode=block";
       add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval' https://ssl.google-analytics.com https://assets.zendesk.com https://connect.facebook.net; img-src 'self' https://ssl.google-analytics.com https://s-static.ak.facebook.com https://assets.zendesk.com; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com https://assets.zendesk.com; font-src 'self' https://themes.googleusercontent.com; frame-src https://assets.zendesk.com https://www.facebook.com https://s-static.ak.facebook.com https://tautt.zendesk.com; object-src 'none'";

       # redirect all http traffic to https
       server {
               listen 3480 default_server;
               listen [::]:3480 default_server;

               server_name _;

               return 301 https://$host$request_uri;
        }

       server {
               listen 3443 ssl http2;

               server_name _;

               root /var/www/html;
               index index.html index.htm;

               ssl_certificate /etc/letsencrypt/live/sip.alta3.com/fullchain.pem;
               ssl_certificate_key /etc/letsencrypt/live/sip.alta3.com/privkey.pem;

               ssl_session_cache shared:SSL:50m;
               ssl_session_timeout 1d;
               ssl_session_tickets off;

       #       ssl_dhparam /etc/nginx/ssl/dhparam.pem;
               ssl_prefer_server_ciphers on;
               ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
               ssl_ciphers 'ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA:ECDHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES256-SHA:ECDHE-ECDSA-DES-CBC3-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:DES-CBC3-SHA:!DSS';

               add_header Strict-Transport-Security "max-age=31536000; includeSubdomains; preload";

               location /ws {
                       proxy_pass https://127.0.0.1:4443/;
                       proxy_http_version 1.1;
                       proxy_set_header Upgrade $http_upgrade;
                       proxy_set_header Connection "upgrade";
                       proxy_read_timeout 86400;
               }
       }

       server {
               listen [::]:3443 ssl http2;

               server_name _;

               root /var/www/html;
               index index.html index.htm;

               ssl_certificate /etc/letsencrypt/live/sip.alta3.com/fullchain.pem;
               ssl_certificate_key /etc/letsencrypt/live/sip.alta3.com/privkey.pem;

               ssl_session_cache shared:SSL:50m;
               ssl_session_timeout 1d;
               ssl_session_tickets off;

       #       ssl_dhparam /etc/nginx/ssl/dhparam.pem;
               ssl_prefer_server_ciphers on;
               ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
               ssl_ciphers 'ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA:ECDHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES256-SHA:ECDHE-ECDSA-DES-CBC3-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:DES-CBC3-SHA:!DSS';

               add_header Strict-Transport-Security "max-age=31536000; includeSubdomains; preload";

               location /ws {
                       proxy_pass https://[::1]:4443/;
                       proxy_http_version 1.1;
                       proxy_set_header Upgrade $http_upgrade;
                       proxy_set_header Connection "upgrade";
                       proxy_read_timeout 86400;
               }
       }

0. Edit /etc/nginx/sites-available/default. File is avaiable at ~/sipgate/nginx/etc/nginx/sites-available/default

       server_tokens off;
       add_header X-Frame-Options SAMEORIGIN;
       add_header X-Content-Type-Options nosniff;
       add_header X-XSS-Protection "1; mode=block";
       add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval' https://ssl.google-analytics.com https://assets.zendesk.com https://connect.facebook.net; img-src 'self' https://ssl.google-analytics.com https://s-static.ak.facebook.com https://assets.zendesk.com; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com https://assets.zendesk.com; font-src 'self' https://themes.googleusercontent.com; frame-src https://assets.zendesk.com https://www.facebook.com https://s-static.ak.facebook.com https://tautt.zendesk.com; object-src 'none'";

       # redirect all http traffic to https
       server {
               listen 80 default_server;
               listen [::]:80 default_server;

               server_name _;

               return 301 https://$host$request_uri;
       }

       server {
               listen 443 ssl http2;

               server_name _;

               root /var/www/html;
               index index.html index.htm;

               ssl_certificate /etc/letsencrypt/live/sip.alta3.com/fullchain.pem;
               ssl_certificate_key /etc/letsencrypt/live/sip.alta3.com/privkey.pem;

               ssl_session_cache shared:SSL:50m;
               ssl_session_timeout 1d;
               ssl_session_tickets off;

       #       ssl_dhparam /etc/nginx/ssl/dhparam.pem;
               ssl_prefer_server_ciphers on;
               ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
               ssl_ciphers 'ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA:ECDHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES256-SHA:ECDHE-ECDSA-DES-CBC3-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:DES-CBC3-SHA:!DSS';

               add_header Strict-Transport-Security "max-age=31536000; includeSubdomains; preload";

               location /ws {
                       proxy_pass https://127.0.0.1:4443/;
                       proxy_http_version 1.1;
                       proxy_set_header Upgrade $http_upgrade;
                       proxy_set_header Connection "upgrade";
                       proxy_read_timeout 86400;
               }
       }

       server {
               listen [::]:443 ssl http2;

               server_name _;

               root /var/www/html;
               index index.html index.htm;

               ssl_certificate /etc/letsencrypt/live/sip.alta3.com/fullchain.pem;
               ssl_certificate_key /etc/letsencrypt/live/sip.alta3.com/privkey.pem;

               ssl_session_cache shared:SSL:50m;
               ssl_session_timeout 1d;
               ssl_session_tickets off;

       #       ssl_dhparam /etc/nginx/ssl/dhparam.pem;
               ssl_prefer_server_ciphers on;
               ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
               ssl_ciphers 'ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA:ECDHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES256-SHA:ECDHE-ECDSA-DES-CBC3-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:DES-CBC3-SHA:!DSS';

               add_header Strict-Transport-Security "max-age=31536000; includeSubdomains; preload";

               location /ws {
                       proxy_pass https://[::1]:4443/;
                       proxy_http_version 1.1;
                       proxy_set_header Upgrade $http_upgrade;
                       proxy_set_header Connection "upgrade";
                       proxy_read_timeout 86400;
               }
       }

0. Check NGINX syntax and potential errors

    `sudo nginx -t`

0. Restart nginx

    `sudo service nginx restart`
