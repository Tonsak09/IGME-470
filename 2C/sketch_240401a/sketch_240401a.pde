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


float spacing = 30; // Spacing from screen edge 
int screenSizeX = 800;
int screenSizeY = 600;

boolean contact = false;    // Whether you've heard from the microcontroller
boolean heldPress = false; 

enum GameState
{
  DAY,
  NIGHT
}
GameState state; 

int foodCounter = 0;
float foodTimerCounter = 10.0;
float sleepCounter = 0.0;

float delta;
float lastTime;

float currentTime;
 
void setup() {
  size(800, 600);
  
  // List all the available serial ports
  println(Serial.list());
  
  String portName = Serial.list()[0];
  myPort = new Serial(this, portName, 9600);
  
  // don't generate a serialEvent() until you get an ASCII newline character
  myPort.bufferUntil('\n');
  
  state = GameState.DAY;
}

void draw() {
  switch(state)
  {
    case DAY:
      background(#FFF3C7);
      break;
    case NIGHT:
      background(#496989);
      break;
  }
  
  fill(fgcolor);
  
  // Draw the creature
  //ellipse(bgR / 10, bgG / 10, 40, 40);

  fill(#453F78);
  rect(360, 360, 80, 100);
  fill(#FFC94A);
  triangle(400, 256.70, 350, 343.30, 450, 343.30);
  triangle(400, 400.70, 350, 350.30, 450, 350.30);
  switch(state)
  {
    case DAY:
      fill(#453F78);
      circle(430, 280, 30);
      circle(370, 280, 30);
      fill(#795458);
      circle(433, 280, 20);
      circle(373, 280, 20);
      break;
    case NIGHT:
      fill(#453F78);
      rect(415, 285, 30, 10);
      rect(365, 285, 30, 10);
      break;
  }
  
  UpdateTime();
  
  foodTimerCounter -= delta;
  if(foodTimerCounter <= 0.0)
  {
     foodCounter--;
     foodTimerCounter = 10000.0;
  }
  
  DisplayScore();
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
    
    
    int sensors[] = int(split(myString, ','));
      // now print out those three integers using a for() loop, like so
      for(int i=0; i<sensors.length; i++) 
      {
        print("Sensor " + i + ": " + sensors[i] + "\t");
        
        switch(i)
        {
          case 0: // Day or night 
          if(sensors[i] <= 100)
          {
            state = GameState.NIGHT;
            sleepCounter += delta; 
          }
          else
          {
           state = GameState.DAY;
           sleepCounter -= delta; 
          }
          
          break;
          case 1: // Button is pressed?
          if(state == GameState.DAY && sensors[i] > 100 && heldPress == false)
          {
            foodCounter++;
          }
          
          heldPress = sensors[i] > 100;

          //bgG = sensors[i] * 100;
        }
      }
      
      
      print("\n");
    
    
    // when you've parsed the data you have, ask for more
    myPort.write(65);
  }
}

// Updates the delta time 
void UpdateTime()
{
  delta = millis() - lastTime;
  lastTime = millis();
  
  currentTime += delta;
}

void DisplayScore()
{
  if(sleepCounter < 0)
  {
   sleepCounter = 0.0; 
  }
  
  if(foodCounter < 0)
  {
   foodCounter = 0; 
  }
  
  fill(fgcolor);
  rect(10, 10, 150, 100);
  
  int timeDisplay = (int)sleepCounter;
  textSize(45);
  fill(0, 408, 612);
  text(timeDisplay / 1000, 20, 50); 
  fill(0, 408, 612);
  text(foodCounter, 20, 90);

}
