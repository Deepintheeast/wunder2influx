# wunder2influx

## Auslesen "einer Wetterstation" bei Wunderground und speichern der Daten in einer InfluxDB.

Das ganze funktioniert nicht nur mit Eurer eigenen Wetterstation! 
Ihr könnt auch beliebige andere Wetterstationen bei Wunderground "abgreifen"!
Ob es in Eurer Nachbarschaft oder anderen gewünschten Orten "Wetterstationen" gibt bekommt Ihr einfach auf der WunderMap https://www.wunderground.com/wundermap heraus.
 Ein Klick auf die gewünschte Station zeigt Euch auch die "Station-ID" welche Ihr zum Einrichten des Scriptes benötigt!
## Installation

Mit folgendem Befehl wird das Installationsprogramm runtergeladen und ausgeführt.
```
wget https://raw.githubusercontent.com/Deepintheeast/wunder2influx/main/install.sh && bash ./install.sh
```
## Konfiguration und Erstellen der benötigten Datenbank
Vor dem ersten Betrieb müssen einige Einstellungen getätigt werden und eine neue Datenbank angelegt werden. 

Öffnet dazu das Script mit einem Editor

```mcedit /home/"username"/scripts/wunder2influx/wunder2influx.py```

(Achtung "username" mit eurem Usernamen (pi) ersetzen !)
und passt folgende Werte entsprechend an:
`````
# API-Schlüssel und Stations-ID
# Habt ihr einen eigenen Key dann hier eintragen
api_key = "e1f10a1e78da46f5b10a1e78da96f525"
# gewünschte Stations ID eintragen
station_id = "XXXXXXX"

# Adresse und Port der InfluxDB
# diese Einstellungen sollten in der Regel so funktionieren
influx_db_adresse = "127.0.0.1"
influx_db_port = "8086"

# Name der InfluxDB-Datenbank
# hier könnt ihr den Namen der Datenbank in die die Werte geschrieben werden sollen festlegen
# Achtung! Diese Datenbank muss existent sein -> Bitte vorher anlegen !
influx_db_name = "wunderweather"
`````
Zum Anlegen der Datenbank rufen wir jetzt auf der Konsole Influx auf und erstellen die "neue" DB (wunderweather):

````
influx
> create database wunderweather
> quit
````
Haben wir das soweit vorgenommen, reicht zum Test des Scriptes 

ein beherztes: 

```
wunder2influx
```

auf der Konsole sollte eine Ausgabe wie diese bringen
`````
{'Temperatur': 24, 'Luftfeuchtigkeit': 45, 'Luftdruck': 1018.96, 'Sonnenstrahlung': 916.7, 'UV-Strahlung': 7.2, 'Windgeschwindigkeit': 2, 'Windrichtung': 'WNW', 'Niederschlag mm/h': 0.0, 'Niederschlag 24h': 0.0}
Wetterdaten erfolgreich in InfluxDB geschrieben
`````

Klappt das soweit müssen wir das ganze nur noch "automatisieren"!
Dazu erstellen wir uns einen entsprechenden "Cron" Eintrag.
(im Beispiel erfolgt der Abruf der Daten zwischen 6:00 -> 21:00 Uhr aller 3 Minten und ausserhalb der Zeit aller 15 Minuten! Solltet Ihr nicht als User "pi" benutzen das ganze entsprechend anpassen!)

wir öffnen die Crontabelle mit:
````
crontab -e
````
und fügen an das Ende folgende Zeilen an und speichern das ganze:

```
*/3 6-20 * * * cd /home/pi/scripts/wunder2influx && /home/pi/.env/bin/python3 ./wunder2influx.py
*/15 0-5,21-23 * * * cd /home/pi/scripts/wunder2influx && /home/pi/.env/bin/python3 ./wunder2influx.py
```
Sollte es hierbei Probleme geben könnt Ihr die beiden Zeilen auch per Konsolenbefehl hinzufügen

```
echo  -e  "$(crontab -l)\n*/3 6-20 * * * cd /home/pi/scripts/wunder2influx && /home/pi/.env/bin/python3 ./wunder2influx.py" | crontab -
```
```
echo  -e  "$(crontab -l)\n*/15 0-5,21-23 * * * cd /home/pi/scripts/wunder2influx && /home/pi/.env/bin/python3 ./wunder2influx.py" | crontab -
```
Einfach jede der beiden Zeilen in die Konsole kopieren und mit "Enter" ausführen!

Habt Ihr das soweit richtig durchgeführt sollten nun die Daten automatisch abgeholt und gespeichert werden.

Zum testen ob auch Daten in der Datenbank ankommen ein paar Minuten warten und dann nachschauen:
```
influx
> use wunderweather
>  SELECT * FROM "weather" WHERE time > now() -15m
> Quit
````

Have Fun!



