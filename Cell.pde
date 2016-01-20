class Cell {


  float x, y;
  float w, h;
  float angle;
  color col;

  // Cell Constructor
  Cell(float tempX, float tempY, float tempW, float tempH, color tempCol) {
    x = tempX;
    y = tempY;
    w = tempW;
    h = tempH;
    col = tempCol;
  }



  void display() {
    stroke(255);
    fill(col);
    rect(x+20, y+20, w, h);
  }

  void update(color newCol) {
    stroke(255);
    fill(newCol); 
    rect(x+20, y+20, w, h);
  }
}