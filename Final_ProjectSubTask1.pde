void setup() 
{
  size(1300, 1400);
  PImage img = loadImage("NumberPlateB.jpg");
  print("The Image Height is : ",img.height,"\n");
  print("The Image Width is  : ",img.width,"\n");
  image(img, 0, 0);
  //  grayscale
  PImage img2 = grayscale(img);
  image(img2, img.width+30, 0);
  
  //  adaptive thresholding
  int epsilon = 5;  // we can adjust this value based on your needs
  
  float adaptiveThreshold = calculateAdaptiveThreshold(img2, epsilon);
  print("The Adaptive Threshold is :",adaptiveThreshold);
  
  // binarization using the adaptive threshold
  PImage img3 = binarization(img2,adaptiveThreshold);
  image(img3, 0, img.height+30);
  
  //Cropping
  PImage img4 = cropping(img3);
  image(img4,img.width+50, img.height+50);
}

// Conversion to grayscale
PImage grayscale(PImage img) 
{

  PImage img_G = createImage(img.width, img.height, RGB);
  img.loadPixels();
  img_G.loadPixels();
  for (int y = 0; y < img.height; y++)//ittrates the coloumns
    for (int x = 0; x < img.width; x++)//ittrates the  rows
    {
       int index = x + y * img.width;
    
    //Colour Extraction
      float r = red(img.pixels[index]);//red compenents of pixcels extracted
      float g = green(img.pixels[index]);//green compenents of pixcels extracted
      float b = blue(img.pixels[index]);//blue compenents of pixcels extracted  
    img_G.pixels[index] =  color(0.21 * r + 0.72 * g + 0.07 * b);// grayscale conversion using luminosity method
    }
    
  img_G.updatePixels();
  return img_G;
}

float calculateAverageIntensity(PImage img) 
{
  img.loadPixels(); // Make sure pixels are loaded
  
  float totalIntensity = 0; // Initialize total intensity sum
  
  // Iterate through each pixel in the image
  for (int i = 0; i < img.pixels.length; i++) 
  {
    // Get the brightness of the current pixel
    float brightnessValue = brightness(img.pixels[i]);
    
    // Add the brightness to the total intensity sum
    totalIntensity += brightnessValue;
  }
  
  // Calculate the average intensity by dividing the total sum by the number of pixels
  float averageIntensity = totalIntensity / img.pixels.length;
  
  return averageIntensity;
}



// Adaptive Thershold
float calculateAdaptiveThreshold(PImage img, float epsilon)
{
  float Ti = calculateAverageIntensity(img);  // Initial threshold
  print("Average Intensity is ", Ti, "\n");
  boolean done = false;
  int no_of_iteration = 0;

  img.loadPixels();
  
  do {
    float group1 = 0, group2 = 0;
    int count1 = 0, count2 = 0;

    // Classify each pixel in the image
    for (int i = 0; i < img.pixels.length; i++) {
      float val = brightness(img.pixels[i]);
      if (val < Ti) {
        group1 += val;
        count1++;
      } else {
        group2 += val;
        count2++;
      }
    }

    // Calculate the average value for each group
    float avg1 = count1 > 0 ? group1 / count1 : 0;
    float avg2 = count2 > 0 ? group2 / count2 : 0;

    // Calculate the new threshold
    float Tnew = (avg1 + avg2) / 2;

    // Check if the absolute difference between the old and new thresholds is less than epsilon
    
    if ((Ti - Tnew) <= epsilon) 
    {
      done = true;
    } else 
    {
      Ti = Tnew;  // Update the threshold for the next iteration
      no_of_iteration++;//just for understanding purpose
    }
  } while (!done);
  print("No of times the New Thershold was calculated - ", no_of_iteration, "\n");
  return Ti;
}


//Image binarization using the adaptive threshold value
PImage binarization(PImage img, float thresholdvalue) 
{
  PImage img_B = createImage(img.width, img.height, RGB);
  img.loadPixels();
  img_B.loadPixels();
  for(int y = 0; y < img.height; y++)
    for (int x = 0; x < img.width; x++)
    {
      int index = y * img.width + x;
      float r = brightness(img.pixels[index]);
      if (r <= thresholdvalue)
        img_B.pixels[index] = color(0);
      else
        img_B.pixels[index] = color(255);
        
    }
  img_B.updatePixels();
  return img_B;
  
}


PImage cropping(PImage img) {
  img.loadPixels(); 
  boolean found = false;
  int y = 0;
  
  // Find top boundary
  for (y = 0; (y < img.height && !found); y++) {
    for (int x = 0; (x < img.width && !found); x++) {
      int index = y * img.width + x;
      float r = brightness(img.pixels[index]);
      if (r == 0)
        found = true;
    }
  }
  int topBoundary = y;
  
  found = false;
  // Find bottom boundary
  int bottomBoundary = 0;
  for (y = img.height - 1; (y >= 0 && !found); y--) {
    for (int x = 0; (x < img.width && !found); x++) {
      int index = y * img.width + x;
      float r = brightness(img.pixels[index]);
      if (r == 0)
        found = true;
    }
  }
  bottomBoundary = y;
  
  found = false;
  int x = 0;
  
  // Find left boundary
  for (x = 0; (x < img.width && !found); x++) {
    for (int y1 = topBoundary; (y1 <= bottomBoundary && !found); y1++) {
      int index = y1 * img.width + x;
      float r = brightness(img.pixels[index]);
      if (r == 0)
        found = true;
    }
  }
  int leftBoundary = x;
  
  found = false;
  // Find right boundary
  int rightBoundary = 0;
  for (x = img.width - 1; (x >= 0 && !found); x--) {
    for (int y1 = topBoundary; (y1 <= bottomBoundary && !found); y1++) {
      int index = y1 * img.width + x;
      float r = brightness(img.pixels[index]);
      if (r == 0)
        found = true;
    }
  }
  rightBoundary = x;
  
  // Crop the image
  return img.get(leftBoundary, topBoundary, rightBoundary - leftBoundary + 1, bottomBoundary - topBoundary + 1);
}
