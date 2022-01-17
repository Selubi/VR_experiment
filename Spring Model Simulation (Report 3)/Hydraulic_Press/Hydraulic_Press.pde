// view parameters
boolean showTime = true; //show time in window
boolean showForce = false; //show force currently applied to each particle

boolean doPress =true;//do the hydraulic press or not
boolean moveFloor=true;//if we dont do hydraulic press, do we move the floor up and down
int fps=60;



// physical parameters

float x0 = 0.05;
float y0 = 0.2;

float m = 0.5;

float radius = 0.05;

float k = 10000;
float d = 100.0;

float gx = 0.0;
float gy = 9.8;

float wallY=3.0;
float wallK=1000000.0;
float wallD=100.0;

float dt = 3e-6;

// viewing parameters

float viewingSize = 4.0;

int xOffset;
int yOffset;
float viewingScale;

// objects

int nParticles = 5;
int nSprings = nParticles-1;

Particle[] particles;
Spring[] springs;
Wall wall;
Press press;

float gridSizeX=0.2;
float gridSizeY=0.2;

int gridNumX=8;
int gridNumY=8;
float gridOffsetX;
float gridOffsetY;





// particle ////////////////////////////////////////////////////////////////////

class Particle {
  float x, y;
  float vx, vy;
  float fx, fy;

  float m;
  boolean isFixed;


  float radius;

  float xPrev, yPrev;
  float vxPrev, vyPrev;
  float fxPrev, fyPrev;

  Particle(float x0, float y0, float vx0, float vy0, float m0, 
    boolean f, float r) {
    m = m0;
    x = x0;
    y = y0;
    vx = vx0;
    vy = vy0;
    isFixed = f;
    radius = r;
  }

  void init() {
    fx = 0.0;
    fy = 0.0;

    xPrev = x;
    yPrev = y;
    vxPrev = vx;
    vyPrev = vy;
    fxPrev = fx;
    fyPrev = fy;
  }

  void clearForce() {
    fx = 0.0;
    fy = 0.0;
  }

  void addForce(float x, float y) {
    fx += x;
    fy += y;
  }

  void move(float dt) {
    if (isFixed) {
      return;
    }

    float xNew = x + (3 * vx - vxPrev) * 0.5 * dt;
    float yNew = y + (3 * vy - vyPrev) * 0.5 * dt;
    float vxNew = vx + (3 * fx - fxPrev) * 0.5 * dt / m;
    float vyNew = vy + (3 * fy - fyPrev) * 0.5 * dt / m;

    xPrev = x;
    yPrev = y;
    vxPrev = vx;
    vyPrev = vy;
    fxPrev = fx;
    fyPrev = fy;

    x = xNew;
    y = yNew;
    vx = vxNew;

    vy = vyNew;
  }

  void draw() {
    if (radius <= 0.0) {
      return;
    }


    fill(224);
    stroke(128);
    strokeWeightScaled(1.0);

    pushMatrix();
    translate(x, y);
    if (isGrabbed == true && this == grabbedParticle) {
      fill(240, 128, 128);
    }
    ellipse(0, 0, radius, radius);
    if (showForce)drawForce();
    popMatrix();
  }

  void drawForce() {
    float linescale=100;
    float arrowscale=linescale*3;
    stroke(255, 0, 0);
    line(0, 0, fx/linescale, fy/linescale);
    pushMatrix();
    translate(fx/linescale, fy/linescale);
    pushMatrix();
    rotate(PI/6);
    line(0, 0, -fx/arrowscale, -fy/arrowscale);
    popMatrix();
    rotate(-PI/6);
    line(0, 0, -fx/arrowscale, -fy/arrowscale);
    popMatrix();
  }
};

// spring //////////////////////////////////////////////////////////////////////

class Spring {
  Particle[] particles;
  float k;
  float l0;
  float d;

  Spring(Particle p0, Particle p1, float k0, float l00, float d0)
  {
    particles = new Particle[2];
    particles[0] = p0;
    particles[1] = p1;
    k = k0;
    l0 = l00;
    d = d0;
  }

  void init() {
  }

  void calc() {
    float dx = particles[1].x - particles[0].x;
    float dy = particles[1].y - particles[0].y;
    float l = sqrt(dx * dx + dy * dy);
    float ex = dx / l;
    float ey = dy / l;
    float fx = -k * (l - l0) * ex;
    float fy = -k * (l - l0) * ey;

    float vx = particles[1].vx - particles[0].vx;
    float vy = particles[1].vy - particles[0].vy;
    fx += -d * vx;
    fy += -d * vy;

    particles[0].addForce(-fx, -fy);
    particles[1].addForce(fx, fy);
  }

