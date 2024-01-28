/*
  AnalogReadSerial

  Reads an analog input on pin 0, prints the result to the Serial Monitor.
  Graphical representation is available using Serial Plotter (Tools > Serial Plotter menu).
  Attach the center pin of a potentiometer to pin A0, and the outside pins to +5V and ground.

  This example code is in the public domain.

  https://www.arduino.cc/en/Tutorial/BuiltInExamples/AnalogReadSerial
*/

// the setup routine runs once when you press reset:
void setup() {
  // initialize serial communication at 9600 bits per second:
  Serial.begin(9600);
}

// the loop routine runs over and over again forever:
void loop() {
  // // read the input on analog pin 0:
  // int sensorValue = map( constrain(analogRead(A0), 4, 130), 4, 130, 0, 100);
  // sensorValue = constrain(sensorValue, 0, 100);
  // // print out the value you read:
  // Serial.println(sensorValue);
  // delay(1);  // delay in between reads for stabilitySerial.print("sensorPinA0: ");
  
  //String data = "sensorPinA0: " + analogRead(A0);
  Serial.print("sensorPinA0: ");
  Serial.print(analogRead(A0));
  Serial.print("  sensorPinA3: ");
  Serial.print(analogRead(A3));
  Serial.print("  sensorPinA5: ");
  Serial.println(analogRead(A5));
}
