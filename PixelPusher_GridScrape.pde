import oscP5.*;
import netP5.*;
import com.heroicrobot.dropbit.registry.*;
import com.heroicrobot.dropbit.devices.pixelpusher.Pixel;
import com.heroicrobot.dropbit.devices.pixelpusher.Strip;
import java.util.*;

TestObserver testObserver;
DeviceRegistry registry;
Cell[][] grid;

OscP5 oscP5;   
NetAddress myRemoteLocation;

int rows;
int cols;



void setup() {

  size(1280, 480);
  registry = new DeviceRegistry();
  testObserver = new TestObserver();
  registry.addObserver(testObserver);
  prepareExitHandler();

  oscP5 = new OscP5(this, 5001);
  myRemoteLocation = new NetAddress("127.0.0.1", 5001);
  
}


public void gridSetup() {

  List<Strip> strips = registry.getStrips();
  for (Strip strip : strips) {
    cols = strip.getLength();
    rows = strips.size();
  }

  /* Offline mode
   cols = 100;
   rows = 3;
   */

  grid = new Cell[cols][rows];

  for (int r = 0; r < rows; r++) {
    for (int c = 0; c < cols; c++) {
      grid[c][r] = new Cell(c*(width/cols), r*(width/cols), width/cols, width/cols, color(0));
      grid[c][r].display();
    }
  }
}




void draw() {
  background(#000000);

  if (testObserver.hasStrips) {
    gridSetup();
    for (int r = 0; r < rows; r ++ ) {     
      for (int c = 0; c < cols; c ++ ) {
        //grid[c][r].display();
        grid[3][r].update(color(255,255,255));
      }
    }

    /*
    color testcol = color(255, 0, 0);
     grid[j][i].update(testcol);
     */

    // this should just scrape the color from the displayed grid
    // will set the colors initially with display() then again with update() on OSC event
    registry.startPushing();
    List<Strip> strips = registry.getStrips();
    int numStrips = strips.size();

    for (Strip strip : strips) {
      int xscale = width/numStrips;
      for (int stripx = 0; stripx < strip.getLength(); stripx++) {
        for (int r = 0; r < rows; r ++ ) {     
          for (int c = 0; c < cols; c ++ ) {
            strip.setPixel(grid[c][r].col, stripx);
          }
        }
      }
    }
  }
}



// Need to establish OSC protocol
// Strip, pixels, colors
// Set grid squares to matching numbers
public void oscEvent(OscMessage theOscMessage) {
  List<Integer> pixelArr = new ArrayList<Integer>();
  for (int i = 0; i < theOscMessage.arguments().length; i++) {
    int n = (Integer) theOscMessage.arguments()[i];
    pixelArr.add(n);
  }
  println("////////////////////");
  println(pixelArr);
  println("////////////////////");


  if (testObserver.hasStrips) {
    for (Integer pix : pixelArr) {
      int strp = pixelArr.get(0);
      for (int r = 0; r < rows; r ++ ) {     
        for (int c = 0; c < cols; c ++ ) {
          //grid[pixelArr.get(pix)][strp].update(color(255, 255, 255));
          grid[r][c].update(color(255, 255, 255));
        }
      }
    }
  }
}




private void prepareExitHandler () {
  Runtime.getRuntime().addShutdownHook(new Thread(new Runnable() {
    public void run () {
      System.out.println("Shutdown hook running");
      List<Strip> strips = registry.getStrips();
      for (Strip strip : strips) {
        for (int i=0; i<strip.getLength(); i++)
        strip.setPixel(#000000, i);
      }
      for (int i=0; i<100000; i++)
      Thread.yield();
    }
  }
  ));
}