echo INSTALLING IP-JS
cd
git clone https://github.com/havfo/SipCaller.git
cd SipCaller/app
sudo apt -y install npm
npm install
npm run build
cd build/
export IP4_ADDR=$(ip a s ens3 | awk -F"[/ ]+" '/inet / {print $3}')
j2 ~/sipgate/22.04/content/config.js.j2  ~/sipgate/22.04/content/config.js
sudo cp ~/sipgate/22.04/content/config.js  /var/www/html/
cd ..
sudo cp -r * /var/www/html/
echo CUSTOMIZE the config.js file
js ~/sipgate/22.04/content/config.js.j2  ~/sipgate/22.04/content/config.js
sudo cp ~/sipgate/22.04/content/config.js  /var/www/html/
sudo chown -R www-data:www-data /var/www/html/
