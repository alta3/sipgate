cd ~/SipCaller/app/build/
echo "Uncomment ONE of the two following lines depending on the turn server in use"
export TURN_CLOUD=$(nslookup 10.0.0.1 | grep -oP alpha||bravo)
export TURN_FQDN="turn.$TURN_CLOUD.alta3.com"
j2 ~/sipgate/22.04/content/config.js.j2 > ~/sipgate/22.04/content/config.js
sudo cp ~/sipgate/22.04/content/config.js  /var/www/html/
cd ..
sudo cp -r * /var/www/html/
sudo chown -R www-data:www-data /var/www/html/
