public class Point {
  float x;
  float y;
  
  public Point(float x, float y) {
    this.x = x;
    this.y = y;
  }
  
  float getDist() {
    return dist( mouseX, mouseY, x, y);
  }
}
