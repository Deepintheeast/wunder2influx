#!/bin/bash
# Installationsscript für 'wunder2influx' von Deepintheeast

timestamp=$(date +"%Y-%m-%d_%H-%M-%S")

# Username des Benutzers
username=$(whoami)
# Abfrage der Debian-Version
version=$(lsb_release -rs)

cd /home/$username

sudo apt install git

  if [ "$version" = "11" ]; then
    echo "Debian 11 erkannt. Führe Installationen für Debian 11 aus..."
    sudo apt install pip
    sudo apt-get install python3-venv

  elif [ "$version" = "12" ]; then
    echo "Debian 12 erkannt. Führe Installationen für Debian 12 aus..."
    sudo apt install python3-pip
    
  else
    echo "Unbekannte Debian-Version. Beende Skript."
    exit 1
  fi

# lokales Environment für User anlegen und aktivieren
  python3 -m venv ~/.env  
  source ~/.env/bin/activate  source ~/.env/bin/activate

  pip3 install requests
  pip3 install influxdb
  
  mkdir -p /home/$username/temp_wunder2influx
  mkdir -p /home/$username/scripts
  

cd /home/$username/temp_wunder2influx

git clone https://github.com/Deepintheeast/wunder2influx.git


echo 'Installation des Scripts für den Benutzer: '$username

  if [ -d "/home/$username/scripts/wunder2influx" ]; then
    mv -f /home/$username/scripts/wunder2influx /home/$username/scripts/wunder2influx-$timestamp.old
  fi

  mv wunder2influx /home/$username/scripts/wunder2influx
  chmod 755 /home/$username/scripts/wunder2influx/wunder2influx.py

  if ! grep -q "alias wunder2influx=" /home/$username/.bashrc; then
    echo "alias wunder2influx='cd /home/$username/scripts/wunder2influx && /home/$username/.env/bin/python3 ./wunder2influx.py'" >> /home/$username/.bashrc
  fi

echo ''
echo 'Zur automatischen Ausführung des Scriptes "Cron-Eintrag" festlegen, Beispiel -> siehe Readme Datei!'
echo ''
echo 'Installation beendet! Viel Spaß!'
echo ''

rm -rf /home/$username/temp_wunder2influx/
rm -f /home/$username/install.sh
source ~/.bashrc
