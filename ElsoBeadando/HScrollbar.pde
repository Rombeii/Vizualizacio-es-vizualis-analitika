class HScrollbar {
  int swidth, sheight;    // width and height of bar
  float xpos, ypos;       // x and y position of bar
  float spos1, newspos1;    // x position of slider1
  float spos2, newspos2;    // x position of slider2
  float sposMin, sposMax; // max and min values of slider
  int loose;              // how loose/heavy
  int over;           // is the mouse over the slider?
  int locked;
  float ratio;

  HScrollbar (float xp, float yp, int sw, int sh, int l) {
    swidth = sw;
    sheight = sh;
    int widthtoheight = sw - sh;
    ratio = (float)sw / (float)widthtoheight;
    xpos = xp;
    ypos = yp-sheight/2;
    spos1 = xpos;
    newspos1 = spos1;
    spos2 = xpos + swidth - sheight;
    newspos2 = spos2;
    sposMin = xpos;
    sposMax = xpos + swidth - sheight;
    loose = l;
  }

  void update() {
    over = overEvent();
    if (mousePressed && over == 1) {
      locked = 1;
    } else if (mousePressed && over == 2) {
      locked = 2;
    }
    if (!mousePressed) {
      locked = 0;
    }
    if (locked == 1) {
      newspos1 = constrain(mouseX-sheight/2, sposMin, spos2);
    } else if (locked == 2) {
      newspos2 = constrain(mouseX-sheight/2, spos1 + sheight, sposMax);
    }
    if (abs(newspos1 - spos1) > 1 && locked == 1) {
      spos1 = spos1 + (newspos1-spos1)/loose;
    } else if (abs(newspos2 - spos2) > 1  && locked == 2) {
      spos2 = spos2 + (newspos2-spos2)/loose;
    }
  }

  float constrain(float val, float minv, float maxv) {
    return min(max(val, minv), maxv);
  }

  //megmondja, hogy melyik felett van
  int overEvent() {
    if (mouseX > spos1 && mouseX < spos1+sheight &&
       mouseY > ypos && mouseY < ypos+sheight) {
      return 1;
    } else if (mouseX > spos2 && mouseX < spos2+sheight &&
       mouseY > ypos && mouseY < ypos+sheight) {
      return 2;
    } else {
      return 0;
    }
  }

  void display() {
    noStroke();
    fill(204);
    rect(xpos, ypos, swidth, sheight);
    if (over !=0 || locked != 0) {
      fill(0, 0, 0);
    } else {
      fill(102, 102, 102);
    }
    rect(spos1, ypos, sheight, sheight);
    rect(spos2, ypos, sheight, sheight);
  }

  float getPos1() {
    return spos1;
  }
  
  float getPos2() {
    return spos2;
  }
}
