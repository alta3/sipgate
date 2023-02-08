echo INSTALLING IP-JS
cd
git clone https://github.com/havfo/SipCaller.git
cd SipCaller/app
sudo apt -y install npm
npm install
echo "Done installing, creating a DIR now."
sudo mkdir -p /var/www/html/
bash -c '/usr/bin/npm run build'
cd build/
echo "Uncomment ONE of the two following lines depending on the turn server in use)
export turn_ipv4="turn.alpha.alta3.com"
#export turn_ipv4="turn.bravo.alta3.com"
j2 ~/sipgate/22.04/content/config.js.j2 > ~/sipgate/22.04/content/config.js
sudo cp ~/sipgate/22.04/content/config.js  /var/www/html/
cd ..
sudo cp -r * /var/www/html/
sudo chown -R www-data:www-data /var/www/html/
