import random
import time

import paho.mqtt.client as mqtt

BROKER = "broker.hivemq.com"
PORT = 1883
PREFIX = "hydroponics"


def on_connect(_client, _userdata, _flags, reason_code, _properties):
    if reason_code == 0:
        print(f"Connected to {BROKER}")
    else:
        print(f"Connection failed: {reason_code}")


client = mqtt.Client(mqtt.CallbackAPIVersion.VERSION2)
client.on_connect = on_connect
client.connect(BROKER, PORT)
client.loop_start()

time.sleep(1)

try:
    while True:
        temp = round(random.uniform(20.0, 26.0), 1)
        humidity = round(random.uniform(60.0, 80.0), 1)
        ph = round(random.uniform(5.8, 7.0), 2)
        light = random.randint(3000, 6000)
        water = random.randint(70, 95)
        nutrients = round(random.uniform(1.5, 2.2), 2)

        client.publish(f"{PREFIX}/temperature", temp)
        client.publish(f"{PREFIX}/humidity", humidity)
        client.publish(f"{PREFIX}/ph", ph)
        client.publish(f"{PREFIX}/light", light)
        client.publish(f"{PREFIX}/water_level", water)
        client.publish(f"{PREFIX}/nutrients", nutrients)

        print(
            f"temp={temp}°C  humidity={humidity}%  pH={ph}"
            f"  light={light}lux  water={water}%  EC={nutrients}"
        )
        time.sleep(3)
except KeyboardInterrupt:
    print("Stopped")
finally:
    client.loop_stop()
    client.disconnect()
