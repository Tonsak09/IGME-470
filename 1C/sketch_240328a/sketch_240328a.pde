/*
 * AnalogSensorsButton_Handshaking
 *
 * Carlos Castellanos
 * August 5, 2020
 *
 * Example of serial communication between Processing & Arduino using the
 * "call-and-response" (handshaking) method
 * Arduino sends the data for three sensors as ASCII and Processing
 * uses that data not to control the position and color of a shape on the screen.
 * 
 *
 */


import processing.serial.*; // import the Processing serial library
import java.util.*;
import processing.sound.*;

Pulse pulse;

Serial myPort;              // The serial port

float fgcolor = 0;          // Fill color defaults to black

int bgR;
int bgG;

float spacing = 30; // Spacing from screen edge 
int screenSizeX = 800;
int screenSizeY = 600;

boolean contact = false;    // Whether you've heard from the microcontroller
 
void setup() {
  size(800, 600);
  
  // List all the available serial ports
  println(Serial.list());
  
  String portName = Serial.list()[0];
  myPort = new Serial(this, portName, 9600);
  
  // don't generate a serialEvent() until you get an ASCII newline character
  myPort.bufferUntil('\n');
  
  // Create and start the sine oscillator.
  pulse = new Pulse(this);
    
  //Start the Pulse Oscillator. 
  pulse.play();
}

void draw() {
  background(bgR, bgG, 100); // green background
  fill(fgcolor);
  
  // Draw the shape
  ellipse(bgR / 10, bgG / 10, 40, 40);
  pulse.amp(bgR);
  pulse.freq(bgG);
}




void serialEvent(Serial myPort) 
{
  SerialLogic(myPort);
  
}









void SerialLogic(Serial myPort)
{
  // read the serial buffer:
  String myString = myPort.readStringUntil('\n');
  if (myString != null) {
    myString = trim(myString); // remove whitespace chars (e.g. '\n')
    
    
    //print(myString);
    //print("\n");
    
    
    int sensors[] = int(split(myString, ','));
      // now print out those three integers using a for() loop, like so
      for(int i=0; i<sensors.length; i++) 
      {
        print("Sensor " + i + ": " + sensors[i] + "\t");
        
        switch(i)
        {
          case 0:
          bgR = sensors[i] * 100;
          case 1:
          bgG = sensors[i] * 100;
        }
      }
      
      //float rate = float(sensors[0]) / float(sensors[1]);
      //bgR = sensors[0] * 100;
     // bgG = sensors[1] * 100; //float(sensors[1]);
      //print("Sensor " + 0 + ": " + sensors[0] + "\t");
      
      // We know thatt we are getting two values 
      //print("Value " + 0 + ": " + sensors[0] / sensors[1] + "\t");
      //print("Value " + 1 + ": " + sensors[1] / sensors[1] + "\t");
      print("\n");
    
    
    //// wait & listen until you hear from the microncontroller
    //if(contact==false) {
    //  if(myString.equals("0,0,0")) {
    //    myPort.clear(); // clear the serial buffer
    //    contact = true;
    //    myPort.write(65); // send back a byte (doesn't matter what) to ask for more data
    //  }
    //} else {  // if you have heard from the microcontroller, proceed
    //  // split the string at the commas
    //  // and convert the sections into integers
    //  int sensors[] = int(split(myString, ','));
    //  // now print out those three integers using a for() loop, like so
    //  for(int i=0; i<sensors.length; i++) {
    //    print("Sensor " + i + ": " + sensors[i] + "\t");
    //  }
    //  // add a linefeed at the end
    //  println();
      
    //  // assign the sensor values to xpos & ypos
    //  if (sensors.length > 1) {
    //    // the button will send 0 or 1.
    //    // this converts them to 0 or 255 (black or white)
    //    fgcolor = sensors[2] * 255;
    //  }
    //}
    // when you've parsed the data you have, ask for more
    myPort.write(65);
  }
}
