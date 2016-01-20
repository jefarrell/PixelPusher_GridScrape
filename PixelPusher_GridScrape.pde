import oscP5.*;
import netP5.*;
import com.heroicrobot.dropbit.registry.*;
import com.heroicrobot.dropbit.devices.pixelpusher.Pixel;
import com.heroicrobot.dropbit.devices.pixelpusher.Strip;
import java.util.*;

TestObserver testObserver;
DeviceRegistry registry;
Cell[][] grid;

OscP5 oscP5;  // send messages 
NetAddress myRemoteLocation;  // where we send to


int rows;
int cols;



void setup() {
  size(1280, 480);

  registry = new DeviceRegistry();
  testObserver = new TestObserver();
  registry.addObserver(testObserver);
  prepareExitHandler();
}


public void gridSetup() {

  List<Strip> strips = registry.getStrips();
  for (Strip strip : strips) {
    cols = strip.getLength();
    rows = strips.size();
  }
  //cols = 100;
  //rows = 3;
  // println("====================================");
  //println(width/cols + ", " + height/rows);
  
  color gridfill = color(125);
  grid = new Cell[cols][rows];

  for (int i = 0; i < rows; i++) {
    for (int j = 0; j < cols; j++) {
      grid[j][i] = new Cell(j*(width/cols), i*(width/cols), width/cols, width/cols, gridfill);
    }
  }
}




void draw() {
  background(0);
  
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
    
    registry.startPushing();
    List<Strip> strips = registry.getStrips();
    int numStrips = strips.size();
    for (Strip strip : strips) {
      int xscale = width/numStrips;
      for (int stripx = 0; stripx < strip.getLength(); stripx++) {
        strip.setPixel(125, stripx);
      }
    }
  }
}






public void oscEvent(OscMessage theOscMessage) {
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