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

  for (int i = 0; i < rows; i++) {
    for (int j = 0; j < cols; j++) {
      grid[j][i] = new Cell(j*(width/cols), i*(width/cols), width/cols, width/cols, #000000);
    }
  }
}




void draw() {
  background(#000000);

  if (testObserver.hasStrips) {
    gridSetup();
    for (int i = 0; i < rows; i ++ ) {     
      for (int j = 0; j < cols; j ++ ) {
        grid[j][i].display();
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
        for (int i = 0; i < rows; i ++ ) {     
          for (int j = 0; j < cols; j ++ ) {
            strip.setPixel(grid[j][i].col, stripx);
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