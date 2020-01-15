import org.openkinect.freenect.*;
import org.openkinect.processing.*;
import mqtt.*;

MQTTClient client;

OPC opc;
Kinect kinect;
PImage depthImg;
import org.processing.wiki.triangulate.*;
import java.util.Map;


int minDepth =  775;
int maxDepth = 895;
int mode = 4;
PVector[] vectors1 = {new PVector(82, 186), new PVector(86, 188), new PVector(108, 359), new PVector(113, 359)};
PVector[] vectors2 = {new PVector(81, 177), new PVector(196, 47), new PVector(93, 183), new PVector(200, 59)};
PVector[] vectors3 = {new PVector(199, 47), new PVector(381, 48), new PVector(200, 56), new PVector(379, 56)};
PVector[] vectors4 = {new PVector(386, 56), new PVector(484, 191), new PVector(381, 67), new PVector(477, 196)};
PVector[] vectors5 = {new PVector(477, 201), new PVector(486, 200), new PVector(488, 377), new PVector(496, 377)};

int ledWidth = 1200;
int ledHeight = 240;
int ledX = 1920/2-ledWidth/2;
int ledY = 1080/2-ledHeight/2;

PVector[][] allVectors = {vectors1, vectors2, vectors3, vectors4, vectors5};
void setup(){
  size(1920, 1080);
  client = new MQTTClient(this);
  client.connect("mqtt://electro-forest:fe8708c4cd16348a@broker.shiftr.io", "processing", true);
  if (mode == 1) airflowSetup();
  if (mode == 2) goldFishSetup();
  if (mode == 3) particleSetup();
  if (mode == 4) ballSetup();
  ellipseMode(RADIUS);  // Set ellipseMode to RADIUS
  opc = new OPC(this, "127.0.0.1", 7890);
  kinect = new Kinect(this);
  kinect.initDepth();
  depthImg = new PImage(kinect.width, kinect.height);
  
  for (int j = 0; j < 5; j++){
    for(int i = 0; i < 5; i++){
      opc.ledStrip(i*64 + j*512, 16, ledX +ledWidth/6 + j*ledWidth/6, ledY + ledHeight/24 + ledHeight/12 + i*ledHeight/6, ledWidth/100, 0, true);
      opc.ledStrip(16+i*64 + j*512, 15, ledX + ledWidth/6 + j*ledWidth/6, ledY + ledHeight/24 + ledHeight/6 + i*ledHeight/6, ledWidth/100, 0, false);
    }
  }
  
}

void draw(){
  background(0);
  
  
  
  
  
  /*
  LED DRAWING
  */
  push();
  translate(ledX,ledY);
  int[] rawDepth = kinect.getRawDepth();
  touchPoints0.clear();
  touchPoints1.clear();
  touchPoints2.clear();
  touchPoints3.clear();
  touchPoints4.clear();
  for (int i=0; i < rawDepth.length; i++) {
      int x = i % kinect.width;
      int y = i / kinect.width;
    if (rawDepth[i] >= minDepth && rawDepth[i] <= maxDepth) {
      if (inBox(x, y, vectors1) || inBox(x, y, vectors2) || inBox(x, y, vectors3) || inBox(x, y, vectors4) || inBox(x, y, vectors5)){
        touch(x, y, rawDepth[i]);
      }
    }
  }
  if (mode == 1){
    push();
    if (touchPoints0.size() > 0) {
      airflowMouseDragged(touchPoints0.get(0), previous0);
      previous0 = touchPoints0.get(0);
    }
    if (touchPoints1.size() > 0) {
      airflowMouseDragged(touchPoints1.get(0), previous1);
      previous1 = touchPoints1.get(0);
    }
    if (touchPoints2.size() > 0) {
      airflowMouseDragged(touchPoints2.get(0), previous2);
      previous2 = touchPoints2.get(0);
    }
    if (touchPoints3.size() > 0) {
      airflowMouseDragged(touchPoints3.get(0), previous3);
      previous3 = touchPoints3.get(0);
    }
    if (touchPoints4.size() > 0) {
      airflowMouseDragged(touchPoints4.get(0), previous4);
      previous4 = touchPoints4.get(0);
    }
    //airflowMouseDragged(new PVector(mouseX, mouseY), previous0);
    //previous0 = new PVector(mouseX, mouseY);
    airflowDraw();
    pop();
  } else if (mode == 2){
    push();
    if (touchPoints0.size() > 0) handDragged(touchPoints0.get(0).x, touchPoints0.get(0).y);
    if (touchPoints1.size() > 0) handDragged(touchPoints1.get(0).x, touchPoints1.get(0).y);
    if (touchPoints2.size() > 0) handDragged(touchPoints2.get(0).x, touchPoints2.get(0).y);
    if (touchPoints3.size() > 0) handDragged(touchPoints3.get(0).x, touchPoints3.get(0).y);
    if (touchPoints4.size() > 0) handDragged(touchPoints4.get(0).x, touchPoints4.get(0).y);
    goldFishDraw();
    pop();
  } else if (mode == 3){
    push();
    particleDraw();
    pop();
  } else if (mode == 4){
    push();
    ballDraw();
    pop();
    push();
    fill(color(255,255,255));
    stroke(color(255,255,255));
    ellipseMode(RADIUS);
    if (touchPoints0.size() > 0) ellipse(touchPoints0.get(0).x, touchPoints0.get(0).y, 25, 25);
    if (touchPoints1.size() > 0) ellipse(touchPoints1.get(0).x, touchPoints1.get(0).y, 25, 25);
    if (touchPoints2.size() > 0) ellipse(touchPoints2.get(0).x, touchPoints2.get(0).y, 25, 25);
    if (touchPoints3.size() > 0) ellipse(touchPoints3.get(0).x, touchPoints3.get(0).y, 25, 25);
    if (touchPoints4.size() > 0) ellipse(touchPoints4.get(0).x, touchPoints4.get(0).y, 25, 25);
    pop();
  }
  pop();
}


