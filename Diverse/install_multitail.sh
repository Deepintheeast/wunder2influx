#!/bin/bash
# Installationsscript für "multitail" Erweiterung für die Solaranzeige
# Installation mit
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
if ! sudo grep -q "colorscheme:solaranzeige" /etc/multitail.conf; then
    sudo bash -c "echo -e '#colorschemes:\n\
    colorscheme:solaranzeige\n\
    cs_re:blue:^[0-3][0-9][/.][0-3][0-9][/.] [0-3][0-9]:[0-5][0-9]:[0-5][0-9]\n\
    cs_re_s:magenta:(.*MQT.*)\n\
    cs_re_s:yellow:(.*InfluxDB.*)\n\
    \n\" >> /etc/multitail.conf"
    echo "Farbschema für 'solaranzeige.log' wurde angelegt."
fi
echo "Farbschema für 'solaranzeige.log' existiert bereits."


if ! sudo grep -q "colorscheme:automation" /etc/multitail.conf; then
    sudo bash -c "echo -e '#colorschemes:\n\  
    colorscheme:automation\n\
    cs_re:blue:^[0-3][0-9][/.][0-3][0-9][/.] [0-3][0-9]:[0-5][0-9]:[0-5][0-9]\n\
    cs_re_s:red,,bold:(ERRO.*)\n\
    cs_re_s:blue:.(WARN.*)\n\
    cs_re_s:green:(INFO.*)\n\
    cs_re_s:magenta:(ENDE.*)\n\
    \n\" >> /etc/multitail.conf"
    echo "Farbschema für 'automation.log' wurde angelegt."
fi
echo "Farbschema für 'automation.log' existiert bereits."


if ! sudo grep -q "# default colorschemes für solaranzeige" /etc/multitail.conf; then
    sudo bash -c "echo -e '#colorschemes:\n\
    # default colorschemes für solaranzeige:\n\
    scheme:automation:/var/www/log/automation.log\n\
    scheme:solaranzeige:/var/www/log/solaranzeige.log' >> /etc/multitail.conf"
    echo "Farbschemen für Solaranzeige wurde aktiviert."
fi
echo "Farbschemen für Solaranzeige sind bereits aktiviert."
echo ""
echo "Installation abgeschlossen. Bitte neu einloggen oder 'source ~/.bashrc' ausführen."
echo "Danach kann 'sazlog' ausgeführt werden, um die Logs der Solaranzeige und der Automation in Multitail anzuzeigen."

# Installer beenden und löschen
rm -f /home/$username/install_multitail.sh
