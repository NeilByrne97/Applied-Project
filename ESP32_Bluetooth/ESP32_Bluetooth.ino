#include "BluetoothSerial.h"
#include "WiFi.h"

// WiFi config
const char* ssid="Infinitang IV";
const char* password = "PowPowPow1";

// Check if bluetooth is enabled
#if !defined(CONFIG_BT_ENABLED) || !defined(CONFIG_BLUEDROID_ENABLED)
#error Bluetooth is not enabled! Please run `make menuconfig` to and enable it
#endif

BluetoothSerial SerialBT;
WiFiClient client; 

void setup() {
  Serial.begin(115200);
 // Wifi setup
  Serial.print("Wifi connecting to ");
  Serial.println( ssid );
  WiFi.begin(ssid,password);
  Serial.println();
  Serial.print("Connecting");

    while( WiFi.status() != WL_CONNECTED ){
      delay(500);
      Serial.print(".");        
  }
  
  // Print WIFI
  Serial.println();
  Serial.println("Wifi Connected Success!");
  Serial.print("NodeMCU IP Address : ");
  Serial.println(WiFi.localIP() );

  // Print BLUETOOTH
  SerialBT.begin("ESP32"); //Bluetooth device name
  Serial.println("The device started, now you can pair it with bluetooth!");
}

void loop() {
  if (Serial.available()) { 
    SerialBT.write(Serial.read());
  }
  if (SerialBT.available()) {
    String infoString=SerialBT.readString();
    Serial.println("String is " + infoString); 
    convertString(infoString);
  }
  delay(20);  
}

void convertString(String infoString){
  Serial.println("String arrived, it is " + infoString);
  
  //char splitString[] = infoString;

  char splitString [1024];
  strcpy(splitString, infoString.c_str());
  
  char *token = strtok(splitString, "-");

  while(token != NULL){
    printf("%s\n", token);
    token = strtok(NULL, "-");
    
  }
}
