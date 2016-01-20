class Cell {
  float x, y;
  float w, h;
  float angle;
  color col;
  int offset = 20;
  
  Cell(float tempX, float tempY, float tempW, float tempH, color tempCol) {
    x = tempX;
    y = tempY;
    w = tempW;
    h = tempH;
    col = tempCol;
  }
  


  void display() {
    stroke(#FFFFFF);
    fill(col);
    rect(x+offset, y+offset, w, h);
  }

  void update(color newCol) {
    stroke(#FFFFFF);
    fill(newCol); 
    rect(x+offset, y+offset, w, h);
  }
}