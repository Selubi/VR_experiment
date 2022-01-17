#include <M5StickC.h>

//important variables
int step = 0;
float accel = 0;
float baseline = 1.1;


//parameters
float passCoef = 0.2;
float width = baseline / 5;
int BASE_COUNT = 25;
int DELAY = 100;

//flags
bool useLowPassFilter = true;
bool useMidpoint=true;

//backendvariable
boolean state = false;
boolean old_state = false;
int count = 0;
float total = 0;
float accelPrev = 1;
float cur_max = 0;
float cur_min = 100;

//graphing variables
const int HISTORY_SIZE = 100;
int SCREEN_WIDTH;
int SCREEN_HEIGHT;
float accHistory[HISTORY_SIZE];
float avgHistory[HISTORY_SIZE];
int next = 0;
int newest = -1;
const int OFFSET_X = 4;
const int OFFSET_Y = 4;
const int GRAPH_OFFSET_X = 60;
const int GRAPH_OFFSET_Y = 0;
const int GRAPH_WIDTH = 100;
const int GRAPH_HEIGHT = 80;
const float ACC_RANGE = 2;
const float AVG_RANGE = 2;
uint16_t infoBackground = M5.Lcd.color565(224, 224, 224);
uint16_t graphBackground = WHITE;

//changing display variable
boolean displayGraph = false;

void initHistory() {
  for (int i = 0; i < HISTORY_SIZE; i++) {
    accHistory[i] = 0.0;
    avgHistory[i] = 0.0;
  }
  next = 0;
  newest = -1;
}

void storeHistory(float acc, float avg) {
  accHistory[next] = acc;
  avgHistory[next] = avg;
  newest = next;
  next = (next + 1) % HISTORY_SIZE;
}

//function to reset step counter (B button)
void resetCounter() {
  if (M5.BtnB.wasPressed()) {
    initHistory();
    step = 0;
    if (displayGraph) {
      M5.Lcd.fillScreen(graphBackground);
      M5.Lcd.fillRect(0, 0, GRAPH_OFFSET_X, SCREEN_HEIGHT, infoBackground);

    }
    else {
      M5.Lcd.fillScreen(BLACK);
      //      M5.Lcd.setTextSize(1);
    }
  }
}

//function to change the display (A button)
void changeDisplay() {
  if (M5.BtnA.wasPressed()) {
    if (displayGraph) {
      M5.Lcd.fillScreen(BLACK);
    }
    else {
      M5.Lcd.fillScreen(graphBackground);
      M5.Lcd.fillRect(0, 0, GRAPH_OFFSET_X, SCREEN_HEIGHT, infoBackground);
      //      M5.Lcd.setTextSize(1);
    }
    displayGraph = !displayGraph;
  }

}

void drawGraph(float *data, int x, uint16_t color, float range, int x0, int y0, int w, int h) {
  int OFFSET = 2;
  int x1 = (x - 1 + HISTORY_SIZE) % HISTORY_SIZE;
  float d1 = data[x1];
  int y1 = (h / 2) - (int)((d1 - OFFSET) / range * (h / 2));

  int x2 = x;
  float d2 = data[x2];
  int y2 = (h / 2) - (int)((d2 - OFFSET) / range * (h / 2));

  if (x1 > x2) {
    x1 = 0;
  }
  x1 += x0;
  x2 += x0;

  y1 = constrain(y1, 0, h);
  y2 = constrain(y2, 0, h);
  y1 += y0;
  y2 += y0;

  M5.Lcd.drawLine(x1, y1, x2, y2, color);
}

//pedometer only
void display1() {
  M5.Lcd.setTextSize(7);
  M5.Lcd.setCursor(20, 15);
  M5.Lcd.setTextColor(M5.Lcd.color565(224, 224, 0), BLACK);
  M5.Lcd.printf("%d", step);
}

//graph
void display2() {
  M5.Lcd.setTextSize(1);
  uint16_t accColor = M5.Lcd.color565(240, 32, 32);
  uint16_t avgColor = M5.Lcd.color565(16, 16, 240);

  int x0 = OFFSET_X;
  int y0 = OFFSET_Y;
  const int dy = 8;
  M5.Lcd.setCursor(x0, y0);
  M5.Lcd.setTextColor(accColor, infoBackground);
  M5.Lcd.printf("Acc:%5.1f", accel);
  y0 += dy;
  M5.Lcd.setCursor(x0, y0);
  M5.Lcd.setTextColor(avgColor, infoBackground);
  M5.Lcd.printf("Base:%4.1f", baseline);
  y0 += dy;
  M5.Lcd.setCursor(x0, y0);
  M5.Lcd.setTextColor(BLACK, infoBackground);
  M5.Lcd.printf("step:%3d", step);

  M5.Lcd.drawLine(GRAPH_OFFSET_X + newest, 0, GRAPH_OFFSET_X + newest, SCREEN_HEIGHT, graphBackground);

  drawGraph(accHistory, newest, accColor, ACC_RANGE, GRAPH_OFFSET_X, GRAPH_OFFSET_Y, GRAPH_WIDTH, GRAPH_HEIGHT);
  drawGraph(avgHistory, newest, avgColor, AVG_RANGE, GRAPH_OFFSET_X, GRAPH_OFFSET_Y, GRAPH_WIDTH, GRAPH_HEIGHT);

  M5.Lcd.drawLine(GRAPH_OFFSET_X + next, 0, GRAPH_OFFSET_X + next, SCREEN_HEIGHT, DARKCYAN);

}



void base_average() {
  if (count < BASE_COUNT) {
    total += accel;
    count += 1;
  } else {
    baseline = total / count;
    width = baseline / 10;
    total = baseline;
    count = 1;
  }
}



void base_midpoint() {
  cur_min = min(cur_min, accel);
  cur_max = max(cur_max, accel);
  count += 1;
  if (count == BASE_COUNT) {
    baseline = (cur_max + cur_min) / 2;
    width = baseline / 5;
    cur_max = 0;
    cur_min = 100;
    count = 0;
  }
}


void setup() {
  M5.begin();
  M5.Lcd.setRotation(1);

  SCREEN_WIDTH = M5.Lcd.width();
  SCREEN_HEIGHT = M5.Lcd.height();
  if (M5.IMU.Init()) { // -1: failed?
    M5.Lcd.fillScreen(RED);
  } else {
    M5.Lcd.fillScreen(BLACK);
  }
}


void loop() {
  M5.update(); // これが必要
  float accX, accY, accZ;

  //get the accel vector
  M5.IMU.getAccelData(&accX, &accY, &accZ);
  accel = sqrt(accX * accX + accY * accY + accZ * accZ);

  //lowpassfilter
  if (useLowPassFilter) accel = passCoef * accelPrev + (1 - passCoef) * accel;

  //for graphing
  storeHistory(accel, baseline);

  //use midpoint or average for the border
  if(useMidpoint)base_midpoint();
  else base_average();

  //change current state
  if (accel > baseline + width) {
    state = true;
  } else if (accel < baseline) {
    state = false;
  }

  // Count step.
  if (!old_state && state) {
    step += 2;
  }

  old_state = state;

  //mid buttonpress, change display type
  changeDisplay();
  if (!displayGraph) {
    display1();
  }
  else {
    display2();
  }

  //serial monitoring
  Serial.print(baseline);
  Serial.print(" ");
  Serial.println(accel);

  //for low pass filter
  accelPrev = accel;

  //side button press, if pressed reset step counter
  resetCounter();

  delay(DELAY);
}
