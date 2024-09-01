void setup() 
{
  size(1300, 1400);
  PImage img1 = loadImage("4b.jpg");
  PImage img2 = loadImage("Danish_number_plate.jpg");

  image(img1, 0, 0);
  image(img2, img1.width + 30, 0);

  // Convert images to grayscale
  PImage imgG1 = grayscale(img1);
  PImage imgG2 = grayscale(img2);
  
  // Display the grayscale images
  image(imgG1, 0, img1.height + 30);
  image(imgG2, img1.width + 50, img1.height + 50);
  
  int n = 8;
  //int N=2,M=3;
  int gridSize = 2;
  
  float[][] main_array1 = hog(imgG1,gridSize,n);
  println("HOG Of Image 1 Before Normalization:");
  printHOG(main_array1); 
    println();
	
  float[][] main_array2 = hog(imgG2,gridSize,n);
  println("HOG Of Image 2 Before Normalization:");
  printHOG(main_array2); 
    println();
	
	// Normalize HOG 
  normalizeHOG(main_array1);
  normalizeHOG(main_array2);
  
  println("HOG Of Image 1 After Normalization:");
  printHOG(main_array1); 
  println();
  println("HOG Of Image 2 After Normalization:");
  printHOG(main_array2); 
  println();
  
  // Compute cosine similarity between the HOG descriptors
  float Sim = cosineSimilarity(main_array1, main_array2);
  
  // Display the similarity value
  println("The Co-Sine Similarity between the 2 images are: ",Sim);
}
//To print the HOG
void printHOG(float[][] h)
{
  for (int i=0; i<h.length; i++)
  {
    for (int j=0; j<h[0].length; j++)
    print(h[i][j] + " ");
    println();
  }

}

// Sobel filters
float[][] hog(PImage img,int gridSize, int n)
{

  img.loadPixels();
  int numpixcels = gridSize * gridSize;
  
  float[][] main_array = new float[numpixcels][n];
  
  float[][] filter1 = {{-1, 0, 1}, 
                       {-2, 0, 2}, 
                       {-1, 0, 1}};
  float[][] filter2 = {{-1, -2, -1}, 
                       { 0,  0,  0}, 
                       { 1,  2,  1}};
             
  for (int y = 1; y < img.height - 1; y++) 
  {
    for (int x = 1; x < img.width - 1; x++) 
    {
      float f1 = 0, f2 = 0;
    
      for (int ky = -1; ky <= 1; ky++)
      {
        for (int kx = -1; kx <= 1; kx++)   
        {
          int index = (y + ky) * img.width + (x + kx);
          float r = brightness(img.pixels[index]);
          f1 += filter1[ky+1][kx+1] * r;
          f2 += filter2[ky+1][kx+1] * r;
        }
      }
      //print("The value of F1 is :",f1,"\n");
      //print("The value of F2 is :",f2,"\n");
	  
      //Gradient Vector
      float mag = sqrt(f1 * f1 + f2 * f2);
      float theta = 0;
      theta = atan2(f2, f1);
      if (f2 < 0)
      {
        theta += 2 * PI;
      }
      //float[] arr = new float [n];
	  
      int indexarray = int (theta *n / (TWO_PI));// decomposition of vector
	  
      //for(int i =0 ; i<n;i++)
      //print("indexarray is ",indexarray,"\n");
      
      int x_axis = min(gridSize-1, max(0, int((x-1)/(img.width/gridSize))));
      int y_axis = min(gridSize-1, max(0, int((y-1)/(img.height/gridSize))));
      main_array[y_axis*gridSize+x_axis][indexarray] += mag;
    }
  }
  return main_array;
}

// ------------Normalization of HOG descriptor---------------------

void normalizeHOG(float[][] main_array) 
{
  float sum = 0;
  // Compute sum of all elements
  for (int i = 0; i < main_array.length; i++) 
  {
    for (int j = 0; j < main_array[i].length; j++) 
	{
      sum += main_array[i][j] * main_array[i][j] ;
    }
  }
  
  float square = sqrt(sum);//square root of sum
 
  
  // Normalize each element
  for (int i = 0; i < main_array.length; i++) 
  {
    for (int j = 0; j < main_array[i].length; j++) 
	{
      main_array[i][j] /= square;
    }
  }
}

//------------Co Sine Function-----------------------------------
float cosineSimilarity(float[][] main_array1, float[][] main_array2) 
{
  // Initialize variables for dot product and magnitudes
  float dotProduct = 0;
  float mag1 = 0;
  float mag2 = 0;

  // Compute dot product and magnitudes
  for (int i = 0; i < main_array1.length; i++) 
	{
	for (int j = 0; j < main_array1[i].length; j++)
		{
			dotProduct += main_array1[i][j] * main_array2[i][j];
			mag1 += main_array1[i][j] * main_array1[i][j];
			mag2 += main_array2[i][j] * main_array2[i][j];
      //print("Mag1 is :",mag1,"\n");
      //print("Mag2 is :",mag2,"\n");
		}
	}

 

   //Compute cosine similarity
  if (mag1 != 0 && mag2 != 0) 
  {
    //print("Mag1 is :",mag1,"\n");
    //print("Mag2 is :",mag2,"\n");
    return dotProduct / (sqrt(mag1) * sqrt(mag2));
    
  } else 
  {
    return 0; // If one of the magnitudes is equal zero, similarity is zero
  }
}

// --------------------Conversion to grayscale---------------------------
PImage grayscale(PImage img) {
  PImage img_G = createImage(img.width, img.height, RGB);
  img.loadPixels();
  img_G.loadPixels();
  for (int y = 0; y < img.height; y++) {
    for (int x = 0; x < img.width; x++) {
       int index = x + y * img.width;
       float r = red(img.pixels[index]);
       float g = green(img.pixels[index]);
       float b = blue(img.pixels[index]);
       img_G.pixels[index] =  color(0.21 * r + 0.72 * g + 0.07 * b);
    }
  }
  img_G.updatePixels();
  return img_G;
}
