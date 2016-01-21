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
int stride = 235;


void setup() {
  // setting exactly to pixelnum*5
  // size(1175, 10);
  size(1280, 480);
  background(0);
  registry = new DeviceRegistry();
  testObserver = new TestObserver();
  registry.addObserver(testObserver);
  prepareExitHandler();

  oscP5 = new OscP5(this, 5001);
  myRemoteLocation = new NetAddress("127.0.0.1", 5001);
  gridSetup();
}


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




void draw() {
  if (testObserver.hasStrips) {


    /* // TESTINGGGG 
     for (int r = 0; r < rows; r ++ ) {     
     for (int c = 0; c < cols; c ++ ) {
     fill(255);
     textSize(75);
     text(grid[3][0].col, 50, 300);
     }
     } */



    // this should just scrape the color from the displayed grid
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
            text(cellCol, 50, 300);
            //strip.setPixel(color(cellCol), stripx);
          }
        }
      }
    }
  }
  scrape();
}


// Need to establish OSC protocol
// Strip, pixels, colors
// Set grid squares to matching numbers
public void oscEvent(OscMessage theOscMessage) {
  println("////////////////////////////////////");
  println("////////////////////////////////////");

  int stripn = theOscMessage.get(0).intValue();
  List<Integer> pixelArr = new ArrayList<Integer>();

  for (int i = 0; i < theOscMessage.arguments().length; i++) {
    int n = (Integer) theOscMessage.arguments()[i];
    pixelArr.add(n);
  }
  println(pixelArr);

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



color weighted_get(int xpos, int ypos, int radius) {
  int red, green, blue;
  int xoffset, yoffset;
  int pixels_counted;

  color thispixel;


  red = green = blue = pixels_counted = 0;

  for (xoffset=-radius; xoffset<radius; xoffset++) {
    for (yoffset=-radius; yoffset<radius; yoffset++) {

      pixels_counted ++;
      thispixel = get(xpos + xoffset, ypos + yoffset);
      red += red(thispixel);
      green += green(thispixel);
      blue += blue(thispixel);
    }
  }
  return color(red/pixels_counted, green/pixels_counted, blue/pixels_counted);
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
       for(Strip strip : strips) {
         int strides_per_strip = strip.getLength() / stride;

         int xscale = width / stride;
         int yscale = height / (strides_per_strip * strips.size());
         
         // for every pixel in the physical strip
         for (int stripx = 0; stripx < strip.getLength(); stripx++) {
             int xpixel = stripx % stride;
             int stridenumber = stripx / stride; 
             int xpos,ypos; 
             
             if ((stridenumber & 1) == 0) { // we are going left to right
               xpos = xpixel * xscale; 
               ypos = ((stripy*strides_per_strip) + stridenumber) * yscale;
            } else { // we are going right to left
               xpos = ((stride - 1)-xpixel) * xscale;
               ypos = ((stripy*strides_per_strip) + stridenumber) * yscale;               
            }
            
             color c = 0;
             c=get(xpos+1,ypos+1);  
             strip.setPixel(c, stripx);
            
          }
         stripy++;
       }
  }
}