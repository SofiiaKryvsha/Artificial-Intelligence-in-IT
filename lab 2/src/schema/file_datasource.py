from csv import reader
from datetime import datetime
from domain.aggregated_data import AggregatedData
from domain.accelerometer import Accelerometer
from domain.gps import Gps

class FileDatasource:
    def __init__(self, accelerometer_filename: str, gps_filename: str) -> None:
        self.accelerometer_filename = accelerometer_filename
        self.gps_filename = gps_filename
        self.accelerometer_file = None
        self.gps_file = None
        self.accelerometer_reader = None
        self.gps_reader = None
    
    def read(self) -> AggregatedData:
        """Метод повертає дані отримані з датчиків"""
        try:
            # Читаємо рядок з акселерометра
            accelerometer_row = next(self.accelerometer_reader)
            # Читаємо рядок з GPS
            gps_row = next(self.gps_reader)
            
            # Створюємо об'єкти
            accelerometer = Accelerometer(
                x=int(accelerometer_row[0]),
                y=int(accelerometer_row[1]),
                z=int(accelerometer_row[2])
            )
            
            gps = Gps(
                longitude=float(gps_row[0]),
                latitude=float(gps_row[1])
            )
            
            # Повертаємо агреговані дані
            return AggregatedData(
                accelerometer=accelerometer,
                gps=gps,
                time=datetime.now()
            )
        except StopIteration:
            # Якщо файл закінчився, починаємо з початку
            self.stopReading()
            self.startReading()
            return self.read()
    
    def startReading(self, *args, **kwargs):
        """Метод повинен викликатись перед початком читання даних"""
        # Відкриваємо файли
        self.accelerometer_file = open(self.accelerometer_filename, 'r')
        self.gps_file = open(self.gps_filename, 'r')
        
        # Створюємо readers
        self.accelerometer_reader = reader(self.accelerometer_file)
        self.gps_reader = reader(self.gps_file)
        
        # Пропускаємо заголовки (якщо є)
        next(self.accelerometer_reader, None)
        next(self.gps_reader, None)
    
    def stopReading(self, *args, **kwargs):
        """Метод повинен викликатись для закінчення читання даних"""
        if self.accelerometer_file:
            self.accelerometer_file.close()
        if self.gps_file:
            self.gps_file.close()
