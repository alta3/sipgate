ssh to target host

cd

git clone https://github.com/alta3/sipgate.git

sudo apt install nginx

sudo rm /etc/nginx/sites-available/default.conf

sudo rm /etc/nginx/sites-enabled/default.conf

sudo cp /home/student/sipgate/22.04/nginx/webrtc.conf  /etc/nginx/conf.d/

sudo mkdir -p /var/www/html

cp -r /home/student/sipgate/18.04/client/*   /home/student/sipgate/22.04/client/

cp -r /home/student/sipgate/22.04/client/*  /var/www/html/   

sudo chown -r  www-data:www-data  /var/www/html/
