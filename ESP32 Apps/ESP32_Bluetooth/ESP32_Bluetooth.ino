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

AsyncWebServer server(80);

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
    Serial.println("String is " + infoString); 
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
      Serial.println("First name is " + firstName);
      Serial.println("Last name is " + lastName);
      Serial.println("Phone Number is " + phoneNumber);
      Serial.println("Email is " + email);

      // TelnetStream setup on PuTTY - 192.168.0.137
      TelnetStream.print("First name is " + firstName);
      TelnetStream.print("Last name is " + lastName);
      TelnetStream.print("Phone Number is " + phoneNumber);
      TelnetStream.print("Email is " + email);

      sendJSON(firstName, lastName, phoneNumber, email);
}

void sendJSON(String firstName, String lastName, String phoneNumber, String email){
  if((WiFi.status() == WL_CONNECTED)){
    HTTPClient client;


    Serial.println("String is " + firstName + lastName + phoneNumber + email);

    String InfoConcat = firstName + "/" + lastName + "/" + phoneNumber + "/" + email;
    Serial.println("json is " + InfoConcat);
    TelnetStream.print("json is " + InfoConcat);

    
    client.begin("http://192.168.0.80:3000/api/contact/");
    client.addHeader("Content-Type", "application/json");

    const size_t CAPACITY = JSON_OBJECT_SIZE(8);
    StaticJsonDocument<CAPACITY> doc;

    JsonObject object = doc.to<JsonObject>();
    object["first_name"] = firstName;
    object["last_name"] = lastName;
    object["phone"] = phoneNumber;
    object["email"] = email;
    
    serializeJson(doc, jsonOutput);
    Serial.println("");

    Serial.println(String(jsonOutput));
    
    int httpCode = client.POST(String(jsonOutput));

    if(httpCode > 0){
      String payload = client.getString();
      Serial.println("\nStatuscode: " + String(httpCode));
      Serial.println(payload);

      client.end();
      
    }
    else{
      Serial.println("Error on HTTP request");
      TelnetStream.print("Error on HTTP request");
    }
  }
  else{
    Serial.println("Connection Lost");
    TelnetStream.print("Connection Lost");
  }
  delay(10000);  
}
