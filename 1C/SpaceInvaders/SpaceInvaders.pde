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

Serial myPort;              // The serial port

float fgcolor = 0;          // Fill color defaults to black
Vector2 playerPos; 

float spacing = 30; // Spacing from screen edge 
int screenSizeX = 800;
int screenSizeY = 600;

Vector2 enemySpawnRange;
Vector2 enemySpawnOrigin;

int enemySpawnRate = 5;
float timer = 10000; // Every 10 seconds spawn 
boolean hasSpawned = false;

List<Enemy> enemies; 


boolean contact = false;    // Whether you've heard from the microcontroller
 
void setup() {
  size(800, 600);
  
  // List all the available serial ports
  println(Serial.list());
  
  String portName = Serial.list()[0];
  myPort = new Serial(this, portName, 9600);
  playerPos = new Vector2(0,0);
  
  enemies = new ArrayList();
  enemySpawnRange = new Vector2(100, 100);
  enemySpawnOrigin = new Vector2(400, 500);
  
  // don't generate a serialEvent() until you get an ASCII newline character
  myPort.bufferUntil('\n');
}

void draw() {
  background(#2b9468); // green background
  fill(fgcolor);
  
  // Draw the shape
  ellipse(playerPos.x, playerPos.y, 40, 40);
  
  RenderEnemies();
}

void RenderEnemies()
{
  for(int i = 0; i < enemies.size(); i++)
  {
     ellipse(enemies.get(i).position.x, enemies.get(i).position.y, 40, 40);
  }
}


void serialEvent(Serial myPort) 
{
  SerialLogic(myPort);
  
  EnemyLogic();
  EnemySpawner();
}









void SerialLogic(Serial myPort)
{
  // read the serial buffer:
  String myString = myPort.readStringUntil('\n');
  if (myString != null) {
    myString = trim(myString); // remove whitespace chars (e.g. '\n')
    
    // wait & listen until you hear from the microncontroller
    if(contact==false) {
      if(myString.equals("0,0,0")) {
        myPort.clear(); // clear the serial buffer
        contact = true;
        myPort.write(65); // send back a byte (doesn't matter what) to ask for more data
      }
    } else {  // if you have heard from the microcontroller, proceed
      // split the string at the commas
      // and convert the sections into integers
      int sensors[] = int(split(myString, ','));
      // now print out those three integers using a for() loop, like so
      for(int i=0; i<sensors.length; i++) {
        print("Sensor " + i + ": " + sensors[i] + "\t");
      }
      // add a linefeed at the end
      println();
      
      // assign the sensor values to xpos & ypos
      if (sensors.length > 1) {
        playerPos.x = lerp(spacing, screenSizeX - spacing, InverseLerp(0, 1023,  sensors[0]));
        playerPos.y = (sensors[1] / 10) + spacing;
        // the button will send 0 or 1.
        // this converts them to 0 or 255 (black or white)
        fgcolor = sensors[2] * 255;
      }
    }
    // when you've parsed the data you have, ask for more
    myPort.write(65);
  }
}






// Moves all enemies towards player 
void EnemyLogic()
{
   for(int i = 0; i < enemies.size(); i++)
   {
      Vector2 dir = playerPos.minus(enemies.get(i).position);
      dir.normalize();
      enemies.get(i).position = enemies.get(i).position.add(dir.Scale(1.0f));
   }
}

// Continously spawns enemies in a burst over each timer amount 
void EnemySpawner()
{
  // Met timer and makes sure don't duplicate 
  // spawning 
  if(millis() % timer <= 100 && (hasSpawned == false))
  {
     for(int i = 0; i < enemySpawnRate; i++)
     {
       // Create enemy 
       SpawnEnemy();
     }
     
     hasSpawned = true;
  }
  else if (hasSpawned == true)
  {
    // Reset timer once past threshold 
    if(millis() % timer <= 100)
    {
      hasSpawned = false;
    }
  }
}



// Creates and enemy and addds it to the gameworld 
void SpawnEnemy()
{
  enemies.add(new Enemy(new Vector2(0,0)));
}


// Holds an entity position 
public class Enemy
{
   public Vector2 position;
   
   Enemy(Vector2 startPos)
   {
      position = startPos;
   }
}

public class Vector2
{
  float x;
  float y;
  
  Vector2(float _x, float _y)
  {
     x = _x;
     y = _y;
  }
  
  Vector2 add(Vector2 other)
  {
    return new Vector2(x + other.x, y + other.y);
  }
  
  Vector2 minus(Vector2 other)
  {
    return new Vector2(x - other.x, y - other.y);
  }
  
  Vector2 Scale(float scale)
  {
    return new Vector2(x * scale, y * scale);
  }
  
  void normalize()
  {
    float hyp = sqrt(x * x + y * y);
    x /= hyp;
    y /= hyp;  //<>//
  }
}

float InverseLerp(float a, float b, float v)
{
   return (v - a) / (b - a); 
}
