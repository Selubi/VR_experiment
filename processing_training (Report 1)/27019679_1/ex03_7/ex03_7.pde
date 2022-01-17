float EYE_X = 100;
float EYE_Y = 80;
float EYE_Z = 80;

float TARGET_X = 0;
float TARGET_Y = 0;
float TARGET_Z = 0;

float UP_X = 0;
float UP_Y = 0;
float UP_Z = -1;

float[] billboardX;
float[] billboardY;
float[] billboardZ;

final int numBillboards = 50;
final float billboardSize = 10.0;
PImage billboardImage;

void setupBillboard() {
  billboardX = new float[numBillboards];
  billboardY = new float[numBillboards];
  billboardZ = new float[numBillboards];

  for (int i = 0; i < numBillboards; i++) {
    billboardX[i] = random(-100, 100);
    billboardY[i] = random(-100, 100);
    billboardZ[i] = billboardSize;
  }

  billboardImage = loadImage("hatena-block.jpg");
}

void setup() {
  size(512, 512, P3D);
  frameRate(60);

  setupBillboard();
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

void drawBillboards() {
  noLights();
  noStroke();
  for (int i = 0; i < numBillboards; i++) {
    pushMatrix();
    translate(billboardX[i], billboardY[i], billboardZ[i]);

    /* write here */
    float theta1=atan(EYE_Y/EYE_X);//
    float theta2=atan(EYE_Z/sqrt(pow(EYE_Y,2)+pow(EYE_X,2)));
    rotateZ(theta1);
    rotateY(-theta2);

    beginShape();
    texture(billboardImage);
    textureMode(NORMAL);
    float l = billboardSize / 2;
    vertex(0, -l, -l, 1, 1);
    vertex(0, -l, l, 1, 0);
    vertex(0, l, l, 0, 0);
    vertex(0, l, -l, 0, 1);
    endShape();
    popMatrix();
  }
}

void draw() {
  background(255);
  camera(EYE_X, EYE_Y, EYE_Z, TARGET_X, TARGET_Y, TARGET_Z, UP_X, UP_Y, UP_Z);

  drawAxes();
  drawPlane();

  drawBillboards();

  if (keyPressed) {
    if (key == 'q' || key == ESC) {
      exit();
    }
  }
}
