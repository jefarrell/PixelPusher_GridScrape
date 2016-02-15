##PixelPusher_GridScrape

___

Application to light specific pixels on LED strips using the Heroic Robotics [PixelPusher](www.heroicrobotics.com/products/pixelpusher).  
___
####Basic Structure
>Program draws grid based on number of strips and pixels per strip, based on numbers defined in pixel.rc configuration file.  Program takes OSC message containing strip and pixel information.  Corresponding cells are turned to desired color.  Grid is then scraped for color, which is sent to PixelPusher.


####Necessary Setup
Processing v3 does not allow for variables in size(), so the sketch won't exactly auto-configure.  There are 3 variables that must be manually set, all in PixelPusher_GridScrape.pde - these should all match what is written in the pixel.rc file

**int stride** on line 17 must be set to the Pixels Per Strip number

**size width** on line 43 must be stripLength

**size height** on line 43 must be numStrips

I multiplity height and width by 5 to get a visible grid that will fit on the screen - this number can be adjusted depending on your number of strips and pixels per strip.

___
####OSC Protocol
Processing sketch is built to receive messages via OSC.  
>OSC messages should be addressed with either "/pixels", "allOn", "allOff", or "/end"
>
>The program will take as many messages as it needs at "/pixels", but then must receive a message at "/end" to light the grid
>
>**/pixels** is for any message containing a array of strip number, pixels and colors (see below).  Multiple can be sent before an "/end" message
>
>**/allOn** means turn entire grid on
>
>**/allOff** means... turn entire grid off
>
>**/end** must be sent at the end of a OSC sequence.  This will color the grid, and light physical pixels
>
>Argument structure of OSC messages should be [strip number, pixel, color, pixel, color... etc]
>
>For example, [1,20,255,21,255,22,255,23,255,24,255]



