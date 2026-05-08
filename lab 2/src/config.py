import os

def try_parse(type, value):
    try:
        return type(value)
    except Exception:
        return None

MQTT_BROKER_HOST = os.environ.get('MQTT_BROKER_HOST') or 'localhost'
MQTT_BROKER_PORT = try_parse(int, os.environ.get('MQTT_BROKER_PORT')) or 1883
MQTT_TOPIC = os.environ.get('MQTT_TOPIC') or 'agent_data_topic'
DELAY = try_parse(float, os.environ.get('DELAY')) or 1
MQTT_PARKING_TOPIC = os.environ.get('MQTT_PARKING_TOPIC') or 'parking_data_topic'
