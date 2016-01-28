class Cell {
  
  float x, y;
  float w, h;
  float angle;
  color col;
  int thing = 0;

  Cell(float tempX, float tempY, float tempW, float tempH, color tempCol) {
    x = tempX;
    y = tempY;
    w = tempW;
    h = tempH;
    col = tempCol;
  }

  void initialize() {
    stroke(255);
    fill(col);
    rect(x, y, w, h);
  }

  void update(color newCol) {
    col = newCol;
    fill(col);
  }
  
}