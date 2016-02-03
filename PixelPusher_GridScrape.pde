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
int stride = 235; // NEEDS TO BE EXACT PIXEL-PER-STRIP# FROM CONFIG

// Hashmap - this will store all pixel-color combos
HashMap<Integer, Integer> pixelCols = new HashMap<Integer, Integer>();

public void gridSetup() {
  List<Strip> strips = registry.getStrips();
  for (Strip strip : strips) {
    cols = strip.getLength();
    rows = strips.size();
  }
          // Offline mode
          //cols = 235;
          //rows = 20;
  grid = new Cell[cols][rows];
  for (int r = 0; r < rows; r++) {
    for (int c = 0; c < cols; c++) {
      grid[c][r] = new Cell(c*(width/cols), r*(width/cols), width/cols, width/cols, color(0));
    }
  }
}



void setup() {
  // width must be stripLength * 5, height must be numStrips * 5
  size(1175, 10); 
  background(0);

  registry = new DeviceRegistry();
  testObserver = new TestObserver();
  registry.addObserver(testObserver);
  prepareExitHandler();
  oscP5 = new OscP5(this, 5001);

  gridSetup();
}



void draw() {
  for (int r = 0; r < rows; r ++ ) {     
    for (int c = 0; c < cols; c ++ ) {
      grid[c][r].initialize();
    }
  }
  scrape();
}


// OSC protocol
//// Address is usecase flag
//// Arguments: [strip#, pixel, color, pixel, color, pixel...]
public void oscEvent(OscMessage theOscMessage) {  
  int stripNum = theOscMessage.get(0).intValue();
  String addr = theOscMessage.addrPattern();
  ArrayList<Integer> pixelArr = new ArrayList<Integer>();
  ArrayList<Integer> colorArr = new ArrayList<Integer>();

  // Split arguments into pixel and color silos
  for (int i = 1; i < theOscMessage.arguments().length; i++) {
    int val = (Integer) theOscMessage.arguments()[i];
    if (i % 2 != 0) {
      pixelArr.add(val);
    } else {
      colorArr.add(val);
    }
  }

  // Cases for where to go based on address
  //// Options : new, continue, allOn, allOff
  switch(addr) {
  case "/new": 
    pixelCols.clear();
    wholeGrid(false);
    for (int i = 0; i < pixelArr.size(); i++) {
      pixelCols.put(pixelArr.get(i), colorArr.get(i));
    }
    colorGrid(stripNum);
    break;
  case "/continue": 
    for (int i = 0; i < pixelArr.size(); i++) {
      pixelCols.put(pixelArr.get(i), colorArr.get(i));
    }
    colorGrid(stripNum);
    break;
  case "/allOn":
    wholeGrid(true);
    break;
  case "/allOff":
    wholeGrid(false);
    break;
  }
}

// Read hashmap, update grid colors
public void colorGrid(int stripN) {
  for (Map.Entry<Integer, Integer> entry : pixelCols.entrySet()) {
    int pixLoc = entry.getKey();
    int pixCol = entry.getValue();
    grid[pixLoc][stripN].update(pixCol);
    println("pix: " + pixLoc);
    println("col: " + pixCol);
  }
}

// Turn the grid all on or off
public void wholeGrid(boolean state) {
  color status;
  if(state) {
   status = color(100); 
  } else {
   status = color(0); 
  }
  for (int r = 0; r < rows; r++) {
    for (int c = 0; c < cols; c++) {
      grid[c][r].update(status);
    }
  }
}



/*

 Screen Scraper
 
 */
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