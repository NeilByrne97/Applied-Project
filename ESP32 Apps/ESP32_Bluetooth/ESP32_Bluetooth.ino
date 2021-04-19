#include "BluetoothSerial.h"
#include "WiFi.h"
#include "HTTPClient.h"
#include <ArduinoJson.h>
#include <AsyncTCP.h>
#include <ESPAsyncWebServer.h>
#include <AsyncElegantOTA.h>
#include <TelnetStream.h>

// WiFi config
const char* ssid="Infinitang IV";
const char* password = "PowPowPow1";
char jsonOutput[128];

AsyncWebServer server(80); // Port 80

// Check if bluetooth is enabled
#if !defined(CONFIG_BT_ENABLED) || !defined(CONFIG_BLUEDROID_ENABLED)
#error Bluetooth is not enabled! Please run `make menuconfig` to and enable it
#endif

BluetoothSerial SerialBT;
WiFiClient client; 

void setup() {
  Serial.begin(115200);
  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid, password);
  Serial.println("");

  // Wait for connection
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("");
  Serial.print("Connected to ");
  Serial.println(ssid);
  Serial.print("IP address: ");
  Serial.println(WiFi.localIP());

  server.on("/", HTTP_GET, [](AsyncWebServerRequest *request) {
    request->send(200, "text/plain", "Hi! I am ESP32.");
  });

  AsyncElegantOTA.begin(&server);    // Start ElegantOTA
  server.begin();
  Serial.println("HTTP server started");

  // Print BLUETOOTH
  SerialBT.begin("ESP32"); //Bluetooth device name
  Serial.println("Bluetooth started");

  TelnetStream.begin();
}

void loop() {
    AsyncElegantOTA.loop();
  if (Serial.available()) { 
    SerialBT.write(Serial.read());
  }
  if (SerialBT.available()) {
    String infoString=SerialBT.readString();
    convertString(infoString);
  }
  delay(20);  
}

void convertString(String infoString){
  String firstName = "";
  String lastName = "";
  String phoneNumber = "";
  String email = "";
    
  char splitString [1024];
  strcpy(splitString, infoString.c_str());
  
  char *token = strtok(splitString, "-");

  while(token != NULL){
    if(firstName == ""){
      firstName = token;
    }
    else if(lastName == ""){
      lastName = token;
    }
    else if(phoneNumber == ""){
      phoneNumber = token;
    }
    else if(email == ""){
      email = token;
    }
    //printf("%s\n", token);
    token = strtok(NULL, "-"); 
  }
      if(firstName == "placeID"){
       SerialBT.print("ChIJK3fd2XoxWUgRBB22NLqO2Ss");
    }
    
      Serial.println("First name is " + firstName);
      Serial.println("Last name is " + lastName);
      Serial.println("Phone Number is " + phoneNumber);
      Serial.println("Email is " + email);

      // TelnetStream setup on PuTTY - 192.168.0.137
      TelnetStream.println("First name is " + firstName);
      TelnetStream.println("Last name is " + lastName);
      TelnetStream.println("Phone Number is " + phoneNumber);
      TelnetStream.println("Email is " + email);

      sendJSON(firstName, lastName, phoneNumber, email);
}

void sendJSON(String firstName, String lastName, String phoneNumber, String email){
  if((WiFi.status() == WL_CONNECTED)){
    HTTPClient client;

    String InfoConcat = firstName + "/" + lastName + "/" + phoneNumber + "/" + email;
    
    client.begin("http://192.168.0.80:3000/api/contact/");
    client.addHeader("Content-Type", "application/json");
    
    // Alocate memory for the document
    const size_t CAPACITY = JSON_OBJECT_SIZE(8);
    StaticJsonDocument<CAPACITY> doc;

    JsonObject object = doc.to<JsonObject>();
    object["first_name"] = firstName;
    object["last_name"] = lastName;
    object["phone"] = phoneNumber;
    object["email"] = email;
    
    serializeJson(doc, jsonOutput);
    Serial.println(String(jsonOutput));    
    TelnetStream.println(String(jsonOutput));
    
    int httpCode = client.POST(String(jsonOutput));

    if(httpCode > 0){
      String payload = client.getString();
      Serial.println("\nStatuscode: " + String(httpCode));
      TelnetStream.println("\nStatuscode: " + String(httpCode));
      Serial.println(payload);

      client.end();
      
    }
    else{
      Serial.println("Error on HTTP request");
      TelnetStream.println("Error on HTTP request");
    }
  }
  else{
    Serial.println("Connection Lost");
    TelnetStream.println("Connection Lost");
  }
  delay(10000);  
    Serial.println("");
    TelnetStream.println("");
}
