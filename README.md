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
    1. Resize for images: 128 px, 256 px, 512 px squares (We do not know which the better)
    2. Normalization
    3. Clahe (Contrast Limited Adaptive Histogram Equalization)
    4. Gamma Correct (this is not so important)
    5. Training image amplification --- 113-folds
    	1. Rotation : 0, 90, 180, 270 degree
    	2. Flip : Y/N
    	3. Horizontal translation : 1/8-7/8 tick
    	4. Vertical translation : 1/8-7/8 tick
    6. RandomSequence of images (I is still not sure)
    7. list2tensor
3. Deep learning model 
	1.  Evaluation metrics
		1. IoU (Intersection-Over-Union)
		2. Dise coefficient (F1 score)<br/>
		[metrics in detail](https://towardsdatascience.com/metrics-to-evaluate-your-semantic-segmentation-model-6bcb99639aa2)
		 