PVector previous0 = new PVector(0, 0);
PVector previous1 = new PVector(0, 0);
PVector previous2 = new PVector(0, 0);
PVector previous3 = new PVector(0, 0);
PVector previous4 = new PVector(0, 0);
ArrayList<PVector> touchPoints0 = new ArrayList<PVector>();
ArrayList<PVector> touchPoints1 = new ArrayList<PVector>();
ArrayList<PVector> touchPoints2 = new ArrayList<PVector>();
ArrayList<PVector> touchPoints3 = new ArrayList<PVector>();
ArrayList<PVector> touchPoints4 = new ArrayList<PVector>();
void touch(int x, int y, int depth){
  //x = x + ledX;
  //y = y + ledY;
  
  //touchPoints.clear();
  for (int i = 0; i < 5; i++){
    if (inBox( x, y, allVectors[i])){
      float dist0 = 0;
      float dist1 = 0;
      switch(i){
        case 0:
          dist0 = allVectors[i][0].dist(new PVector(x, y));
          dist1 = allVectors[i][2].dist(new PVector(x, y));
        break;
        case 1:
          dist0 = allVectors[i][1].dist(new PVector(x, y));
          dist1 = allVectors[i][0].dist(new PVector(x, y));
        break;
        case 2:
          dist0 = allVectors[i][1].dist(new PVector(x, y));
          dist1 = allVectors[i][0].dist(new PVector(x, y));
        break;
        case 3:
          dist0 = allVectors[i][1].dist(new PVector(x, y));
          dist1 = allVectors[i][0].dist(new PVector(x, y));
        break;
        case 4:
          dist0 = allVectors[i][2].dist(new PVector(x, y));
          dist1 = allVectors[i][0].dist(new PVector(x, y));
        break;
      }
      float totalDist = dist0 + dist1;
      float xPercentage = dist0/totalDist;
      int finalX = ledWidth-int(xPercentage*ledWidth/6 + (4-i) * ledWidth/6)-ledWidth/12;
      int finalY = (depth-minDepth)*ledHeight/(maxDepth-minDepth);
      switch(i){
        case 0:
        touchPoints0.add(new PVector(finalX, finalY));
        break;
        case 1:
        touchPoints1.add(new PVector(finalX, finalY));
        break;
        case 2:
        touchPoints2.add(new PVector(finalX, finalY));
        break;
        case 3:
        touchPoints3.add(new PVector(finalX, finalY));
        break;
        case 4:
        touchPoints4.add(new PVector(finalX, finalY));
        break;
      }
    }
  }
}


boolean inBox(int x, int y, PVector[] vectors){
  PVector p1 = vectors[0].copy();
  PVector p2 = vectors[1].copy();
  PVector p3 = vectors[2].copy();
  PVector p4 = vectors[3].copy();
  PVector upperLine = new PVector(1, (p1.y - p2.y)/(p1.x - p2.x));
  PVector underLine = new PVector(1, (p3.y - p4.y)/(p3.x - p4.x));
  
  PVector rightLine = new PVector((p2.x - p4.x)/(p2.y - p4.y), 1);
  PVector leftLine = new PVector((p1.x - p3.x)/(p1.y - p3.y), 1);
  upperLine.mult((x - p1.x));
  underLine.mult((x - p4.x));
  rightLine.mult((y - p2.y));
  leftLine.mult((y-p3.y));
  p1.add(upperLine);
  p4.add(underLine);
  p2.add(rightLine);
  p3.add(leftLine);
  return (y > p1.y && y < p4.y && x < p2.x && x > p3.x);
}

void clientConnected() {
  println("client connected");

  client.subscribe("/minorinteractive/studio/KEIZEN");
}

void messageReceived(String topic, byte[] payload) {
  println("new message: " + topic + " - " + new String(payload));
}

void connectionLost() {
  println("connection lost");
}
void sendMessage(int x){
  client.publish("/minorinteractive/studio/KEIZEN", str(x));
}
void keyPressed() {
  if (key == '0'){
    sendMessage(0);
  } else if (key == '1'){
    sendMessage(1);
  }
  if (key == '4') switchSketch(true);
  if (key == '6') switchSketch(false);
}

void switchSketch(boolean left){
  if (!left) {
    mode++;
    if (mode > 4) mode -= 4;
  } else {
    mode--;
    if (mode < 1) mode += 4;
  }
  if (mode == 1) airflowSetup();
  if (mode == 2) goldFishSetup();
  if (mode == 3) particleSetup();
}
