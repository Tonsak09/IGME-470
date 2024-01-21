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
const int ledPinA = 4;
const int ledPinB = 3;

// store button's status - initialize to OFF (this variable will change, so it's not a const)
int buttonState = 0;
int prevButtonState = 0;
bool alt = false; // Alternates which led 

void setup() {
  pinMode(buttonPin, INPUT);    // set button to input
  pinMode(ledPinA, OUTPUT);      // LED to output
  pinMode(ledPinB, OUTPUT);      // LED to output

  //SetLEDs();
}

void loop() {
  
  // read the state of the button into our variable
  buttonState = digitalRead(buttonPin);
        Serial.print("test");
  // test that state
  if (buttonState == HIGH) // if button is pressed...
  {      
    if(prevButtonState == LOW) // if it was previously not pressed
    {  
      alt = !alt;
      SetLEDs();
    }
  }
  else
  {
    if(prevButtonState == HIGH)
    {
      alt = !alt;
      SetLEDs();
    }
  }

  prevButtonState = buttonState; // save the previous button state

}

void SetLEDs()
{
  digitalWrite(ledPinA, alt);   // toggle the LED
  digitalWrite(ledPinB, !alt);   // toggle the LED
}