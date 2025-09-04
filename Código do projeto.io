#include <WiFi.h>
#include <HTTPClient.h>
#include <DHT.h>

#define DHTPIN 15 
#define DHTTYPE DHT22 
DHT dht(DHTPIN, DHTTYPE);

#define POT_PIN 34 

// Credenciais
const char* ssid = "Wokwi-GUEST"; // Rede Wi-Fi
const char* password = ""; // Senha da rede Wi-Fi
const char* apiKey = "OTTZR7G8AB8GUR3R"; // Write API Key
const char* server = "http://api.thingspeak.com"; // Servidor ThingSpeak

void setup() {
  Serial.begin(9600);
  dht.begin();

  pinMode(POT_PIN, INPUT);

  // Inicialização e loop de verificação da rede Wi-Fi
  WiFi.begin(ssid, password);
  Serial.print("Conectando ao WiFi");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println(" conectado!");
}

void loop() {
  if (WiFi.status() == WL_CONNECTED) {
    // Leitura dos sensores
    float h = dht.readHumidity();
    float t = dht.readTemperature();
    int potValue = analogRead(POT_PIN); // Leitura do valor do Potenciômetro
    float speed = map(potValue, 0, 4095, 0, 100); 

    if (isnan(h) || isnan(t)) {
      Serial.println("Falha ao ler o sensor DHT11!");
      return;
    }

    // Envio de dados para o ThingSpeak
    HTTPClient http;
    String url = String(server) + "/update?api_key=" + apiKey + "&field1=" + String(t) +
                                 "&field2=" + String(h) + "&field3=" + String(speed);
    http.begin(url);

    int httpCode = http.GET();
    if (httpCode > 0) {
      String payload = http.getString(); // Resposta da requisição HTTP
      Serial.println("Dados enviados ao ThingSpeak.");
      Serial.print("Código HTTP: ");
      Serial.println(httpCode);
      Serial.println("Resposta: ");
      Serial.println(payload);
    } else {
      Serial.print("Erro ao enviar dados. Código HTTP: ");
      Serial.println(httpCode);
    }
    
    http.end();
  } else {
    Serial.println("WiFi não conectado. Tentando reconectar...");
  }
  
  delay(2500);
}
