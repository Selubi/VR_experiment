float EYE_X = 100;
float EYE_Y = 80;
float EYE_Z = 80;

float TARGET_X = 0;
float TARGET_Y = 0;
float TARGET_Z = 0;

float UP_X = 0;
float UP_Y = 0;
float UP_Z = -1;

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


void drawArm() {
  float ARM_LENGTH=30;
  float ARM_WIDTH=5;
  translate(0,0, ARM_LENGTH/2);
  box(ARM_WIDTH,ARM_WIDTH,ARM_LENGTH);
  translate(0,0, ARM_LENGTH/2);
}


void drawFinger(){
  float FINGER_LENGTH=15;
  float FINGER_WIDTH=5;
  translate(0,0, FINGER_LENGTH/2);
  box(FINGER_WIDTH,FINGER_WIDTH,FINGER_LENGTH);
  translate(0,0, FINGER_LENGTH/2);
  
}

void drawHand(){
  fill(127,127,127);
  //ARM BASE
  int PERIOD=3000;
  float theta1=(((float)millis()/PERIOD)*TWO_PI)%TWO_PI;
  rotateZ(theta1);
  drawArm();
  //float theta2=(((float)millis()/PERIOD)*HALF_PI)%HALF_PI;
  //float theta2=asin(1-abs((float)millis()%(2*PERIOD)/PERIOD-1)*2);
  
  //MID ARM
  PERIOD=2000;
  float theta2=(sin((((float)millis()/PERIOD)*TWO_PI)%TWO_PI)+1)/2*HALF_PI;
  rotateX(theta2);
  drawArm();
  
  //FINGERS
  PERIOD=1000;
  float theta3=(sin((((float)millis()/PERIOD)*TWO_PI)%TWO_PI)+1)/2*HALF_PI/2;
  //println(theta3);
  pushMatrix();
  rotateX(-theta3);
  drawFinger();
  popMatrix();
  rotateX(theta3);
  drawFinger();
}

void draw() {
  background(255);
  camera(EYE_X, EYE_Y, EYE_Z, TARGET_X, TARGET_Y, TARGET_Z, UP_X, UP_Y, UP_Z);
  lights();

  drawPlane();
  drawAxes(); 

  /* write your code here */
  drawHand();
}
