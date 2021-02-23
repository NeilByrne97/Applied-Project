#include "BluetoothSerial.h"
#include "WiFi.h"
HTTPClient http;


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
    Serial.write(SerialBT.read());
  }
  delay(20);

int httpCode;String line;
uint8_t sendEmployee(int currentID) {
    Serial.print("connecting to ");
    Serial.println(host);
    
    //This is the URL of the Post API 
    String url="http://192.168.0.164:3000/FingerPrint?id="+String(currentID); 
    
                                                         
    http.begin(url);
    
    //Specify content-type header
    http.addHeader("Content-Type", "application/x-www-form-urlencoded");  
    
    httpCode = http.POST("Message from ESP32");   //Send the request
    //Get the response payload
    line=Response(httpCode);
    Serial.println(line);   //Print HTTP return code
    // Serial.println(payload);    //Print request response payload
    
    http.end();  //Close connection
    Serial.println("send Data to web server");
}

String Response(int httpcode)   // Function to read response from the server.
{
 
  if (httpcode>0)
  {
   line = http.getString();   
    }
    else 
     { line="sucess";}
    return line;
  
  }


  

}
