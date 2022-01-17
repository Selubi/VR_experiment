float EYE_X = 100;
float EYE_Y = 80;
float EYE_Z = 80;

float TARGET_X = 0;
float TARGET_Y = 0;
float TARGET_Z = 0;

float UP_X = 0;
float UP_Y = 0;
float UP_Z = -1;

PMatrix3D cur=new PMatrix3D(1,0,0,0,0,1,0,0,0,0,1,50,0,0,0,1);
float anglespeed=PI/120;
float linearspeed=2;

void setup() {
  size(512, 512, P3D);
  frameRate(60);
}

void drawAxes() {
  float axisLength = 50;
  strokeWeight(5);
  noFill();
  stroke(240, 64, 64);
  line(0, 0, 0, axisLength, 0, 0);
  stroke(64, 192, 64);
  line(0, 0, 0, 0, axisLength, 0);
  stroke(64, 64, 255);
  line(0, 0, 0, 0, 0, axisLength);
}

void drawPlane() {
  int numX = 16;
  int numY = 16;
  float sideLength = 20.0;
  color[] c = {220, 200};
  noStroke();
  pushMatrix();
  translate(-(numX / 2) * sideLength, -(numY / 2) * sideLength, 0);
  for (int x = 0; x < numX; x++) {
    for (int y = 0; y < numY; y++) {
      fill(c[(x + y) % 2]);
      rect(0, 0, sideLength, sideLength);
      translate(sideLength, 0, 0);
    }
    translate(-numX * sideLength, sideLength, 0);
  }
  popMatrix();
}
void drawAirplane(){
  float b=30;
  fill(127,127,127);
  noStroke();
  box(30,5,5);
  pushMatrix();
  translate(b/3,0,0);
  box(5,20,2);
  popMatrix();
  translate(-b*3/8,0,0);
  box(5,14,2);
  rotateY(-PI/2);
  translate(5,0,0);
  box(6,2,5);
}
void draw() {
  background(255);
  
  camera(EYE_X, EYE_Y, EYE_Z, TARGET_X, TARGET_Y, TARGET_Z, UP_X, UP_Y, UP_Z);
  lights();

  drawPlane();
  drawAxes(); 
  
  /* write your code here */
  applyMatrix(cur);
  //roll
  if(keyPressed && key=='a'){
      float s=sin(anglespeed);
      float c=cos(anglespeed);
      cur.apply(new PMatrix3D(1,0,0,0,0,c,-s,0,0,s,c,0,0,0,0,1));
  }
  if(keyPressed && key=='d'){
      float s=sin(-anglespeed);
      float c=cos(-anglespeed);
      cur.apply(new PMatrix3D(1,0,0,0,0,c,-s,0,0,s,c,0,0,0,0,1));
  }
  //pitch
  if(keyPressed && key=='w'){
      float s=sin(anglespeed);
      float c=cos(anglespeed);
      cur.apply(new PMatrix3D(c,0,s,0,0,1,0,0,-s,0,c,0,0,0,0,1));
  }
  if(keyPressed && key=='s'){
      float s=sin(-anglespeed);
      float c=cos(-anglespeed);
      cur.apply(new PMatrix3D(c,0,s,0,0,1,0,0,-s,0,c,0,0,0,0,1));
  }
  //yaw
  if(keyPressed && key=='q'){
      float s=sin(-anglespeed);
      float c=cos(-anglespeed);
      cur.apply(new PMatrix3D(c,-s,0,0,s,c,0,0,0,0,1,0,0,0,0,1));
  }
  if(keyPressed && key=='e'){
      float s=sin(anglespeed);
      float c=cos(anglespeed);
      cur.apply(new PMatrix3D(c,-s,0,0,s,c,0,0,0,0,1,0,0,0,0,1));
  }
  
  //front and back
   if(keyPressed && key=='f'){
      cur.apply(new PMatrix3D(1,0,0,linearspeed,0,1,0,0,0,0,1,0,0,0,0,1));
  }
     if(keyPressed && key=='b'){
      cur.apply(new PMatrix3D(1,0,0,-linearspeed,0,1,0,0,0,0,1,0,0,0,0,1));
  }
  //cur.apply(new PMatrix3D(1,0,0,linearspeed,0,1,0,0,0,0,1,0,0,0,0,1));
  drawAirplane();
}
