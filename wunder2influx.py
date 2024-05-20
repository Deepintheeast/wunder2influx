#!/usr/bin/env python3
"""
Abholen von Daten einer Wetterstation bei "Wunderground" und 
Speichern der Daten in einer InfluxDB Datenbank
"""

import time
import requests
from influxdb import InfluxDBClient

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

# URL der API
url = f"https://api.weather.com/v2/pws/observations/current?apiKey={api_key}&stationId={station_id}&format=json&units=m"


def fetch_weather_data(url):
    """Holt Wetterdaten von der API und gibt sie als Dictionary zurück"""
    # Anfrage an die API senden
    response = requests.get(url)
    # Antwort als JSON umwandeln
    data = response.json()
    # Windrichtung umwandeln
    data["observations"][0]["winddir"] = grad_to_richtung(
        data["observations"][0]["winddir"]
    )
    # Relevanten Wetterdaten in ein Dictionary packen
    weather_data = {
        "Temperatur": data["observations"][0]["metric"]["temp"],
        "Luftfeuchtigkeit": data["observations"][0]["humidity"],
        "Luftdruck": data["observations"][0]["metric"]["pressure"],
        "Sonnenstrahlung": data["observations"][0]["solarRadiation"],
        "UV-Strahlung": data["observations"][0]["uv"],
        "Windgeschwindigkeit": data["observations"][0]["metric"]["windSpeed"],
        "Windrichtung": data["observations"][0]["winddir"],
        "Niederschlag mm/h": data["observations"][0]["metric"]["precipRate"],
        "Niederschlag 24h": data["observations"][0]["metric"]["precipTotal"],
    }
    return weather_data

def grad_to_richtung(grad):
    """Wandelt Windrichtung in Grad in eine Himmelsrichtung um"""
    richtungen = [
        "N",
        "NNO",
        "NO",
        "ONO",
        "O",
        "OSO",
        "SO",
        "SSO",
        "S",
        "SSW",
        "SW",
        "WSW",
        "W",
        "WNW",
        "NW",
        "NNW",
    ]
    index = round(grad / 22.5) % 16
    return richtungen[index]

def write_to_influxdb(weather_data, station_id):
    """Schreibt Wetterdaten in die InfluxDB-Datenbank"""
    # InfluxDB-Client erstellen
    client = InfluxDBClient(host=influx_db_adresse, port=influx_db_port)
    # Datenbank auswählen
    client.switch_database(influx_db_name)
    # Daten vorbereiten
    weather_data_influx = [
        {
            "measurement": "weather",
            "tags": {
                "location": station_id,
            },
            "fields": weather_data,
        }
    ]
    # Daten in die Datenbank schreiben
    client.write_points(weather_data_influx)



# Wetterdaten abrufen
weather_data = fetch_weather_data(url)
# Wetterdaten ausgeben
print(weather_data)
# Wetterdaten in die InfluxDB-Datenbank schreiben
write_to_influxdb(weather_data, station_id)
print("Wetterdaten erfolgreich in InfluxDB geschrieben")