  void draw() {

    noFill();
    stroke(128);
    strokeWeightScaled(1.0);

    line(particles[0].x, particles[0].y, particles[1].x, particles[1].y);
  }
};

// wall /////////////////////////////////////////////////////////////////////////

class Wall {
  float basey;
  float y;
  float k;
  float d;
  float periode=2;


  Wall(float y0, float k0, float d0) {
    basey = y0;
    y=basey;
    k = k0;
    d = d0;
  }

  float collisionForceX(float dy, float dvx, float dvy) {
    return -d * dvx;
  }


  float collisionForceY(float dy, float dvx, float dvy) {
    return -k * dy - d * dvy;
  }

  void init() {
  }

  void calc() {
    y=basey+sin(curt/periode*TWO_PI)/2;
  }

  void draw() {
    fill(224);
    noStroke();
    rect(-viewingSize / 2, y, viewingSize, viewingSize);

    stroke(128);
    strokeWeightScaled(1.0);
    line(-viewingSize, y, viewingSize, y);
  }
};

//hydraulic press/////////////////////////////////////

class Press {
  float basey;
  float y;
  float k;
  float d;
  float periode=6;
  float limit=wallY;


  Press(float y0, float k0, float d0) {
    basey = y0;
    y=basey;
    k = k0;
    d = d0;
  }

  float collisionForceX(float dy, float dvx, float dvy) {
    return -d * dvx;
  }


  float collisionForceY(float dy, float dvx, float dvy) {
    return -(-k * dy - d * dvy);
  }

  void init() {
  }

  void calc() {
    y=basey+sin((curt/periode*TWO_PI)%PI)*3;
    
  }

  void draw() {
    fill(224);
    noStroke();
    rect(-viewingSize / 2, 0, viewingSize, y);

    stroke(128);
    strokeWeightScaled(1.0);
    line(-viewingSize, y, viewingSize, y);
  }
};


// simulation //////////////////////////////////////////////////////////////////

//init /////////////////////////////////
void simulationInit() {
  gridOffsetX = -gridSizeX * (gridNumX - 1) / 2.0;
  gridOffsetY = 0.5;

  nParticles = gridNumX * gridNumY;
  nSprings = gridNumX * (gridNumY - 1) + (gridNumX - 1) * gridNumY
    + 2 * (gridNumX - 1) * (gridNumY - 1);


  particles = new Particle[nParticles];
  for (int j = 0; j < gridNumY; j++) {
    for (int i = 0; i < gridNumX; i++) {
      int n = i + j * gridNumX;
      particles[n] = new Particle(gridOffsetX + i * gridSizeX, 
        gridOffsetY + j * gridSizeY, 
        0.0, 0.0, m, false, radius);
    }
  }

  springs = new Spring[nSprings];
  int n = 0;
  for (int j = 0; j < gridNumY; j++) {
    for (int i = 0; i < gridNumX - 1; i++) {
      springs[n] = new Spring(particles[i + j * gridNumX], 
        particles[(i + 1) + j * gridNumX], 
        k, gridSizeX, d);
      n++;
    }
  }

  for (int j = 0; j < gridNumY - 1; j++) {
    for (int i = 0; i < gridNumX; i++) {
      springs[n] = new Spring(particles[i + j * gridNumX], 
        particles[i + (j + 1) * gridNumX], 
        k, gridSizeY, d);
      n++;
    }
  }

  float l = sqrt(gridSizeX * gridSizeX + gridSizeY * gridSizeY);
  for (int j = 0; j < gridNumY - 1; j++) {
    for (int i = 0; i < gridNumX - 1; i++) {
      springs[n] = new Spring(particles[i + j * gridNumX], 
        particles[(i + 1) + (j + 1) * gridNumX], 
        k, l, d);
      n++;
    }
  }
  for (int j = 0; j < gridNumY - 1; j++) {
    for (int i = 0; i < gridNumX - 1; i++) {
      springs[n] = new Spring(particles[(i + 1) + j * gridNumX], 
        particles[i + (j + 1) * gridNumX], 
        k, l, d);
      n++;
    }
  }

  for (Particle p : particles) {
    p.init();
  }

  for (Spring s : springs) {
    s.init();
  }
  wall = new Wall(wallY, wallK, wallD);
  wall.init();
  press = new Press(0, wallK, wallD);
  press.init();
}


