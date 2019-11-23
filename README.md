# Introduction

  This matlab code aims to percieve the depth of an image and blur the object that it detects as the background .<br/>
  This program uses only **single image as input** unlike other smartphone algos and works on clustering and equation optimzation methods rather than Neural Networks.<br/>
  this is an implementation of an idea of another person's research paper<br/>
  https://ieeexplore.ieee.org/document/6909756  - contains the weighting method<br/>
  https://ieeexplore.ieee.org/document/8103371  - contains a better method for blurring along with weighting<br/>
  
  
  ## Step 1 : Conversion to LAB Colorspace and clustering
  
  Let's Take an input image:<br/>
  <img src="https://github.com/Manjunatha-b/Portrait-Mode/blob/master/ReadmeFiles/prof4.jpg" width="400">
  
  The input image is converted to LAB space and clustered with inbuilt matlab function for further processing.<br/>
  Representation of the clustered picture:
  
  <img src="https://github.com/Manjunatha-b/Portrait-Mode/blob/master/ReadmeFiles/untitled.jpg" width="400">
  
  ## Step 2 : Calculation of weights 
  
  w_bgr represents the probability of each superpixel belonging to the background , whiter the superpixel , more is the chance of it belonging to the background.<br/>
  This uses a connected graph method to compute the probabilities. First an adjacency matrix was constructed and a weighted graph was created from this.<br/><br/>
  <img src="https://github.com/Manjunatha-b/Portrait-Mode/blob/master/ReadmeFiles/adjacency%20matrix.PNG" width="300"> <img src="https://github.com/Manjunatha-b/Portrait-Mode/blob/master/ReadmeFiles/graphra.jpg" width="500"><br/>
  The constructed graph was then used in determining the w_bgr values . the computation involves finding shortest distance between two superpixels as well, which is again taken care of by an inbuilt matlab function.<br/>
  Representation of w_bgr:<br/>
  <img src="https://github.com/Manjunatha-b/Portrait-Mode/blob/master/ReadmeFiles/w_bgr.jpg" width="400"><br/>
  
  w_Ctr represents the probability of each superpixel belonging to the foreground , whiter the superpixel , more is the chance of it belonging to the foreground.
  This is constructed from a combination of the produced background weights and a superpixel contrast map (in colorspace).<br/>
  Representation of w_Ctr:<br/>
  <img src="https://github.com/Manjunatha-b/Portrait-Mode/blob/master/ReadmeFiles/w_Ctr.jpg" width="400"><br/><br/>
  
  w_smooth is used in the optimzation equation to promote smoother gradient of superpixels, rather than abrupt changes.This is again dependant on colorspace distance between to superpixels.<br/>
  
  ## Step 3 : Gradient Descent optimization
  
  Saliency basically means the importance of a pixel (lies b/w 0-1), closer it is to 1 , the higher is its chance of belonging to the foreground.<br/>
  The optimized output is produced by the minimization of an eqn with w_bgr , w_Ctr & w_smooth as constants and saliency as the variable parameter.<br/><br/>
  I have implemented this optimization by deploying s as a set of random numbers b/w [0 1]. Then I computed the error (Gradient here) of the equation with respect to saliency of the ith superpixel.<br/><br/>
  this gradient was subtracted from the I'th superpixel's value after being multiplied with a learning rate 'alpha'.<br/><br/>
  The same process was repeated for all superpixels in one iteration. <br/><br/>
  500 such iterations resulted in a very optimized solution<br/><br/>
  Representation of optimized saliency : <br/><br/>
  
  <img src="https://github.com/Manjunatha-b/Portrait-Mode/blob/master/ReadmeFiles/opti.jpg" width="400"><br/>
  
  ## Step 4 : Blurring based on saliency map
  
  we can see our saliency map is basically a depth map at this point <br/>
  **the optimal way would be to blur the superpixels based on their saliency values i.e: <br/><br/>
   <t/> if saliency closer to 0 , blur the portion harder <br/>
   <t/> if saliency closer to 1 , sharpen the portion more <br/>
   <t/> if saliency is around 0.5 , the portion can be left as is<br/>
   <br/>**
   
   due to lack of time to finish the project we implemented a cheap threshold on the depth map and produced a mask : <br/>
   
   <img src="https://github.com/Manjunatha-b/Portrait-Mode/blob/master/ReadmeFiles/threshed.jpg" width="400"><br/>
   
   the portion in white was sharpened and black was blurred and added to produce the final image : <br/>
   
   <img src="https://github.com/Manjunatha-b/Portrait-Mode/blob/master/ReadmeFiles/final.jpg" width="400"><br/>
   
   
