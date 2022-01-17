float EYE_X = 100;
float EYE_Y = 80;
float EYE_Z = 80;

float TARGET_X = 0;
float TARGET_Y = 0;
float TARGET_Z = 0;

float UP_X = 0;
float UP_Y = 0;
float UP_Z = -1;

float L=30;
float[] target={random(-35, 35), random(-35, 35), 0};
float[] theta={0, HALF_PI, HALF_PI};

class Matrix2D {
  float[][] Matrix={{0, 0}, {0, 0}};
  public Matrix2D(float n00, float n01, float n10, float n11) {
    Matrix[0][0]=n00;
    Matrix[0][1]=n01;
    Matrix[1][0]=n10;
    Matrix[1][1]=n11;
  }

  public void print() {
    println(Matrix[0][0], Matrix[0][1]);
    println(Matrix[1][0], Matrix[1][1]);
  }

  public boolean inverse() {
    float det= Matrix[0][0]*Matrix[1][1]-Matrix[0][1]*Matrix[1][0];
    if (det==0)return false;
    float n00=Matrix[1][1]/det;
    float n01=-Matrix[0][1]/det;
    float n10=-Matrix[1][0]/det;
    float n11=Matrix[0][0]/det;

    Matrix[0][0]=n00;
    Matrix[0][1]=n01;
    Matrix[1][0]=n10;
    Matrix[1][1]=n11;

    return true;
  }
  
  //if this matrix is M and the arguement is v, return Mv;
  public float[] mult_to_right(float[] v) {
    return new float[]{ Matrix[0][0]*v[0]+Matrix[0][1]*v[1], Matrix[1][0]*v[0]+Matrix[1][1]*v[1]};
  }
}



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
  translate(0, 0, ARM_LENGTH/2);
  box(ARM_WIDTH, ARM_WIDTH, ARM_LENGTH);
  translate(0, 0, ARM_LENGTH/2);
}




void drawHand(float[] theta) {
  pushMatrix();
  fill(127, 127, 127);
  //ARM BASE
  rotateZ(theta[0]);
  drawArm();

  //MID ARM
  rotateY(theta[1]);
  drawArm();

  //FINGERS
  rotateY(theta[2]);
  drawArm();
  popMatrix();
}

void drawBall(float[] target) {
  pushMatrix();
  translate(target[0], target[1], target[2]);
  stroke(255, 0, 0);
  sphere(1);
  popMatrix();
}

int sign(float num) {
  return (num<0?-1:1);
}

void draw() {
  background(255);
  camera(EYE_X, EYE_Y, EYE_Z, TARGET_X, TARGET_Y, TARGET_Z, UP_X, UP_Y, UP_Z);
  lights();

  drawPlane();
  drawAxes(); 

  /* write your code here */
  float target_theta0;
  if ((sign(target[0])==-1 && sign(target[1])==1)) {
    target_theta0=atan(target[1]/target[0])+PI;
  } else if ((sign(target[0])==-1 && sign(target[1])==-1)) {
    target_theta0=atan(target[1]/target[0])-PI;
  } else {
    target_theta0=atan(target[1]/target[0]);
  }
  
  //by here, target_theta0 takes -pi to pi angle
  //float dtheta0=target_theta0-theta[0];
  
  float dtheta0=target_theta0-theta[0];
  theta[0]+=sign(dtheta0)*min(abs(dtheta0), HALF_PI/20);
  //println(atan(target[1]/target[0])-theta[0]);

  float targetr=sqrt(pow(target[0], 2)+pow(target[1], 2));
  float currentr=L*sin(theta[1])+L*sin(theta[1]+theta[2]);
  float targetz=target[2];
  float currentz=L+L*cos(theta[1])+L*cos(theta[1]+theta[2]);

  Matrix2D Jacobian=new Matrix2D(L*cos(theta[1])+L*cos(theta[1]+theta[2]), L*cos(theta[1]+theta[2]), -L*sin(theta[1])-L*sin(theta[1]+theta[2]), -L*sin(theta[1]+theta[2]));
  float[] roc_rz={targetr-currentr, targetz-currentz};
  Jacobian.inverse();

  float[] roc_theta=Jacobian.mult_to_right(roc_rz);
  theta[1]+=sign(roc_theta[0])*min(abs(roc_theta[0]), HALF_PI/60);
  theta[2]+=sign(roc_theta[1])*min(abs(roc_theta[1]), HALF_PI/60);
  drawHand(theta);
  drawBall(target);

  if (abs(dtheta0)<0.01 && abs(roc_theta[0])<0.01 && abs(roc_theta[1])<0.01) {
    target[0]=random(-35, 35);
    target[1]=random(-35, 35);
  }
}
