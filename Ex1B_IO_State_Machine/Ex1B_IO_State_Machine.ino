


//////
/*
Button
Carlos Castellanos | 2014 | ccastellanos.com

Press and release to turn an LED on, then press and release again to turn off

Note: this example works best with a momentary pushbutton or similarly biased switch


Schematic, see:
https://github.com/carloscastellanos/teaching/blob/master/Arduino/Basics/Digital/Button_schem.png

Suggestions:
- Can you make the LED go off after a certain amount of time has passed? Hint: while
  using 'delay' will work, you can also look into the 'millis' function...
- add an additional led and/or button na d increase the complexity of behaviors  
*/

// constants won't change. They're used here to set pin numbers (faster/saves memory):
const int buttonPin = 2;      // pins for button and LED
const int ledPinStart = 13;
const int ledPinEnd = 7;

// store button's status - initialize to OFF (this variable will change, so it's not a const)
int buttonState = 0;
int prevButtonState = 0;

unsigned long timeToResetStart = 1000;

int size;
int currentLED = 0; 
unsigned long lastReset;

void setup() {
  pinMode(buttonPin, INPUT);    // set button to input
  //pinMode(ledPinA, OUTPUT);      // LED to output
  //pinMode(ledPinB, OUTPUT);      // LED to output

  size = ledPinStart - ledPinEnd + 1;
  for(int i = 0; i <= size; i++)
  {
    pinMode(ledPinStart - i, OUTPUT);
    //digitalWrite(ledPinStart - i, true);   // toggle the LED
  }
  lastReset = millis();
  //digitalWrite(10, true);
  //digitalWrite(11, true);
  //SetLEDs();
  Serial.begin(9600);
}

void loop() {
  
  // read the state of the button into our variable
  buttonState = digitalRead(buttonPin);
  //unsigned long delta = milis
  Serial.write("Test");

  if(millis() - lastReset > (timeToResetStart / (1 + currentLED)))
  {
    if(currentLED > 0)
    {
      digitalWrite(ledPinStart - currentLED, false);   // toggle the LED
      currentLED--;
      lastReset = millis();
      //SetLEDs();
    }
  }
  
  // test that state
  if (buttonState == HIGH) // if button is pressed...
  {      

    if(prevButtonState == LOW) // if it was previously not pressed
    {
      SetLEDs();
      currentLED++;
      //lastReset = millis();

      
    }
  }

  prevButtonState = buttonState; // save the previous button state

}

void SetLEDs()
{
  //digitalWrite(ledPinStart - currentLED + 1, true);   // toggle the LED
  digitalWrite(ledPinStart - currentLED, true);   // toggle the LED
}