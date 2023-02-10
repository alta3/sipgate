echo INSTALLING IP-JS
cd
git clone https://github.com/havfo/SipCaller.git
cd SipCaller/app
sudo apt -y install npm
npm install
echo "Done installing, creating a DIR now."
sudo mkdir -p /var/www/html/
