#!/bin/bash
# Installationsscript für "multitail" Erweiterung für die Solaranzeige
# Installation mit:
# wget https://raw.githubusercontent.com/Deepintheeast/wunder2influx/main/Diverse/install_multitail.sh && bash ./install_multitail.sh

# Username des Benutzers
username=$(whoami)

cd /home/$username

# multitail installieren
sudo apt-get install multitail
echo "multitail installiert."
# alias für multitail anlegen
# Überprüfen, ob der Alias bereits existiert
if ! grep -q "alias sazlog=" /home/$username/.bashrc; then
    # Alias für multitail anlegen
    echo "alias sazlog='multitail -N 300 -i /var/www/log/solaranzeige.log -i /var/www/log/automation.log'" >> /home/$username/.bashrc
    echo "Alias 'sazlog' für Multitail wurde angelegt."
fi
echo "Alias 'sazlog' für Multitail existiert bereits."

# Ein bisschen Farbe gefällig?
# Farbschema für "solaranzeige.log" und "automation.log" anlegen
# und an /etc/multitail.conf anhängen
# Überprüfen und hinzufügen des ersten Blocks
if ! sudo grep -q "colorscheme:solaranzeige" /etc/multitail.conf; then
    sudo bash -c 'echo -e "colorscheme:solaranzeige\n\
    cs_re:blue:^[0-3][0-9][/.][0-3][0-9][/.] [0-3][0-9]:[0-5][0-9]:[0-5][0-9]\n\
    cs_re_s:magenta:(.*MQT.*)\n\
    cs_re_s:yellow:(.*InfluxDB.*)\n\
    cs_re_s:red,,bold:(.*Error.*)\n" >> /etc/multitail.conf'
    echo "colorscheme:solaranzeige wurde hinzugefügt."
else
    echo "colorscheme:solaranzeige ist bereits vorhanden."
fi

# Überprüfen und hinzufügen des zweiten Blocks
if ! sudo grep -q "colorscheme:automation" /etc/multitail.conf; then
    sudo bash -c 'echo -e "colorscheme:automation\n\
    cs_re:blue:^[0-3][0-9][/.][0-3][0-9][/.] [0-3][0-9]:[0-5][0-9]:[0-5][0-9]\n\
    cs_re_s:red,,bold:(ERRO.*)\n\
    cs_re_s:blue:.(WARN.*)\n\
    cs_re_s:green:(INFO.*)\n\
    cs_re_s:magenta:(ENDE.*)\n" >> /etc/multitail.conf'
    echo "colorscheme:automation wurde hinzugefügt."
else
    echo "colorscheme:automation ist bereits vorhanden."
fi

# Überprüfen und hinzufügen des dritten Blocks
if ! sudo grep -q "scheme:automation:/var/www/log/automation.log" /etc/multitail.conf; then
    sudo bash -c 'echo -e "## colorschemes solaranzeige\n\
    # default colorschemes:\n\
    scheme:automation:/var/www/log/automation.log\n\
    scheme:solaranzeige:/var/www/log/solaranzeige.log" >> /etc/multitail.conf'
    echo "Default Colorschemes wurden aktiert."
else
    echo "Default Colorschemes bereits aktiert."
fi

echo ""
echo "Installation abgeschlossen. "
echo "Mit 'sazlog' kann man sich nun die Logs der 'Solaranzeige' und der 'Automation' in Multitail anzuzeigen."
echo "Durch hinzufügen weiterer 'aliase' können auch andere 'Anzeigekonfigurationen' erzeugt werde!"
echo ""
echo "Have Fun!"

# Installer beenden und löschen
rm -f /home/$username/install_multitail.sh
source ~/.bashrc
