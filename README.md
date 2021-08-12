# cellDisplacement_DZNE
scripts for assessment of neuronal and glial pathologies

Based on methods chapter: Wagner, Völkner, Schmied & Karl [in preparation].

## Scripts & accepted datasets

Included in the package are the scripts for the workflow as well as test files.  


### cell-remodeling_nuclear-marker.ijm 

Tissue ROI – aligned crop from a larger field of view 
<ul>
<li>Single channel</li>  
<li>Stack</li> 
<li>TIFF</li> 
</ul>
Test files: *nuclear-marker*

Detects in 3D the position of nuclei using a nuclear marker. 
Visualizes the location of the nuclei in 2D. 

### cell-remodeling_cytoplasmic-marker.ijm 

Tissue ROI – aligned crop from a larger field of view 
<ul>
<li>Dual channel</li>
<li>Stack</li> 
<li>TIFF</li>
</ul>
Test files: *cytoplasmic-marker* 

Performs an intensity based segmentation based on a cytoplasmatic marker. 
Gives a location of each pixel that is above the threshold.

## Dependencies

Fiji - https://fiji.sc/ 

Schindelin, J., Arganda-Carreras, I., Frise, E., Kaynig, V., Longair, M., Pietzsch, T., … Cardona, A. (2012). Fiji: an open-source platform for biological-image analysis. Nature Methods, 9(7), 676–682. doi:10.1038/nmeth.2019 

The script *cell-remodeling_nuclear-marker.ijm* needs the following update sites: 

3D ImageJ Suite: http://sites.imagej.net/Tboudier/ 
Wiki: https://imagej.net/plugins/3d-imagej-suite/ 

J. Ollion, J. Cochennec, F. Loll, C. Escudé, T. Boudier. (2013) TANGO: A Generic Tool for High-throughput 3D Image Analysis for Studying Nuclear Organization. Bioinformatics 2013 Jul 15;29(14):1840-1. 

**Fiji > Help > Update** 

The ImageJ Updater window will pop up. Click Manage update sites and activate the 3D ImageJ Suite update site (3D ImageJ Suite: http://sites.imagej.net/Tboudier/ ) by making a tick mark next to it. Click Close and proceed with update by pressing Apply changes in the ImageJ Updater window and finally restart Fiji.  

## Workflow execution

Drag & Drop scripts into the Fiji toolbar. The scripts will be loaded into the Macro editor. Press **Run** for starting the script.  

### Analyze Nuclear Marker 

Load *cell-remodeling_nuclear-marker.ijm* 

**Input directory:** Folder that contains the input file(s). 
**Output directory:** were to save the result files. 
**File suffix:** specify the suffix of the input files. 
**Detection radius xy:** filter size in xy for the 3D Median filter. 
**Detection radius z:** filter size for z for the 3D Median filter (anisotropy in z). 
**Detection noise:** noise setting for the 3D maxima finder – only local maxima are considered that are higher than this value. 

Further documentation of the specific tools: 
3D filter: https://imagej.net/plugins/3d-imagej-suite
3D Maxima finder:  https://imagejdocu.tudor.lu/tutorial/plugins/3d_maxima_finder 

Press **OK** to start the script. 

Processing is performed in batch over all files with the correct **File suffix** in the **Input directory**. 

The settings chosen will be saved with a time stamp as text file the **Output directory** (*Settings_YYYY-MM-DD.txt*). A Log file will open documenting the processing. This Log file will be also saved with a time stamp as text file in the **Output directory** (*Log_YYYY-MM-DD.txt*). 

Results for each processed input image will be saved in the Output directory: 
```
├── *\<fileName\>_Detection.roi* 
├── *\<fileName\>_Detection.tif* 
└── *\<fileName\>_Results.xls* 
```
You can adjust the detection parameters by running the script and verifying the detections using the *\<fileName\>_Detection.tif*. Keep in mind that this is a 2D visualization of a 3D detection. Alternatively you can load the *\<fileName\>_Detection.roi* over the original 3D stack. 
  
The coordinates as well as the height of the image is stored in *\<fileName\>_Results.xls* and can be used for further analysis.


### Analyze Cytoplasmic Marker

Load *cell-remodeling_cytoplasmic-marker.ijm* 

**Input directory:** Folder that contains the input file(s). 
**Output directory:** were to save the result files. 
**File suffix:** specify the suffix of the input files. 
**Name channel 1:** name for result files. 
**Name channel 2:** name for result files. 
**Median filter size:** filter kernel size for median filter. 
**Rolling ball size:** size for rolling ball background subtraction. 
**Threshold channel 1:** automatic intensity based threshold. 
**Threshold channel 2:** automatic intensity based threshold. 

Press **OK** to start the script. 

Processing is performed in batch over all files with the correct **File suffix** in the **Input directory**. 

The settings chosen will be saved with a time stamp as text file the **Output directory** (*Settings_YYYY-MM-DD.txt*). A Log file will open documenting the processing. This Log file will be also saved with a time stamp as text file in the **Output directory** (*Log_YYYY-MM-DD.txt*). 

 
Results for each processed input image will be saved in the **Output directory**: 
```
├── *<ImageHeight>_<fileName>_<channel1Name>.txt*
├── *<ImageHeight>_<fileName>_<channel2Name>.txt* 
└── masks 
    ├── *Mask_<fileName>_channel1Name>.tif* 
    └──*Mask_<fileName>_channel2Name>.tif* 
```
You can adjust the segmentation parameters by running the script and verifying the segmentation using the resulting masks.  

For further analysis use *<ImageHeight>_<fileName>_<channel1Name>.txt* files which contains the x and y coordinates of every pixel of the segmentation mask. 
 
