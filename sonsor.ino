// YCAM AMP SHIELD PIN LAYOUT
// A0 - リファレンス用
// A1 - 測定値用
// A3 - 温度用
// A4,A5 - RTC通信用(I2C)

// 温度 = ((temp - 100) / 10.0) - 40.0;
#include <stdlib.h>
#include <Time.h>
#include <Wire.h>
//#include <SD.h>

#define AVG_COUNT  (32)
#define SLEEP_MS   (1000)
#define VCC        (5.0)
#define ADCUNIT    ((VCC / 1024.0) * 1000.0) // mV

//const int chipSelect = 8;

void setup() {
  Serial.begin(9600);
}


void loop() {
  float a0, a1, a2, volt;
  char buffer[10];
  String dataString;

  a0 = 0;
  a1 = 0;
  a2 = 0;

  // throw away 1st ADC value.
  analogRead(0);
  analogRead(1);

  // read analog input.
  // 32回とってきて平均するのかしら．
  for(int i = 0; i < AVG_COUNT; i++) {
    a0 += analogRead(0);
    a1 += analogRead(1);
  }

  volt = (float)((((a1 - a0) / AVG_COUNT) * (VCC / 1024.0)) / 5.0);\
  String voltage = dtostrf(volt, 8, 5, buffer);
  voltage.replace(" ", "");
  
    if(Serial.available()==1){
    byte inBuf[1];
    Serial.readBytes(inBuf,1);
    if(inBuf[0] == 's'){
      Serial.println(voltage);
    }
  }
  else{
    while(Serial.available() >0)Serial.read();
  }
  if (Serial.available()>1){
    while(Serial.available()>0)Serial.read();
  }

  //これこんなに必要か？
  //取得の速さと演出については考えなければ．
  delay(500);
}
