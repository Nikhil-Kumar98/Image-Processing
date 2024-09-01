# Image-Processing

Task specification:
In this task, you should write and submit an object detection program based on the histogram of oriented gradients that reads object represented in imageA and detects its occurrences in imageB. 
This program should meet the following requirements:

Task 1: It performs adaptive binarization and cropping of an input image.

Task 2: It computes a histogram of oriented gradients for a given image. The input parameters are: grayscale image, number of chaincode directions, and grid dimension. Then, it estimates the similarity between two input images by calculating the cosine similarity between their histograms of oriented gradients.

Task 3: It reads an object represented in imageA and detects its occurrences in imageB, by applyling the sliding window technique. The input parameters are: two grayscale images, number of chaincode directions, grid dimension, sliding window dimension, sliding window steps along the x- and y-axis, etc.