//calc /////////////////////////////////
void simulationCalc() {
  while (true) {
    if (isGrabbed) {
      float mx = (mouseX - xOffset) / viewingScale;
      float my = (mouseY - yOffset) / viewingScale;
      grabbedParticle.x = mx;
      grabbedParticle.y = my;
      float vx = (mouseX - pmouseX) / viewingScale;
      float vy = (mouseY - pmouseY) / viewingScale;
      grabbedParticle.vx = vx;
      grabbedParticle.vy = vy;
    }

    for (Particle p : particles) {
      p.clearForce();
      p.addForce(p.m * gx, p.m * gy);
    }

    //if (mousePressed == true) {
    //  float mx = (mouseX - xOffset) / viewingScale;
    //  float my = (mouseY - yOffset) / viewingScale;
    //  for (Particle p : particles) {
    //    float dx = mx - p.x;
    //    float dy = my - p.y;
    //    float pullK = 10.0;
    //    p.addForce(pullK * dx, pullK * dy);
    //  }
    //}

    //wall collision
    for (Particle p : particles) {
      float dy = (p.y + p.radius) - wall.y;
      if (dy > 0.0) {
        p.addForce(wall.collisionForceX(dy, p.vx, p.vy), 
          wall.collisionForceY(dy, p.vx, p.vy));
      }
    }
    //press collision
    for (Particle p : particles) {
      float dy = - (p.y - p.radius) + press.y;
      if (dy > 0.0) {
        p.addForce(press.collisionForceX(dy, p.vx, p.vy), 
          press.collisionForceY(dy, p.vx, p.vy));
      }
    }
    if (!doPress && moveFloor)wall.calc();
    if(doPress)press.calc();
    for (Spring s : springs) {
      s.calc();
    }

    for (Particle p : particles) {
      p.move(dt);
    }
  }
}


//draw /////////////////////////////////
void simulationDraw() {
  ellipseMode(RADIUS);
  background(255);
  pushMatrix();
  translate(xOffset, yOffset);
  scale(viewingScale);

  for (Spring s : springs) {
    s.draw();
  }

  for (Particle p : particles) {
    p.draw();
  }
  wall.draw();
  press.draw();
  popMatrix();
  if (showTime)displaytime();
}

// utility function ////////////////////////////////////////////////////////////
PFont f; 
float curt=0;
void displaytime() {
  textFont(f, 16);                  // STEP 3 Specify font to be used
  fill(0);                         // STEP 4 Specify font color
  text("cur_t : "+nf(curt, 0, 2), 0.8*width,0.1*height);   // STEP 5 Display Text
  //text(y,width*0.9,height*0.2);   // STEP 5 Display Text
  curt+=(float)1/fps;
}

void strokeWeightScaled(float s) {
  strokeWeight(s / viewingScale);
}

// setup ///////////////////////////////////////////////////////////////////////

void setup() {
  size(512, 512);
  frameRate(fps);
  smooth(4);
  f = createFont("Arial", 16, true); // STEP 2 Create Font
  xOffset = width / 2;
  yOffset = 0;
  viewingScale = width / viewingSize;

  simulationInit();
  thread("simulationCalc");
}

// draw ////////////////////////////////////////////////////////////////////////

void draw() {
  simulationDraw();
}

// callbacks ///////////////////////////////////////////////////////////////////

void keyPressed() {
  if (key == ESC || key == 'q') {
    exit();
  }
}
// interaction

boolean isGrabbed = false;
Particle grabbedParticle;
float grabStartX;
float grabStartY;

void mousePressed() {
  float mx = (mouseX - xOffset) / viewingScale;
  float my = (mouseY - yOffset) / viewingScale;
  for (Particle p : particles) {
    float dx = p.x - mx;
    float dy = p.y - my;
    if (dx * dx + dy * dy < p.radius * p.radius) {
      isGrabbed = true;
      grabbedParticle = p;
      grabbedParticle.isFixed = true;
      grabStartX = mouseX;
      grabStartY = mouseY;
      break;
    }
  }
}

void mouseReleased() {
  if (isGrabbed) {
    isGrabbed = false;
    grabbedParticle.isFixed = false;
  }
}


//mouse interaction 1 ////////////////////////////////
//void mousePressed() {
//  if (mousePressed == true) {
//    float mx = (mouseX - xOffset) / viewingScale;
//    float my = (mouseY - yOffset) / viewingScale;
//    for (Particle p : particles) {
//      float dx = mx - p.x;
//      float dy = my - p.y;
//      float pullK = 10.0;
//      p.addForce(pullK * dx, pullK * dy);
//    }
//  }
//}
