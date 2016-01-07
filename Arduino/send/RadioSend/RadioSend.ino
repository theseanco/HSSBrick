
// Arduino Wire library is required if I2Cdev I2CDEV_ARDUINO_WIRE implementation
// is used in I2Cdev.h
#include "Wire.h"

// I2Cdev and HMC5883L must be installed as libraries, or else the .cpp/.h files
// for both classes must be in the include path of your project
#include "I2Cdev.h"
#include "HMC5883L.h"

//radio things
#include <SPI.h>
#include <nRF24L01.h>
#include <RF24.h>

// class default I2C address is 0x1E
// specific I2C addresses may be passed as a parameter here
// this device only supports one I2C address (0x1E)
HMC5883L mag;

int16_t mx, my, mz;

#define LED_PIN 13
//radio things
#define CE_PIN   9
#define CSN_PIN 10

bool blinkState = false;
const uint64_t pipe = 0xE8E8F0F0E1LL; // Define the transmit pipe

/*-----( Declare objects )-----*/
RF24 radio(CE_PIN, CSN_PIN); // Create a Radio
/*-----( Declare Variables )-----*/
float values[5];  // 2 element array holding Joystick readings

void setup() {
    // join I2C bus (I2Cdev library doesn't do this automatically)
    Wire.begin();

    // initialize serial communication
    // (38400 chosen because it works as well at 8MHz as it does at 16MHz, but
    // it's really up to you depending on your project)
    Serial.begin(9600);

    // initialize device
    Serial.println("Initializing I2C devices...");
    mag.initialize();

    // verify connection
    Serial.println("Testing device connections...");
    Serial.println(mag.testConnection() ? "HMC5883L connection successful" : "HMC5883L connection failed");

    // configure Arduino LED for
    pinMode(LED_PIN, OUTPUT);
    
    //radio things
    radio.begin();
    radio.openWritingPipe(pipe);
}

void loop() {
    // read raw heading measurements from device
    mag.getHeading(&mx, &my, &mz);
    
// To calculate heading in degrees. 0 degree indicates North
    float heading = atan2(my, mx);
    if(heading < 0)
      heading += 2 * M_PI;

    // blink LED to indicate activity
    blinkState = !blinkState;
    digitalWrite(LED_PIN, blinkState);
    
    values[0] = float(mx);
    values[1] = float(my);
    values[2] = float(mz);
    values[3] = heading * 180/M_PI;
    values[4] = float(analogRead(A0));
    
    Serial.println(analogRead(A0));
    
    radio.write( values, sizeof(values) );
}  
