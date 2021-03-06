
#!/bin/bash

# stop services
echo "making sure services are not running"
sudo systemctl stop lnd 2>/dev/null

echo "keep old tls data as backup"
sudo mv /mnt/hdd/lnd/tls.cert /mnt/hdd/lnd/tls.cert.old 
sudo mv /mnt/hdd/lnd/tls.key /mnt/hdd/lnd/tls.key.old 

echo "let lnd generate new TLSCert"
sudo -u bitcoin /usr/local/bin/lnd &>/dev/null &
echo "wait until generated"
newCertExists=0
count=0
while [ ${newCertExists} -eq 0 ]
do
  count=$(($count + 1))
  echo "(${count}/60) check for cert"
  if [ ${count} -gt 60 ]; then
    echo "FAIL - was not able to generate new LND certs"
    exit 1
  fi
  newCertExists=$(sudo ls /mnt/hdd/lnd/tls.cert 2>/dev/null | grep -c '.cert')
  sleep 2
done
sudo killall /usr/local/bin/lnd
sudo chmod 664 /mnt/hdd/lnd/tls.cert
echo "copy new cert to admin user"
sudo cp /mnt/hdd/lnd/tls.cert /home/admin/.lnd
sudo chown admin:admin -R /home/admin/.lnd/*.cert
echo "OK TLS certs are fresh"