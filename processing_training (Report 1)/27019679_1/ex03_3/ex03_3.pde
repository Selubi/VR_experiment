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



void polarTransform(float r, float theta, float phi) {
  rotateZ(phi);
  rotateY(theta);
  translate(r, 0, 0);
}

void drawBall() {
  int a=5, r=70;
  fill(255, 0, 255);
  stroke(255, 0, 255);
  for (int i=0; i<=90; i+=10) {
    for (int j=0; j<=90; j+=10) {
      pushMatrix();
      polarTransform(r, (float)-i/180*PI, (float)j/180*PI);
      box(1, a, a);
      popMatrix();
    }
  }
}


void draw() {
  background(255);
  camera(EYE_X, EYE_Y, EYE_Z, TARGET_X, TARGET_Y, TARGET_Z, UP_X, UP_Y, UP_Z);
  lights();

  drawPlane();
  drawAxes(); 

  /* write your code here */
  drawBall();
}
