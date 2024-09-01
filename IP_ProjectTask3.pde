void setup() {
  size(1300, 1400);
  PImage imgA = loadImage("4b.jpg");
  //imgA.resize(50,0);
  PImage imgB = loadImage("Danish_number_plate.jpg");

  image(imgA, 0, 0);
  image(imgB, imgA.width + 50, 0);

  // Convert images to grayscale
  PImage imgG1 = grayscale(imgA);
  PImage imgG2 = grayscale(imgB);
  
  image(imgG1, 0, imgA.height+30);
  
  int n = 8;
  int N = 3, M = 2;
  
  float[][] main_array1 = hog(imgG1,M,N,n);
  println("HOG Of Image 1 Before Normalization:");
  printHOG(main_array1); 
  println();

  float[][] main_array2 = hog(imgG2,M,N,n);
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

   //Compute cosine similarity between the HOG descriptors
  float Sim = cosineSimilarity(main_array1, main_array2);
  //println("The Co-Sine Similarity between the 2 images are: ", Sim);
  


  // Detect objects using sliding window technique
   
   PImage results = object_detection(imgG1,imgG2,
                    n,M,N,//chain code direction and grid dimensions
                    80,110,//window dimension
                    16,16,//window steps
                    0.85);//threshoid value

    image (results, imgA.width + 50, imgB.height + 30) ;

}

//To print the HOG
void printHOG(float[][] h) {
  for (int i = 0; i < h.length; i++) {
    for (int j = 0; j < h[0].length; j++)
      print(h[i][j] + " ");
    println();
  }
}
//--------------------------------- OBJECT DETECTION ------------------------------------------
PImage object_detection(PImage img1, PImage img2, int n, int M, int N, 
                        int windowWidth, int windowHeight, int stepX, int stepY, 
                        float threshold) 
{
        
    float[][] hogFeatures1 = hog(img1, M,N,n);

    // Create a copy of img2 to draw detection results on
   PImage results = img2.copy();

    // Iterate through img2 with sliding window
    for (int y = 0; y <= img2.height - windowHeight; y += stepY) 
	{
        for (int x = 0; x <= img2.width - windowWidth; x += stepX) 
		{
            // Extract window from img2
            PImage window = img2.get(x, y, windowWidth, windowHeight);
            
            float[][] hogFeaturesWindow = hog(window, M,N,n);

            
            float similarity = cosineSimilarity(hogFeatures1, hogFeaturesWindow);
            //println("The Co-Sine Similarity between the 2 images are: ", similarity);


            // If similarity exceeds threshold, consider it a detection
            if (similarity >= threshold) 
			{
				results = drawRectangle(results, x, y, windowWidth, windowHeight);    
          println("The Co-Sine Similarity between the 2 images are: ", similarity);      
          //image (window, img1.width, img1.height+600) ;
          
            }
        }
    }

    return results;
}

PImage drawRectangle(PImage img, int x, int y, int windowWidth, int windowHeight) 
{
	img.loadPixels();
	// Draw top and bottom borders
	for (int i = x; i < x + windowWidth; i++) 
	{
		img.pixels[y * img.width + i] = color(0); // Top
		img.pixels[(y + windowHeight) * img.width + i] = color(0); // Bottom
	}
	// Draw left and right borders
	for (int i = y; i < y + windowHeight; i++) 
	{
		img.pixels[i * img.width + x] = color(0); // Left
		img.pixels[i * img.width + (x + windowWidth)] = color(0); // Right
	}
	
	img.updatePixels();
	return img;
}


//------------------- HOG ----------------------------

float[][] hog(PImage img,int M,int N, int n)
{

  img.loadPixels();
  int numpixcels = M * N;
  
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
         
         //int x_axis = min(gridSize-1, max(0, int((x-1)/(img.width/M))));
         //int y_axis = min(gridSize-1, max(0, int((y-1)/(img.height/N))));
         
          int x_axis = min(M-1, max(0, int((x-1)/(img.width/M))));
          int y_axis = min(N-1, max(0, int((y-1)/(img.height/N))));
            main_array[y_axis*M+x_axis][indexarray] += mag;
       }
    }
	
	return main_array;
}


// ------------Normalization of HOG ---------------------
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
		}
	}
	
	//Compute cosine similarity
	if (mag1 != 0 && mag2 != 0)
	{
		return dotProduct / (sqrt(mag1) * sqrt(mag2));
	} else 
	{
		return 0; // If one of the magnitudes is equal zero, similarity is zero
	}
}

// --------------------Conversion to grayscale---------------------------
PImage grayscale(PImage img)
{
  PImage img_G = createImage(img.width, img.height, RGB);
  img.loadPixels();
  img_G.loadPixels();
  for (int y = 0; y < img.height; y++) 
  {
		for (int x = 0; x < img.width; x++) 
		{
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
