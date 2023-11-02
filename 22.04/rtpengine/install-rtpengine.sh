VER="1.1.1"

sudo apt update

sudo apt upgrade

sudo apt install -y cmake debhelper init-system-helpers default-libmysqlclient-dev gperf libmysqlclient-dev libip4tc-dev libip6tc-dev libiptc-dev libxtables-dev libavcodec-dev libavfilter-dev libavformat-dev libavutil-dev libbencode-perl libcrypt-openssl-rsa-perl libcrypt-rijndael-perl libhiredis-dev libio-multiplex-perl libio-socket-inet6-perl libjson-glib-dev libdigest-crc-perl libdigest-hmac-perl libnet-interface-perl libnet-interface-perl libssl-dev libsystemd-dev libxmlrpc-core-c3-dev libcurl4-openssl-dev libevent-dev libpcap0.8-dev markdown unzip nfs-common dkms libspandsp-dev libjson-perl libmosquitto-dev libopus-dev libtest2-suite-perl libwebsockets-dev python3-websockets libmnl-dev libncurses-dev libnftnl-dev pandoc

git clone https://github.com/alta3/sipgate.git

cd ~/sipgate/22.04/rtpengine/

git clone https://github.com/sipwise/rtpengine.git

cd ~/sipgate/22.04/rtpengine/rtpengine

wget https://codeload.github.com/BelledonneCommunications/bcg729/tar.gz/$VER -O bcg729_$VER.orig.tar.gz

tar zxf bcg729_$VER.orig.tar.gz

cd ~/sipgate/22.04/rtpengine/rtpengine/bcg729-$VER

git clone https://github.com/ossobv/bcg729-deb.git debian

sudo dpkg-buildpackage -us -uc -sa -b -rfakeroot

cd ../

sudo dpkg -i libbcg729-*.deb

sudo dpkg-checkbuilddeps

sudo dpkg-buildpackage -us -uc -sa

cd ../

sudo dpkg -i ngcp-rtpengine-daemon_*.deb ngcp-rtpengine-iptables_*.deb ngcp-rtpengine-kernel-dkms_*.deb

cd
