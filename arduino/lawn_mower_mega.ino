/**
 * ============================================================
 *  Lawn Mower Robot — Arduino Mega Firmware
 *  Compatible with: HC-05 / HC-06 Bluetooth Module
 * ============================================================
 *  WIRING GUIDE:
 *  - HC-05/HC-06 TX  → Arduino Mega RX1 (pin 19)
 *  - HC-05/HC-06 RX  → Arduino Mega TX1 (pin 18) via 5V→3.3V divider
 *  - HC-05/HC-06 VCC → 5V, GND → GND
 *
 *  - Motor Driver (L298N or L293D):
 *    Left Motor:  IN1=30, IN2=31, EN=2 (PWM)
 *    Right Motor: IN3=32, IN4=33, EN=3 (PWM)
 *
 *  - Cutter/Blade Motor:
 *    Relay IN → pin 40 (HIGH = cutter ON)
 *    -- OR --
 *    ESC signal → pin 9 (PWM)
 *
 *  - Ultrasonic Sensor (HC-SR04):
 *    TRIG → pin 50
 *    ECHO → pin 51
 * ============================================================
 */

#include <Arduino.h>

// ─── PIN DEFINITIONS ──────────────────────────────────────────
// Motor driver
const int LEFT_IN1  = 30;
const int LEFT_IN2  = 31;
const int LEFT_EN   = 2;   // PWM
const int RIGHT_IN3 = 32;
const int RIGHT_IN4 = 33;
const int RIGHT_EN  = 3;   // PWM

// Cutter motor (relay or ESC relay pin)
const int CUTTER_PIN = 40;

// Ultrasonic HC-SR04
const int TRIG_PIN = 50;
const int ECHO_PIN = 51;

// ─── ADJUSTABLE SETTINGS ─────────────────────────────────────
// Bluetooth Serial: use Serial1 on Mega (pins 18/19)
#define BT_SERIAL Serial1
#define BT_BAUD   9600

// Motor speed (0–255). Adjust for your motor specs.
const int DRIVE_SPEED  = 200;
const int TURN_SPEED   = 180;

// Distance reporting interval (ms)
const unsigned long DIST_INTERVAL = 200;

// ─── COMMAND CHARACTERS (must match app defaults) ─────────────
// These can also be hard-coded here if you prefer not to change
// them in the app; just keep both sides in sync.
// F=Forward B=Backward L=Left R=Right S=Stop C=CutterOn X=CutterOff

// ─── GLOBALS ─────────────────────────────────────────────────
unsigned long lastDistRead = 0;

// ─── SETUP ───────────────────────────────────────────────────
void setup() {
  Serial.begin(115200);      // Debug monitor
  BT_SERIAL.begin(BT_BAUD);  // Bluetooth

  // Motor driver pins
  pinMode(LEFT_IN1,  OUTPUT);
  pinMode(LEFT_IN2,  OUTPUT);
  pinMode(LEFT_EN,   OUTPUT);
  pinMode(RIGHT_IN3, OUTPUT);
  pinMode(RIGHT_IN4, OUTPUT);
  pinMode(RIGHT_EN,  OUTPUT);

  // Cutter relay
  pinMode(CUTTER_PIN, OUTPUT);
  digitalWrite(CUTTER_PIN, LOW); // cutter OFF by default

  // Ultrasonic
  pinMode(TRIG_PIN, OUTPUT);
  pinMode(ECHO_PIN, INPUT);

  stopMotors(); // ensure stopped on startup
  Serial.println("Lawn Mower Ready. Waiting for BT commands...");
}

// ─── MAIN LOOP ────────────────────────────────────────────────
void loop() {
  // Handle incoming Bluetooth command
  if (BT_SERIAL.available()) {
    char cmd = (char)BT_SERIAL.read();
    processCommand(cmd);
    Serial.print("CMD: ");
    Serial.println(cmd);
  }

  // Periodically send distance data to app
  unsigned long now = millis();
  if (now - lastDistRead >= DIST_INTERVAL) {
    lastDistRead = now;
    float dist = readDistanceCm();
    // Send as "D:42.5\n" — parsed by the Flutter app
    BT_SERIAL.print("D:");
    BT_SERIAL.println(dist, 1);
  }
}

