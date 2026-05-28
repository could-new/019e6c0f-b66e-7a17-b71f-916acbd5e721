# Arduino Motion Detector

This project consists of two parts:
1. **Flutter Dashboard**: A cross-platform app to monitor motion detection events in real-time.
2. **Arduino Program**: The C++ code to run on your Arduino board using a PIR motion sensor.

## 1. Arduino Code

Upload this code to your Arduino. It uses a standard PIR sensor connected to a digital pin.

```cpp
// Arduino Motion Detection Program
// Connect PIR sensor OUT pin to Arduino digital pin 2

const int PIR_PIN = 2;       // Digital pin connected to the PIR sensor
const int LED_PIN = 13;      // Onboard LED pin
int pirState = LOW;          // Start assuming no motion
int val = 0;                 // Variable for reading the pin status

void setup() {
  pinMode(LED_PIN, OUTPUT);      // Declare LED as output
  pinMode(PIR_PIN, INPUT);       // Declare sensor as input
  
  Serial.begin(9600);            // Initialize serial communication
  Serial.println("Motion sensor calibrating...");
  delay(5000);                   // Give the sensor time to calibrate
  Serial.println("System active.");
}

void loop() {
  val = digitalRead(PIR_PIN);    // Read sensor value
  
  if (val == HIGH) {             // Check if the sensor is HIGH
    digitalWrite(LED_PIN, HIGH); // Turn LED ON
    if (pirState == LOW) {
      // Motion just started
      Serial.println("MOTION_DETECTED");
      pirState = HIGH;
    }
  } else {
    digitalWrite(LED_PIN, LOW);  // Turn LED OFF
    if (pirState == HIGH) {
      // Motion just stopped
      Serial.println("MOTION_CLEARED");
      pirState = LOW;
    }
  }
  
  delay(100); // Small delay to avoid bouncing
}
```

### Wiring Guide
- **VCC** on PIR sensor -> **5V** on Arduino
- **GND** on PIR sensor -> **GND** on Arduino
- **OUT** on PIR sensor -> **Digital Pin 2** on Arduino

## 2. Flutter App (Dashboard)

The Flutter app currently provides a simulated connection to visualize how the dashboard works. In a production environment, you would connect the Flutter app to the Arduino via Bluetooth (e.g., using `flutter_blue_plus`) or via a network if using an ESP8266/ESP32.

### Running the App
1. Ensure you have Flutter installed.
2. Run `flutter pub get`
3. Run `flutter run`

## CouldAI

This app was generated with [CouldAI](https://could.ai), an AI app builder for cross-platform apps that turns prompts into real native iOS, Android, Web, and Desktop apps with autonomous AI agents that architect, build, test, deploy, and iterate production-ready applications.
