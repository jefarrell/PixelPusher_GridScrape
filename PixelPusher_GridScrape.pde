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
int stride = 235; // NEEDS TO BE EXACT PIXEL# FROM CONFIG



public void gridSetup() {
  List<Strip> strips = registry.getStrips();
  for (Strip strip : strips) {
    cols = strip.getLength();
    rows = strips.size();
  }

  /* //Offline mode
   cols = 235;
   rows = 20;
   */
  grid = new Cell[cols][rows];
  for (int r = 0; r < rows; r++) {
    for (int c = 0; c < cols; c++) {
      grid[c][r] = new Cell(c*(width/cols), r*(width/cols), width/cols, width/cols, color(0));
      grid[c][r].initialize();
    }
  }
}




void setup() {
  // setting exactly to pixelnum*5  -> SEEMS IMPORTANT
  size(1175, 10); 
  //size(1280, 480);
  background(0);
  registry = new DeviceRegistry();
  testObserver = new TestObserver();
  registry.addObserver(testObserver);
  prepareExitHandler();

  oscP5 = new OscP5(this, 5001);
  myRemoteLocation = new NetAddress("127.0.0.1", 5001);
  gridSetup();  // Initial grid
}






void draw() {
  if (testObserver.hasStrips) {

    // this should just scrape the color from the displayed grid // ACTUALLY NOT ANYMORE
    // will set the colors initially with display() then again with update() on OSC event
    registry.startPushing();
    List<Strip> strips = registry.getStrips();
    int numStrips = strips.size();
    for (Strip strip : strips) {
      for (int stripx = 0; stripx < strip.getLength(); stripx++) {
        for (int r = 0; r < rows; r ++ ) {     
          for (int c = 0; c < cols; c ++ ) {
            color cellCol = color(grid[c][r].col);
            fill(255);
            continue;  // WHY DO I NEED THIS?!
            //strip.setPixel(color(cellCol), stripx);
          }
        }
      }
    }
  }
  scrape();
}


// Need to establish OSC protocol (strip,pixls,cols), set matching grid squares
public void oscEvent(OscMessage theOscMessage) {

  int stripn = theOscMessage.get(0).intValue();
  List<Integer> pixelArr = new ArrayList<Integer>();

  for (int i = 0; i < theOscMessage.arguments().length; i++) {
    int n = (Integer) theOscMessage.arguments()[i];
    pixelArr.add(n);
  }

  println("////////////////////////////////////");
  println(pixelArr);
  println("////////////////////////////////////");


  if (testObserver.hasStrips) {
    Iterator<Integer> pixItr = pixelArr.iterator(); 
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        while (pixItr.hasNext()) { 
          grid[pixItr.next()][stripn].update(color(255));
        }
      }
    }
  }
}


boolean first_scrape = true;

void scrape() {
  // scrape for the strips
  loadPixels();
  if (testObserver.hasStrips) {
    registry.startPushing();
    List<Strip> strips = registry.getStrips();
    boolean phase = false;
    // for every strip:
    int currenty = 0;
    int stripy = 0;
    for (Strip strip : strips) {
      int strides_per_strip = strip.getLength() / stride;

      int xscale = width / stride;
      int yscale = height / (strides_per_strip * strips.size());

      // for every pixel in the physical strip
      for (int stripx = 0; stripx < strip.getLength(); stripx++) {
        int xpixel = stripx % stride;
        int stridenumber = stripx / stride; 
        int xpos, ypos; 

        if ((stridenumber & 1) == 0) { // we are going left to right
          xpos = xpixel * xscale; 
          ypos = ((stripy*strides_per_strip) + stridenumber) * yscale;
        } else { // we are going right to left
          xpos = ((stride - 1)-xpixel) * xscale;
          ypos = ((stripy*strides_per_strip) + stridenumber) * yscale;
        }

        color c = 0;
        c=get(xpos+1, ypos+1);  
        strip.setPixel(c, stripx);
      }
      stripy++;
    }
  }
  updatePixels();
}











////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////

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