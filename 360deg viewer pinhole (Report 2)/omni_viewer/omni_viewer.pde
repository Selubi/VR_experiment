PImage imgSrc;
PImage imgDst;

float theta_v;
float phi_v;
float theta_fovx;


void IO() {
  //look right
  if (keyPressed&&key=='d') {
    phi_v-=PI/60;
  }
  //look left
  if (keyPressed&&key=='a') {
    phi_v+=PI/60;
  }
  //look down
  if (keyPressed&&key=='s') {
    theta_v+=PI/60;
  }
  //look up
  if (keyPressed&&key=='w') {
    theta_v-=PI/60;
  }
  //zoom out
  if (keyPressed&&key=='q'&&theta_fovx<radians(90)) {
    theta_fovx+=radians(1);
  }
  //zoom in
  if (keyPressed&&key=='e'&&theta_fovx>radians(30)) {
    theta_fovx-=radians(1);
  }
}

color bilinear(float x, float y) {
  //takes two float positions, x and y and return the bilinear filtered color
  int x1=floor(x);
  int x2;
  if (x1==imgSrc.width-1) {
    x2=x1;
  } else {
    x2=floor(x)+1;
  }
  int y1=floor(y);
  int y2;
  if (y1==imgSrc.height-1) {
    y2=y1;
  } else {
    y2=floor(y)+1;
  }
  float u=x-x1;
  float v=y-y1;

  //count weight
  float tlc=((float)1-u)*(1-v)*imgSrc.pixels[x1 + y1 * imgSrc.width];
  float trc=(float)u*(1-v)*imgSrc.pixels[x2 + y1 * imgSrc.width];
  float blc=((float)1-u)*v*imgSrc.pixels[x1 + y2 * imgSrc.width];
  float brc=u*v*imgSrc.pixels[x2 + y2 * imgSrc.width];
  return (int)(tlc+trc+blc+brc);
}

void calcPixel(float w, float h, float f) {
  for (int j = 0; j < imgDst.height; j++) {
    for (int i = 0; i < imgDst.width; i++) {
      //Fix Z axis as the direction we are looking
      //Find the camera axes

      PVector ex, ey, ez;//This actually can be done outside of the loop but it bugs.
      ex=new PVector(sin(phi_v), -cos(phi_v), (float)0);
      ey=new PVector(cos(theta_v)*cos(phi_v), cos(theta_v)*sin(phi_v), -sin(theta_v));
      ez=new PVector(sin(theta_v)*cos(phi_v), sin(theta_v)*sin(phi_v), cos(theta_v));

      //Determine current pixel in screen before rotation (world axis)
      PVector cam_coor=new PVector((i-imgDst.width/2)*w/imgDst.width, (j-imgDst.height/2)*h/imgDst.height, f);
      //Determine current pixel in screen after rotation (camera axis)
      PVector omni=ex.mult(cam_coor.x).add(ey.mult(cam_coor.y).add(ez.mult(cam_coor.z)));


      //Determine the polar coordinates of the pixel in the sphere
      float theta=atan2(sqrt(omni.x*omni.x+omni.y*omni.y), omni.z);
      float phi;
      if (omni.y>=0 && omni.x>=0 || omni.y>=0 && omni.x<0) {
        phi=atan2(omni.y, omni.x);
      } else {
        phi=atan2(omni.y, omni.x)+TWO_PI;
      }

      //from the polar coordinates, find the pixel in the source image.
      int x, y;
      x = floor(((float)1-phi/TWO_PI)*imgSrc.width);
      y = floor(theta/PI*imgSrc.height);

      //if that pixel is in the screen apply bilinear filter and copy it.
      if (x>=0 && x<imgSrc.width && y>=0 && y<imgSrc.height) {
        //color c = imgSrc.pixels[x1 + y1 * imgSrc.width]; 
        color c=bilinear(x, y);
        imgDst.pixels[i + j * imgDst.width] = c;
      } else //make it black {
      imgDst.pixels[i + j * imgDst.width] = color(0, 0, 0);
    }
  }

  //update pixel display
  imgDst.updatePixels();
  set(0, 0, imgDst);
}

void setup() {
  size(640, 360);
  frameRate(60);
  imgSrc = loadImage("panorama.jpg");
  imgDst = createImage(width, height, RGB);

  theta_v = HALF_PI;
  phi_v = PI;
  theta_fovx = radians(50); // 50deg
}

void draw() {

  //Calss IO() to handle input
  IO();

  imgSrc.loadPixels();
  imgDst.loadPixels();

  //calculate virtual screen characteristics
  float f, w, h;
  f=5;
  w=(float)2*f*tan(theta_fovx/2);
  h=(float)imgDst.height/(float)imgDst.width*w;

  //calculate pixel for the screen
  calcPixel(w, h, f);
}
