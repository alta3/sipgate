## Update timesyncd config  

-----

1. The ubuntu ntp servers are too bogged down to respond to NTP. Log fills up griping ubuntu ntp servers are unresponsive, so point systemd-timesyncd to google NTP servers.

    `sudo vim /etc/systemd/timesyncd.conf`

       # CONFIG /etc/systemd/timesyncd.conf
       [Time]
       NTP=time.google.com
       FallbackNTP=time.google.com
       #RootDistanceMaxSec=5
       #PollIntervalMinSec=32
       #PollIntervalMaxSec=2048

0. Restart timesyncd

    `sudo systemctl restart systemd-timesyncd.service`
