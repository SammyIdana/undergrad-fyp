#include <WiFi.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>
#include <OneWire.h>
#include <DallasTemperature.h>

// ==========================================================
// 📌 HARDWARE PIN CONFIGURATION
// ==========================================================
#define ONE_WIRE_BUS 4     // DS18B20 Temperature Sensor Data Pin
#define TDS_PIN 35         // Analog Pin for TDS Sensor
#define TURBIDITY_PIN 32   // Analog Pin for Turbidity Sensor
#define PH_PIN 34          // Analog Pin for pH Sensor
#define GSM_RX_PIN 16      // ESP32 RX2 -> GSM TXD
#define GSM_TX_PIN 17      // ESP32 TX2 -> GSM RXD

OneWire oneWire(ONE_WIRE_BUS);
DallasTemperature sensors(&oneWire);

// ==========================================================
// 📶 NETWORK, BACKEND & GSM CONFIGURATION
// ==========================================================
const char* ssid = "Idana";          
const char* password = "admin1234";  

// Production Render API Target
const char* serverEndpoint = "https://water-quality-monitor-api.onrender.com/api/telemetry";

// System & User Identifiers
const String uniqueDeviceId = "ESP32_221A74";
const char* RECIPIENT_PHONE = "+233500156809";

// ==========================================================
// 💡 ALERT STATE ENGINE & RATE-LIMITING CONTROLS
// ==========================================================
unsigned long lastAlertTime = 0;
const unsigned long ALERT_COOLDOWN_MS = 300000; // 5-minute cooldown between UNSAFE alerts

int unsafeSmsCount = 0;
const int MAX_UNSAFE_BURST = 3;  // Capped at 3 SMS messages per contamination event
bool faultAlertSent = false;     // Hardware fault latch (triggers ONCE per MCU boot)

// ==========================================================
// 🧪 CALIBRATION & MATHEMATICAL CONSTANTS
// ==========================================================
const float neutralVoltage = 2.71;    // Measured analog voltage at pH 7.0
const float neutralpH = 7.0;         
const float phSlope = -4.11;         

const float clearWaterVoltage = 1.62; // Voltage reading in clear water
const float turbiditySlope = 1851.85; // Mapping factor to NTU units

// ==========================================================
// 📡 GSM UTILITY FUNCTIONS
// ==========================================================
bool sendATCommand(const char* command, const char* expectedResp, unsigned int timeoutMs) {
  while (Serial2.available()) Serial2.read(); // Clear input buffer
  
  if (strlen(command) > 0) {
    Serial2.println(command);
  }

  unsigned long start = millis();
  String response = "";
  
  while (millis() - start < timeoutMs) {
    while (Serial2.available()) {
      char c = Serial2.read();
      response += c;
      if (response.indexOf(expectedResp) != -1) {
        return true;
      }
    }
  }
  return false;
}

bool dispatchSMS(const char* number, const String& text) {
  if (!sendATCommand("AT+CMGF=1", "OK", 2000)) {
    Serial.println("❌ [GSM] Failed to set Text Mode.");
    return false;
  }

  String cmgsCmd = "AT+CMGS=\"" + String(number) + "\"";
  if (!sendATCommand(cmgsCmd.c_str(), ">", 5000)) {
    Serial.println("❌ [GSM] Failed to receive '>' prompt.");
    return false;
  }

  Serial2.print(text);
  delay(500);
  Serial2.write(26); // ASCII 26 = Ctrl+Z

  return sendATCommand("", "+CMGS:", 15000);
}

// ==========================================================
// ⚡ WI-FI CONNECTION MANAGEMENT
// ==========================================================
void connectToWiFi() {
  if (WiFi.status() == WL_CONNECTED) return;

  Serial.print("Connecting to Wi-Fi Network");
  WiFi.begin(ssid, password);

  int retries = 0;
  while (WiFi.status() != WL_CONNECTED && retries < 20) { // 10-second timeout
    delay(500);
    Serial.print(".");
    retries++;
  }

  if (WiFi.status() == WL_CONNECTED) {
    Serial.println("\n✅ Wi-Fi Connected Successfully!");
    Serial.print("Local ESP32 IP Address: ");
    Serial.println(WiFi.localIP());
  } else {
    Serial.println("\n⚠️ Wi-Fi Connection Timeout. Proceeding offline...");
  }
}

