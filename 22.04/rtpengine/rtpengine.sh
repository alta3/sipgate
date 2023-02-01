VER="1.1.1"

git clone https://github.com/sipwise/rtpengine.git

sudo apt install -y cmake debhelper init-system-helpers default-libmysqlclient-dev gperf libmysqlclient-dev libip4tc-dev libip6tc-dev libiptc-dev libxtables-dev libavcodec-dev libavfilter-dev libavformat-dev libavutil-dev libbencode-perl libcrypt-openssl-rsa-perl libcrypt-rijndael-perl libhiredis-dev libio-multiplex-perl libio-socket-inet6-perl libjson-glib-dev libdigest-crc-perl libdigest-hmac-perl libnet-interface-perl libnet-interface-perl libssl-dev libsystemd-dev libxmlrpc-core-c3-dev libcurl4-openssl-dev libevent-dev libpcap0.8-dev markdown unzip nfs-common dkms libspandsp-dev libjson-perl libmosquitto-dev libopus-dev libtest2-suite-perl libwebsockets-dev python3-websockets

cd ~/sipgate/22.04/rtpengine/rtpengine

wget https://codeload.github.com/BelledonneCommunications/bcg729/tar.gz/$VER -O bcg729_$VER.orig.tar.gz

tar zxf bcg729_$VER.orig.tar.gz

cd bcg729-$VER

git clone https://github.com/ossobv/bcg729-deb.git debian

dpkg-buildpackage -us -uc -sa -b -rfakeroot

cd ../

dpkg -i libbcg729-*.deb

dpkg-checkbuilddeps

dpkg-buildpackage -us -uc -sa

cd ../

sudo dpkg -i ngcp-rtpengine-daemon_*.deb ngcp-rtpengine-iptables_*.deb ngcp-rtpengine-kernel-dkms_*.deb
