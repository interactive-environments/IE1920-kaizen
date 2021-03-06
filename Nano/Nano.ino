#include <WiFiNINA.h>
#include <MQTT.h>
#define PIN1     5
#define PIN2     6
//wifi settings
const char ssid[] = "Science-Centre-EVENT";
const char pass[] = "ScienceCentre";

//mqtt settings
const char mqtt_clientID[] = "COCONE";
const char mqtt_username[] = "electro-forest";
const char mqtt_password[] = "fe8708c4cd16348a";
WiFiClient net;
MQTTClient client;
unsigned long lastMillis = 0;


int toSend1 = 1;
int toSend2 = 1;

void connect() {
  Serial.print("checking wifi...");
  while (WiFi.status() != WL_CONNECTED) {
    Serial.println(WiFi.status());
    delay(1000);
  }

  Serial.print("\nconnecting...");
  while (!client.connect(mqtt_clientID, mqtt_username, mqtt_password)) {+
    Serial.print("x");
    delay(1000);
  }

  Serial.println("\nconnected!");

  client.subscribe("/minorinteractive/studio/KEIZEN");
}

void messageReceived(String &topic, String &payload) {
//  Serial.println("incoming: " + topic + " - " + payload);
  toSend1 = (payload).toInt()%2;
  toSend2 = (payload).toInt()-toSend1;
}


void setup() {
  Serial.begin(9600);
  Serial.println("WiFi.begin");
  WiFi.begin(ssid, pass);
  pinMode(PIN1, OUTPUT);
  pinMode(PIN2, OUTPUT);
  // Note: Local domain names (e.g. "Computer.local" on OSX) are not supported by Arduino.
  // You need to set the IP address directly.
  //
  // MQTT brokers usually use port 8883 for secure connections.
  client.begin("broker.shiftr.io", net);
  client.onMessage(messageReceived);

  connect();

}

void loop() {
  client.loop();
  delay(10);  // <- fixes some issues with WiFi stability

  if (!client.connected()) {
    connect();
  }
  
  // publish a message roughly every second.
  if (millis() - lastMillis > 1000) {
    lastMillis = millis();
    Serial.print(toSend1);
    Serial.println(toSend2);
    digitalWrite(PIN1, toSend1);
    digitalWrite(PIN2, toSend2);
//    if (toSend == 1) toSend = 0; else toSend = 1;
//    if (toSend == 1){
//    client.publish("/minorinteractive/studio/KEIZEN", "0");
//    } else {
//    client.publish("/minorinteractive/studio/KEIZEN", "1");
//    }
  }
}