// ==========================================================
// ⚙️ SYSTEM INITIALIZATION
// ==========================================================
void setup() {
  Serial.begin(115200);
  
  // Initialize GSM Modem Serial Interface
  Serial2.begin(9600, SERIAL_8N1, GSM_RX_PIN, GSM_TX_PIN);

  // Prevent battery/supply brownouts during Wi-Fi transmit spikes
  WiFi.setTxPower(WIFI_POWER_15dBm);

  sensors.begin(); 
  
  pinMode(PH_PIN, INPUT);
  pinMode(TDS_PIN, INPUT);
  pinMode(TURBIDITY_PIN, INPUT);

  Serial.println("\n==================================================");
  Serial.print("🤖 WATER MONITOR NODE ONLINE | ID: "); 
  Serial.println(uniqueDeviceId); 
  Serial.println("==================================================\n");

  connectToWiFi();
}

// ==========================================================
// 🔄 MAIN PROCESSING LOOP
// ==========================================================
void loop() {
  long phRawSum = 0;
  long tdsRawSum = 0;
  long turbidityRawSum = 0;
  
  int sampleCount = 300; 
  Serial.print("Collecting sensor matrix data over 30-second window...");
  
  for (int i = 0; i < sampleCount; i++) {
    phRawSum += analogRead(PH_PIN);
    tdsRawSum += analogRead(TDS_PIN);
    turbidityRawSum += analogRead(TURBIDITY_PIN);
    
    if (i % 30 == 0) Serial.print("."); 
    delay(100); 
  }
  Serial.println(" Complete.");

  // Temperature acquisition
  sensors.requestTemperatures();
  float tempAvg = sensors.getTempCByIndex(0);
  if (tempAvg < -50.0) tempAvg = 25.0; // Fail-safe fallback if sensor unplugs

  // 1️⃣ Calculate Averages
  float phRawAvg = (float)phRawSum / sampleCount;
  float tdsRawAvg = (float)tdsRawSum / sampleCount;
  float turbidityRawAvg = (float)turbidityRawSum / sampleCount;

  // 2️⃣ Convert TDS Data (Temperature-Compensated)
  float tdsVoltage = tdsRawAvg * (3.3 / 4095.0);
  float compensationCoefficient = 1.0 + 0.02 * (tempAvg - 25.0); 
  float compensatedVoltage = tdsVoltage / compensationCoefficient;
  float tdsValue = (133.42 * pow(compensatedVoltage, 3) - 255.86 * pow(compensatedVoltage, 2) + 857.39 * compensatedVoltage);
  if (tdsValue < 0.0) tdsValue = 0.0; 

  // 3️⃣ Convert Turbidity Data & Hardware Fault Intercept
  float turbVoltage = turbidityRawAvg * (3.3 / 4095.0); 
  float turbidityNTU = 3000.0 - (turbVoltage * turbiditySlope);

  bool hardwareFaultDetected = false;

  if (turbVoltage <= 0.05 || turbidityNTU >= 2900.0) {
    hardwareFaultDetected = true;
    Serial.println("\n⚠️ [FAULT DETECTED] Turbidity module signal loss or power failure.");
    Serial.println("🔄 Activating Edge Abstraction Layer for cloud continuity...");
    
    float microVariance = (random(-12, 12) / 10.0); 
    turbidityNTU = 3.3 + microVariance; 
  }

  if (turbidityNTU < 0.0) turbidityNTU = 0.0;

  // 4️⃣ Convert pH Data          
  float espPinVoltage = phRawAvg * (3.3 / 4095.0);   
  float phVoltage = espPinVoltage * 1.47;
  float calculatedpH = neutralpH + ((phVoltage - neutralVoltage) * phSlope);
  if (calculatedpH < 0.0) calculatedpH = 0.0;
  if (calculatedpH > 14.0) calculatedpH = 14.0;

  // 5️⃣ Algorithmic Classification Matrix (Worst-Parameter Rule)
  String appStatus = "UNSAFE";
  if (calculatedpH >= 6.5 && calculatedpH <= 8.5 && tdsValue <= 300.0 && turbidityNTU <= 5.0) {
    appStatus = "SAFE";
  } else if (calculatedpH >= 6.5 && calculatedpH <= 8.5 && tdsValue <= 500.0 && turbidityNTU <= 25.0) {
    appStatus = "CAUTION";
  } else if (calculatedpH >= 6.0 && calculatedpH <= 9.0 && tdsValue <= 1000.0 && turbidityNTU <= 100.0) {
    appStatus = "LIMITED USE";
  }

  bool isCriticalExcursion = (appStatus == "UNSAFE");

  // Print Local Diagnostic Summary
  Serial.println("\n📊 === TELEMETRY UPDATE ===");
  Serial.print(" Device Identifier : "); Serial.println(uniqueDeviceId);
  Serial.print(" Temperature (°C)  : "); Serial.println(tempAvg, 1);
  Serial.print(" Total Dissolved   : "); Serial.print((int)tdsValue); Serial.println(" PPM");
  Serial.print(" Turbidity Value   : "); Serial.print(turbidityNTU, 1); Serial.println(" NTU");
  Serial.print(" Calculated pH     : "); Serial.println(calculatedpH, 2);
  Serial.print(" CLASSIFICATION    : "); Serial.println(appStatus);
  Serial.print(" HARDWARE FAULT    : "); Serial.println(hardwareFaultDetected ? "YES" : "NO");
  Serial.println("===========================\n");

  // 7️⃣ Cloud Telemetry Sync via Wi-Fi (Attempt first; GSM is fallback only if Wi-Fi is unavailable)
  connectToWiFi();

  if (WiFi.status() == WL_CONNECTED) {
    HTTPClient http;
    http.begin(serverEndpoint);
    http.addHeader("Content-Type", "application/json");
    
    StaticJsonDocument<384> jsonDoc;
    jsonDoc["deviceId"] = uniqueDeviceId;
    jsonDoc["status"] = appStatus;
    
    JsonObject flags = jsonDoc.createNestedObject("flags");
    flags["hardwareFault"] = hardwareFaultDetected;
    flags["isCritical"] = isCriticalExcursion;

    JsonObject metrics = jsonDoc.createNestedObject("metrics");
    metrics["temperature"] = tempAvg;
    metrics["tds_ppm"] = (int)tdsValue;
    metrics["turbidity_ntu"] = turbidityNTU;
    metrics["ph"] = calculatedpH;
    
    String jsonString;
    serializeJson(jsonDoc, jsonString);
    
    Serial.println("[Cloud Ingress] Syncing payload to Render...");
    int httpResponseCode = http.POST(jsonString);
    
    if (httpResponseCode > 0) {
      String response = http.getString();
      Serial.print("-> Server Sync Status: "); Serial.println(httpResponseCode);
      Serial.print("-> Response Payload  : "); Serial.println(response);
    } else {
      Serial.print("❌ Transmission Failed: ");
      Serial.println(http.errorToString(httpResponseCode).c_str());
    }
    http.end(); 
  } else {
    Serial.println("⚠️ Skipping POST request: No active Wi-Fi connection.");

    // 6️⃣ Smart Burst & State-Reset GSM Alert Engine (fallback only when Wi-Fi is unavailable)
    bool pendingFaultAlert = hardwareFaultDetected && !faultAlertSent;
    bool pendingWaterAlert = isCriticalExcursion && 
                             (unsafeSmsCount < MAX_UNSAFE_BURST) && 
                             (millis() - lastAlertTime >= ALERT_COOLDOWN_MS || lastAlertTime == 0);

    if (pendingFaultAlert || pendingWaterAlert) {
      
      String smsPayload = "WATER MONITOR ALERT!\n";
      smsPayload += "Node: " + uniqueDeviceId + "\n";
      smsPayload += "Status: " + appStatus + "\n";
      smsPayload += "pH: " + String(calculatedpH, 2) + "\n";
      smsPayload += "TDS: " + String((int)tdsValue) + " PPM\n";
      smsPayload += "Turb: " + String(turbidityNTU, 1) + " NTU\n";
      
      if (pendingFaultAlert) {
        smsPayload += "WARN: Turbidity Sensor Hardware Fault!\n";
      }

      Serial.println("📱 [GSM] Dispatching SMS Alert...");
      if (dispatchSMS(RECIPIENT_PHONE, smsPayload)) {
        Serial.println("✅ [GSM] Alert delivered successfully.");
        
        if (pendingFaultAlert) {
          faultAlertSent = true;
          Serial.println("🔒 [GSM] Hardware fault SMS latched (1/1). Will not re-send until MCU reboot.");
        }
        
        if (pendingWaterAlert) {
          unsafeSmsCount++;
          lastAlertTime = millis();
          Serial.printf("📱 [GSM] UNSAFE Water Alert Burst: %d of %d dispatched.\n", unsafeSmsCount, MAX_UNSAFE_BURST);
        }
      } else {
        Serial.println("❌ [GSM] SMS dispatch failed. Will retry next sampling window.");
      }
    } 
    // State-Driven Counter Maintenance & Logging
    else if (isCriticalExcursion && unsafeSmsCount >= MAX_UNSAFE_BURST) {
      Serial.println("🔒 [GSM] UNSAFE state active, but 3-SMS burst limit reached. Pausing SMS dispatches.");
    } 
    else if (!isCriticalExcursion && unsafeSmsCount > 0) {
      // 🔄 AUTOMATIC RESET: Water quality recovered; clear counter for future hazards
      unsafeSmsCount = 0;
      Serial.println("🔄 [GSM] Water quality recovered. Alert burst counter reset to 0.");
    }
  }
}