// ─── COMMAND PROCESSOR ───────────────────────────────────────
void processCommand(char cmd) {
  switch (cmd) {
    case 'F': moveForward();  break;
    case 'B': moveBackward(); break;
    case 'L': turnLeft();     break;
    case 'R': turnRight();    break;
    case 'S': stopMotors();   break;
    case 'C': cutterOn();     break;
    case 'X': cutterOff();    break;
    default:
      // Unknown command — safety stop
      stopMotors();
      break;
  }
}

// ─── MOTOR CONTROL FUNCTIONS ──────────────────────────────────
void moveForward() {
  analogWrite(LEFT_EN,  DRIVE_SPEED);
  analogWrite(RIGHT_EN, DRIVE_SPEED);
  digitalWrite(LEFT_IN1, HIGH);
  digitalWrite(LEFT_IN2, LOW);
  digitalWrite(RIGHT_IN3, HIGH);
  digitalWrite(RIGHT_IN4, LOW);
}

void moveBackward() {
  analogWrite(LEFT_EN,  DRIVE_SPEED);
  analogWrite(RIGHT_EN, DRIVE_SPEED);
  digitalWrite(LEFT_IN1, LOW);
  digitalWrite(LEFT_IN2, HIGH);
  digitalWrite(RIGHT_IN3, LOW);
  digitalWrite(RIGHT_IN4, HIGH);
}

void turnLeft() {
  analogWrite(LEFT_EN,  TURN_SPEED);
  analogWrite(RIGHT_EN, TURN_SPEED);
  // Left motor backward, Right motor forward
  digitalWrite(LEFT_IN1, LOW);
  digitalWrite(LEFT_IN2, HIGH);
  digitalWrite(RIGHT_IN3, HIGH);
  digitalWrite(RIGHT_IN4, LOW);
}

void turnRight() {
  analogWrite(LEFT_EN,  TURN_SPEED);
  analogWrite(RIGHT_EN, TURN_SPEED);
  // Left motor forward, Right motor backward
  digitalWrite(LEFT_IN1, HIGH);
  digitalWrite(LEFT_IN2, LOW);
  digitalWrite(RIGHT_IN3, LOW);
  digitalWrite(RIGHT_IN4, HIGH);
}

void stopMotors() {
  analogWrite(LEFT_EN,  0);
  analogWrite(RIGHT_EN, 0);
  digitalWrite(LEFT_IN1, LOW);
  digitalWrite(LEFT_IN2, LOW);
  digitalWrite(RIGHT_IN3, LOW);
  digitalWrite(RIGHT_IN4, LOW);
}

// ─── CUTTER MOTOR ────────────────────────────────────────────
void cutterOn() {
  digitalWrite(CUTTER_PIN, HIGH);
  Serial.println("Cutter ON");
}

void cutterOff() {
  digitalWrite(CUTTER_PIN, LOW);
  Serial.println("Cutter OFF");
}

// ─── ULTRASONIC DISTANCE ─────────────────────────────────────
float readDistanceCm() {
  // Send 10µs pulse
  digitalWrite(TRIG_PIN, LOW);
  delayMicroseconds(2);
  digitalWrite(TRIG_PIN, HIGH);
  delayMicroseconds(10);
  digitalWrite(TRIG_PIN, LOW);

  // Measure echo (timeout 30ms = ~5m max range)
  long duration = pulseIn(ECHO_PIN, HIGH, 30000UL);
  if (duration == 0) return 999.0; // timeout = no object detected

  // Speed of sound 343 m/s → 0.0343 cm/µs → divide by 2 for round trip
  return (duration * 0.0343f) / 2.0f;
}
