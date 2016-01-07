/**
 * oscP5parsing by andreas schlegel
 * example shows how to parse incoming osc messages "by hand".
 * it is recommended to take a look at oscP5plug for an
 * alternative and more convenient way to parse messages.
 * oscP5 website at http://www.sojamo.de/oscP5
 */

import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress myRemoteLocation;
NetAddress superCollider;

PGraphics data;
PGraphics netinfo;
PGraphics currentiplayer;

int xpos=0;
int ypos=0;

Boolean sw = false;
Boolean netsw = false;
Boolean ipsw = false;

//strings holding data from OSC messages
String message = " ";
String ipAddr = "127.0.0.1";
String currentip = "";

int tsize = 14; //change this to universally change the size and distribution of Whois data which is spat out 
int btColor1 = 255; //declaring colours of background writing
int btColor2 = 255;
int btColor3 = 255;

PFont ipFont;

void setup() {
  
  //size(1600,900);
    fullScreen();
  frameRate(25);
  /* start oscP5, listening for incoming messages at port 12000 */
  oscP5 = new OscP5(this,12000);
  
  /* myRemoteLocation is a NetAddress. a NetAddress takes 2 parameters,
   * an ip address and a port number. myRemoteLocation is used as parameter in
   * oscP5.send() when sending osc packets to another computer, device, 
   * application. usage see below. for testing purposes the listening port
   * and the port of the remote location address are the same, hence you will
   * send messages back to this sketch.
   */
  myRemoteLocation = new NetAddress("127.0.0.1",12000);
  superCollider = new NetAddress("127.0.0.1", 57120);
  netinfo = createGraphics(width,height);
  data = createGraphics(width,height);
  currentiplayer = createGraphics(width,height);
  
  
  //load the font
  ipFont = loadFont("DroidSansMono-150.vlw");
  
  //randomise text size
  tsize = int(random(10,25));
  
  
  background(0);
}

void draw() {
  
  background(0);
  textSize(tsize);
 
    //function in the draw loop which draws the message if there is a trigger from the OSC reciever.
    //once the characters have been drawn the boolean flips back to false.
      data.beginDraw();
      data.textSize(tsize); 
      data.fill(btColor1,btColor2,btColor3,255);
      if(sw==true){
      for (int i = 0; i < message.length(); i++) {
      // Each character is displayed one at a time with the charAt() function.
      data.text(message.charAt(i),xpos,ypos);
      // All characters are spaced 10 pixels apart.
      xpos += tsize*0.7;   
      }
      sw = false;
      };
      data.endDraw();
      
      //function to change the colour of characters when the switch indicator turns true
      if ( netsw == true){
        //netinfo.clear();
        btColor1 = int(random(50,255));
        btColor2 = int(random(50,255));
        btColor3 = int(random(50,255));
        netinfo.beginDraw();
        netinfo.background(0,0,0,0); //this still doesn't wipe the original text...
        netinfo.textFont(ipFont);
        netinfo.textSize(height/9);
        netinfo.textAlign(CENTER);
        netinfo.text("Current IP: "+ipAddr,width/2,height/5);
        netinfo.endDraw();
        netsw = false;
      }
      
      if ( ipsw == true){
        //netinfo.clear();
        currentiplayer.beginDraw();
        currentiplayer.background(0,0,0,0); //this still doesn't wipe the original text...
        currentiplayer.textFont(ipFont);
        currentiplayer.textSize(height/12);
        currentiplayer.textAlign(CENTER);
        currentiplayer.text("Direction: "+currentip,width/2,height/5*3);
        currentiplayer.endDraw();
        ipsw = false;
      }
      
      if(xpos>width){
        ypos = ypos+tsize;
        xpos= int(random(-50,0));
      }
      
      if(ypos>height){
        ypos=0;
        data.clear();
        tsize = int(random(10,25));
      }
     
     
     image(data,0,0);
     image(netinfo,0,0);
     image(currentiplayer,0,0);
      
}


void oscEvent(OscMessage theOscMessage) {
  /* check if theOscMessage has the address pattern we are looking for. */
  
  if(theOscMessage.checkAddrPattern("/whois")==true) {
    /* check if the typetag is the right one. */
    if(theOscMessage.checkTypetag("s")) {
      /* parse theOscMessage and extract the values from the osc message arguments. */
      message = theOscMessage.get(0).stringValue();
      
      //this sends the info onto supercollider. great.
      OscMessage msg = new OscMessage("/scwhois");
      msg.add("x");
      oscP5.send(msg, superCollider);
      //println(" values: "+message);
      sw = true;
     
      return;
    }
  }
  if(theOscMessage.checkAddrPattern("/netinfo")==true) {
    /* check if the typetag is the right one. */
    if(theOscMessage.checkTypetag("s")) {
      /* parse theOscMessage and extract the values from the osc message arguments. */
      ipAddr = theOscMessage.get(0).stringValue();
      //again, sending on
      OscMessage msg = new OscMessage("/scnetinfo");
      msg.add("x");
      oscP5.send(msg, superCollider);
      //forwarding message to supercollider
      //println(" values: "+message);
      netsw = true;
     
      return;
    }
  }
     if(theOscMessage.checkAddrPattern("/currentip")==true) {
    /* check if the typetag is the right one. */
    if(theOscMessage.checkTypetag("s")) {
      /* parse theOscMessage and extract the values from the osc message arguments. */
      currentip = theOscMessage.get(0).stringValue();
      //println(" values: "+message);
      ipsw = true;
     
      return;
     }
  }
  println("### received an osc message. with address pattern "+theOscMessage.addrPattern());
}