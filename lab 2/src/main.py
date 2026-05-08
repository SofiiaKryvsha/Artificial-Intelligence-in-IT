from paho.mqtt import client as mqtt_client
from paho.mqtt.enums import CallbackAPIVersion
import time
from schema.aggregated_data_schema import AggregatedDataSchema
from schema.parking_schema import ParkingSchema
from file_datasource import FileDatasource
import config


def connect_mqtt(broker, port):
    """Create MQTT client with retry logic"""
    print(f"CONNECT TO {broker}:{port}")

    def on_connect(client, userdata, flags, rc):
        if rc == 0:
            print(f"Connected to MQTT Broker ({broker}:{port})!")
        else:
            print(f"Failed to connect {broker}:{port}, return code {rc}")

    # Виправлення DeprecationWarning — використовуємо новий API
    client = mqtt_client.Client(callback_api_version=CallbackAPIVersion.VERSION2)
    client.on_connect = on_connect

    # Retry логіка — чекаємо поки MQTT брокер запуститься
    while True:
        try:
            client.connect(broker, port)
            break
        except (ConnectionRefusedError, OSError) as e:
            print(f"Connection failed: {e}. Retrying in 5 seconds...")
            time.sleep(5)

    client.loop_start()
    return client


def publish(client, topic, parking_topic, datasource, delay):
    datasource.startReading()

    while True:
        time.sleep(delay)

        # Відправка агрегованих даних (акселерометр + GPS)
        data = datasource.read()
        msg = AggregatedDataSchema().dumps(data)
        result = client.publish(topic, msg)
        if result[0] != 0:
            print(f"Failed to send message to topic {topic}")

        # Відправка даних паркінгу
        parking_data = datasource.read_parking()
        if parking_data:
            parking_msg = ParkingSchema().dumps(parking_data)
            p_result = client.publish(parking_topic, parking_msg)
            if p_result[0] != 0:
                print(f"Failed to send message to topic {parking_topic}")


def run():
    client = connect_mqtt(config.MQTT_BROKER_HOST, config.MQTT_BROKER_PORT)
    datasource = FileDatasource(
        "data/accelerometer.csv",
        "data/gps.csv",
        "data/parking.csv",
    )
    publish(client, config.MQTT_TOPIC, config.MQTT_PARKING_TOPIC, datasource, config.DELAY)


if __name__ == "__main__":
    run()
