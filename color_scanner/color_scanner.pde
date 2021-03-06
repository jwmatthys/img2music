import oscP5.*;
import netP5.*;

final int numBands = 4;
float hueBand[];
float satBand[];
float valBand[];
PImage img;
int x = 0;
int bandwidth;

OscP5 oscP5;
NetAddress myRemoteLocation;

void setup()
{
  oscP5 = new OscP5(this, 12000); // listen at 12000
  myRemoteLocation = new NetAddress("127.0.0.1", 53186);
  size(150, 150);
  img = loadImage("13.jpg");
  frameRate(1);
  colorMode(HSB, 360);
  image(img, 0, 0, width, height);
  double brsum = 0;
  for (int i=0; i<width; i++)
  {
    color c = get(i, height/2);
    brsum += brightness(c)/255.0;
  }
  OscMessage myMessage;
  myMessage = new OscMessage("/torch");
  myMessage.add(99);
  myMessage.add(0.0);    
  myMessage.add(0.0);  
  myMessage.add(brsum/width);    
  oscP5.send(myMessage, myRemoteLocation);

  hueBand = new float[numBands];
  satBand = new float[numBands];
  valBand = new float[numBands];
  bandwidth = height / numBands;
}

void draw()
{
  int x = frameCount;
  if (x >= width)
  {
    OscMessage myMessage;
    myMessage = new OscMessage("/torch");
    myMessage.add(-1);    
    myMessage.add(0.0);    
    myMessage.add(0.0);    
    myMessage.add(0.0);  
    oscP5.send(myMessage, myRemoteLocation);
    exit();
  } else {
    int y = 0;
    float allHues[] = new float[height];
    float tempHues[] = new float[bandwidth];
    OscMessage myMessage;
    float allHue = 0;
    float allSat = 0;
    float allVal = 0;
    for (int band = 0; band < numBands; band++)
    {
      float tempSat = 0;
      float tempVal = 0;
      for (int i = 0; i < tempHues.length; i++)
      {
        color c = get(x, y);
        tempHues[i] = hue(c);
        allHues[y] = hue(c);
        tempSat += saturation(c);
        tempVal += brightness(c);
        allSat += saturation(c);
        allVal += brightness(c);
        y++;
      }
      hueBand[band] = getAverageBearing(tempHues);
      satBand[band] = tempSat / tempHues.length;
      valBand[band] = tempVal / tempHues.length;
      myMessage = new OscMessage("/torch");
      myMessage.add(band+1);
      myMessage.add(hueBand[band]/360);
      myMessage.add(satBand[band]/360);
      myMessage.add(valBand[band]/360);
      oscP5.send(myMessage, myRemoteLocation);
    }

    allHue = getAverageBearing(allHues);
    allSat /= y;
    allVal /= y;
    myMessage = new OscMessage("/torch");
    myMessage.add(0);
    myMessage.add(allHue/360);
    myMessage.add(allSat/360);
    myMessage.add(allVal/360);
    oscP5.send(myMessage, myRemoteLocation);

    for (int i = 0; i < numBands; i++)
    {
      //println("band "+i+": "+hueBand[i]+", "+satBand[i]+", "+valBand[i]);
      stroke(hueBand[i], satBand[i], valBand[i]);
      line(x, bandwidth*i, x, bandwidth*(i+1));
    }
  }
}

public static float getAverageBearing(float[] arr)
{
  double sunSin = 0;
  double sunCos = 0;
  int counter = 0;

  for (double bearing : arr)
  {
    bearing *= Math.PI/180;

    sunSin += Math.sin(bearing);
    sunCos += Math.cos(bearing);
    counter++;
  }

  float avBearing = 0;
  if (counter > 0)
  {
    double bearingInRad = Math.atan2(sunSin/counter, sunCos/counter);
    avBearing = (float) (bearingInRad*180f/Math.PI);
    if (avBearing<0)
      avBearing += 360;
  }

  return avBearing;
}
