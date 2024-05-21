#!/usr/bin/env python3
""" Python-Script zum Abrufen von Daten von einem Ecowater-Softener-Gerät 
    und Schreiben der Daten in eine InfluxDB-Datenbank."""
from ecowater_softener import Ecowater
# https://github.com/barleybobs/ecowater-softener
from influxdb import InfluxDBClient

ecowater_user = 'xxxxxx'
ecowater_password = 'xxxxxx'
ecowater_seriennummer = 'xxxxxx'

influxdb_host = 'localhost'
influxdb_port = 8086
influxdb_dbname = 'ecowater'


def write_to_influxdb(data):
    # Erstellen Sie eine Verbindung zur InfluxDB-Datenbank
    client = InfluxDBClient(host=influxdb_host, port=influxdb_port)

    # Wählen Sie die Datenbank aus
    client.switch_database(influxdb_dbname)

    # Formatieren Sie die Daten für InfluxDB
    points = []
    for key, value in data.items():
        points.append({
            "measurement": "ecowater",
            "fields": {
                key: value
            }
        })

    # Schreiben Sie die Daten in die Datenbank
    client.write_points(points)

ecowaterDevice = Ecowater(ecowater_user, ecowater_password, ecowater_seriennummer)

# returns 'all data other commands can get' as a dictionary
#ecowaterDevice.getData()
data_ecowater = (ecowaterDevice.getData())

# Ausgabe der Daten
print(data_ecowater)

# Schreiben der Daten in die InfluxDB-Datenbank
write_to_influxdb(data_ecowater)

print('Daten erfolgreich in die InfluxDB-Datenbank geschrieben')
