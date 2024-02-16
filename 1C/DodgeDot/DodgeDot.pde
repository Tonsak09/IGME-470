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


/*
  Latest notes is that added collider and is making sure
  that they work. Also update both the entity and its 
  collider position. 
  
  Also need to make sure that the rate that the program
  moves enemies is not frame dependent 
  
  
  Update to the enemy movement to take in a custom
  delta time. This is done with millis though so
  it could be janky.
  
  Moved enemy logic to draw function as well instead
  of serial update. 
*/

import processing.serial.*; // import the Processing serial library
import java.util.*;
import java.util.Random;

Serial myPort;              // The serial port
Random random;

float fgcolor = 0;          // Fill color defaults to black
Vector2 playerPos; 
CircleCollider playerCollider;
float playerRadius = 15.0f;
float playerMoveSpeed = 0.5f;


float spacing = 30; // Spacing from screen edge 
int screenSizeX = 800;
int screenSizeY = 600;

Vector2 enemySpawnRange;
Vector2 enemySpawnOrigin;

int enemySpawnRate = 3;
float timer = 2000; // Every 10 seconds spawn 
boolean hasSpawned = false;

List<Enemy> enemies; 
float enemySpeed = 0.1f;
float enemyRadius = 15.0f;

// Time 
float delta;
float lastTime;

float currentTime;
int timeDisplay;
float timeRecord; 


boolean contact = false;    // Whether you've heard from the microcontroller
 
void setup() {
  size(800, 600);
  
  // List all the available serial ports
  println(Serial.list());
  
  String portName = Serial.list()[0];
  myPort = new Serial(this, portName, 9600);
  
  random = new Random();
  
  playerPos = new Vector2(0,0);
  playerCollider = new CircleCollider(playerRadius, playerPos);
  
  enemies = new ArrayList();
  enemySpawnRange = new Vector2(1000, 200);
  enemySpawnOrigin = new Vector2(400, 300);
  
  // don't generate a serialEvent() until you get an ASCII newline character
  myPort.bufferUntil('\n');
}

void draw() {
  
  UpdateTime();
  
  background(#2b9468); // green background
  fill(fgcolor);
  
  // Draw Player 
  ellipse(playerPos.x, playerPos.y, 40, 40);
  
  RenderEnemies();
  DisplayScore();
  
  EnemyLogic();
  EnemySpawner();
}

void serialEvent(Serial myPort) 
{
  SerialLogic(myPort);
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
  timeDisplay = (int)currentTime;
  textSize(45);
  text(timeDisplay / 1000, 20, 50); 
  fill(0, 408, 612);
  text((int)timeRecord / 1000, 20, 90);

}



void RenderEnemies()
{
  for(int i = 0; i < enemies.size(); i++)
  {
     ellipse(enemies.get(i).position.x, enemies.get(i).position.y, 40, 40);
  }
}


// Moves all enemies towards player 
void EnemyLogic()
{
   for(int i = 0; i < enemies.size(); i++)
   {
      Vector2 dir = playerPos.minus(enemies.get(i).position);
      dir.normalize();
      
      Vector2 displacement = dir.Scale(delta * enemySpeed);
      enemies.get(i).SetPosition(enemies.get(i).position.add(displacement));
      
      if(enemies.get(i).IsColliding(playerCollider))
      {
        // Reset game 
        //println("Is Colliding");
        ResetGame();
        break;
      }
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
    if(millis() % timer >= (timer / 2.0f))
    {
      hasSpawned = false;
    }
  }
}



// Creates and enemy and addds it to the gameworld 
void SpawnEnemy()
{
  Vector2 min = enemySpawnOrigin.minus(enemySpawnRange.Scale(0.5f));
  Vector2 max = enemySpawnOrigin.add(enemySpawnRange.Scale(0.5f));
  
  Vector2 pos = new Vector2(
    RandWithinRange(min.x, max.x), 
    RandWithinRange(min.y, max.y));
  
  enemies.add(new Enemy(pos, enemyRadius));
}

void ResetGame()
{
  if(currentTime > timeRecord)
  {
    timeRecord = currentTime;
  }
  
  currentTime = 0;
  enemies.clear();
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
        
        if(sensors[1] > 100)
        {
          playerPos.y += playerMoveSpeed * delta;
        }
        else
        {
          playerPos.y -= playerMoveSpeed * delta;
        }
        
        // Clamp player position 
        playerPos.y = Math.max(spacing, Math.min(screenSizeY - spacing, playerPos.y));
        
        
        //playerPos.y = (sensors[1] / 10) + spacing;
        // the button will send 0 or 1.
        // this converts them to 0 or 255 (black or white)
        fgcolor = sensors[2] * 255;
      }
    }
    // when you've parsed the data you have, ask for more
    myPort.write(65);
  }
}







// Holds an entity position 
public class Enemy
{
   private Vector2 position;
   private CircleCollider collider;
   
   Enemy(Vector2 startPos, float radius)
   {
      position = startPos;
      collider = new CircleCollider(radius, startPos);
   }
   
   void SetPosition(Vector2 _position)
   {
     position = _position;
     collider.SetPosition(_position);
   }
   
   boolean IsColliding(CircleCollider other)
   {
     return collider.isColliding(other);
   }
   
}

public class CircleCollider
{
  float radius;
  Vector2 position;
  
  CircleCollider(float _radius, Vector2 _position)
  {
    radius = _radius;
    position = _position;
  }
  
  void SetPosition(Vector2 _position)
  {
    position = _position;
  }
  
  boolean isColliding(CircleCollider other)
  {
   Vector2 dis = position.minus(other.position);
   return dis.GetMag() < (radius + other.radius);
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
  
  float GetMag()
  {
   return  sqrt(x * x + y * y);
  }
  
  void normalize()
  {
    float hyp = GetMag();
    x /= hyp;
    y /= hyp;  //<>//
  }
}

float InverseLerp(float a, float b, float v)
{
   return (v - a) / (b - a); 
}

float RandWithinRange(float min, float max)
{
  return random.nextFloat(max - min + 1) + min;
}
