#ssh to target host

cd

git clone https://github.com/alta3/sipgate.git

sudo apt install nginx -y

sudo rm /etc/nginx/sites-available/default.conf

sudo rm /etc/nginx/sites-enabled/default.conf

sudo cp /home/student/sipgate/22.04/nginx/webrtc.conf  /etc/nginx/conf.d/

sudo mkdir -p /var/www/html

sudo cp -r /home/student/sipgate/22.04/content/*  /var/www/html/   

sudo chown -R  www-data:www-data  /var/www/html/
