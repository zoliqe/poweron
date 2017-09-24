// SoftwareSerial - Version: Latest 
#include <SoftwareSerial.h>

const int ledPin = 13;
const int timeOutMins = 1; 

SoftwareSerial catSerial(2, 3); // RX, TX
bool state = false;
unsigned long milisStop;

void setup() {
  while (!Serial) {
    ;
  }
  Serial.begin(9600);
  Serial.println("READY");
  Serial.flush();
  pinMode(ledPin, OUTPUT);
  digitalWrite(ledPin, state);

  catSerial.begin(9600);
}

void loop() {
  if (Serial && Serial.available()) {
    int val = Serial.read();
    // Serial.write(val);
    if (val == 'H') {
      on();
    } else if (val == 'L') {
      off();
    } else if (val == 'N') {
      swstate();
    }
//    Serial.write("\r\n> ");
  }
  if (state) {
    if (millis() > milisStop) {
      off();
    } else {
      info();
    }
  }
  delay(1000);
}

void on() {
  state = HIGH;
  milisStop = millis() + (timeOutMins * 60000);
  swstate();
}

void off() {
  if (!state) {
    return;
  }
  state = LOW;
  swstate();
}

void swstate() {
  Serial.println(state ? "HIGH" : "LOW");
  digitalWrite(ledPin, state);
  Serial.flush();
}

void info() {
  unsigned long remains = milisStop - millis();
  unsigned int mins = remains / 60000;
  unsigned int secs = (remains - mins * 60000) / 1000;
  Serial.print(mins < 10 ? "T0" : "T");
  Serial.print(mins);
  Serial.print(secs < 10 ? ":0" : ":");
  Serial.println(secs);
  Serial.flush();

  if (catSerial && catSerial.available()) {
    iqrg();
  }
}

void iqrg() {
  uint8_t buff[11];
  uint8_t len = 0;
  Serial.print("CIV=");
  while (catSerial.available() && len < 11) {
    buff[len] = catSerial.read();
    Serial.print(buff[len]);
    Serial.print(',');
    len++;
  }
  Serial.println("");
  Serial.flush();
  if (buff[4] == 0 || buff[4] == 3) {
    uint8_t MHZ_100 = (buff[8]);
    MHZ_100 = MHZ_100 - (((MHZ_100 / 16) * 6));
    uint8_t MHZ = (buff[7]);
    MHZ = MHZ - (((MHZ / 16) * 6));
    uint8_t KHZ = buff[6];
    KHZ = KHZ - (((KHZ / 16) * 6));
    uint8_t HZ = buff[5];
    HZ = HZ - (((HZ / 16) * 6));
    unsigned long QRG = ((MHZ * 10000) + (KHZ * 100) + (HZ * 1));
    Serial.print("QRG=");
    Serial.println(QRG);
  }
}
