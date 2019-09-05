<h1 align="center">
  <img src="img/bh19-logo.png" ><br/> BH2019-Fukuoka 
</h1>

## Metadata annotation for image data using machine learning 
Member : Satoshi Kume, Norio Kobayashi, Hiroshi Masuya

Description : <br/>
- To discuss the metadata description (phenotypes/morphology) for ROI &/or masked region.
- To try the development of the supporting system of metadata annotation for the insight view of images using the machine learning.
-  To consider an effective  amplification of training data from a few dataset.


## Computation environment
Machine
- PC : HPCT W111ga
- CPU : Intel Skylake CPU W-2123 (3.60 GHz, 4Core)
- GPU : NVIDIA TITAN RTX (GDDR6 24GB) x 2
- Memory : 128 GB 

OS / Software
- OS : CentOS Linux 7.6.1810
- NVIDIA Driver : 418.67 / gcc : 4.8.5
- CUDA : V9.0.176
- Rstudio (R version 3.6.0), R-Keras 2.2.4, R-TensorFlow 1.11.0 (Backend)

## Metadata Concept
<img src="img/ClassRelation.png" >

## Process for image segmentaiton
1. Image dataset
    1. Mouse B6J kidney electron microscopy images
    	1. [Nucleus](https://github.com/kumeS/BH2019-Fukuoka/tree/master/01_ImageDataset/01_Mouse_B6J_Kidney_Nucleus_All_ver190903)
    	2. Mitochondria
    2. Croped images around 1000 x 1000 px<br/>
<img src="img/GT01.png" > <br/>
2. Pre-processing
    1. Resize for images: 512 x 512 px /  1024 x 1024 px 
    2. Normalization
    3. Clahe (Contrast Limited Adaptive Histogram Equalization)
    4. Gamma Correct (this is not so important)
    5. Training image amplification : This step was skipped in BH19 due to time consuming.
    	1. Rotation : 0, 90, 180, 270 degree
    	2. Flip : Y/N
    	3. Horizontal translation : 1/8-7/8 tick
    	4. Vertical translation : 1/8-7/8 tick
    6. RandomSequence of images
		```R 
		library(random)
		Ran <- c(random::randomSequence(min=1, max=length(XYG$X), col=1))
		```
    7. list2tensor
		```R 
		list2tensor <- function(xList) {
		xTensor <- simplify2array(xList)
		aperm(xTensor, c(4, 1, 2, 3)) }
		```  
3. Deep learning model 
	1.  Evaluation metrics
		1. IoU (Intersection-Over-Union)
		```R
		iou <- function(y_true, y_pred, smooth = 1.0){
		y_true_f <- k_flatten(y_true)
		y_pred_f <- k_flatten(y_pred)
		intersection <- k_sum( y_true_f * y_pred_f)
		union <- k_sum( y_true_f + y_pred_f ) - intersection
		result <- (intersection + smooth) / ( union + smooth)
		return(result)}
		```
		2. Dice Coefficient (F1 score)<br/>
		```R
		dice_coef <- function(y_true, y_pred, smooth = 1.0) {
		y_true_f <- k_flatten(y_true)
		y_pred_f <- k_flatten(y_pred)
		intersection <- k_sum(y_true_f * y_pred_f)
		result <- (2 * intersection + smooth) / 
		(k_sum(y_true_f) + k_sum(y_pred_f) + smooth)
		return(result)}
		```
		[metrics in detail](https://towardsdatascience.com/metrics-to-evaluate-your-semantic-segmentation-model-6bcb99639aa2)
		3. Model
			1. U-NET : [Olaf Ronneberger et al, U-Net: Convolutional Networks for Biomedical Image Segmentation](https://arxiv.org/abs/1505.04597)
4. Calculation
	1. Result 1 : Failed
	2. Result 2
5. Evaluation and modification cycle of results
	1. ideas from 
		1. [Morphological Snakes GitHub : Morphological snakes for image segmentation and tracking](https://github.com/pmneila/morphsnakes)
		2. [Microscopy Image Browser: A Platform for Segmentation and Analysis of Multidimensional Datasets](https://journals.plos.org/plosbiology/article/figure?id=10.1371/journal.pbio.1002340.g001)
		3. [Microscopy Image Browser Watershed/Graphcut segmentation](http://mib.helsinki.fi/help/main2/ug_gui_menu_tools_watershed.html)
6. Particle shape
	1. [BioVoxxel/ImageJ](https://imagej.net/BioVoxxel_Toolbox), others<br/>
		<img src="https://imagej.net/File:ExtendedParticleAnalyzer_v2.png" alt="" width="" height="" border="0" /><br/>
		
