// ============================================================================
/* Batch macro cell detection     
 * 
 * DESCRIPTION: Detection of cells
 * 				Segments cells of user preprocessed images
 *            	using 3D ImageJ Suite: 3D Maxima Finder
 *              
 *      AUTHOR: Christopher Schmied, christopher.schmied@dzne.de
 *    INSITUTE: Deutsches Zentrum für Neurodegenerative Erkankungen (DZNE)
 *        BUGS:
 *       NOTES: 
 * DEPENDECIES: 3D ImageJ Suite: http://sites.imagej.net/Tboudier/
 * 				ImageScience: http://sites.imagej.net/ImageScience
 *     VERSION: 2.0
 *     CREATED: 2016-09-20
 *    REVISION: 2016-09-20
 */
// ============================================================================
// User defined parameters
// Detection parameters
radiusxy =3; 
radiusz = 3;
noise = 150;

// ============================================================================
// Specifies input and output directories
input = getDirectory("Input directory");
dir = getDirectory("Output directory");

Dialog.create("File type");
Dialog.addString("File suffix: ", ".tif", 5);
Dialog.show();
suffix = Dialog.getString();

processFolder(input);

function processFolder(input) {
	list = getFileList(input);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(input + list[i]))
			processFolder("" + input + list[i]);
		if(endsWith(list[i], suffix))
			processFile(input, dir, list[i], radiusxy, radiusz, noise);
	}
}

// ============================================================================
// takes images in input directory and performs processing

function processFile(input, dir, file, radiusxy, radiusz, noise) {

		// sets processing without displaying images
		run("Close All"); 
		roiManager("reset"); 
		setBatchMode(true);
		
		// functions for macro
		function closeImage(title){
					selectWindow(title);
					close();
					//print("Closed image: " + title);
		}

		function saveImage(title2, name, dir){
				selectWindow(title2);
				saveAs("Tiff", dir + name + ".tif");
				//print("Saved image:" + title2);
		}

		// Open image files 
	 	open(input + file);
		name=getTitle;
		print("Starting processing of file: " + name);
		
		// gets and prints image height in px
		height = getHeight();
		print("Height of image is: " + height + " px");
		
		// Filter and substract background
		print("Starting 3D Fast Filter: Median filter");
		run("3D Fast Filters","filter=Median radius_x_pix=4 radius_y_pix=4 radius_z_pix=8 Nb_cpus=4");
		mean=getTitle;
		print("Substracting Background");
		run("Subtract Background...", "rolling=50 stack");
		closeImage(name);

		// detect cells using "3D Maxima Finder"
		print("Starting 3D Maxima Finder");
		run("3D Maxima Finder", "radiusxy=" + radiusxy + " radiusz=" + radiusz + " noise=" + noise);
		selectWindow("Results"); 
		setResult("Height", 0, height);
		updateResults();
		saveAs("Results", dir + name +"_Results.xls");
		selectWindow("Results"); 
		run("Close"); 

		// detect 2D position of cells for visualization
		print("Starting visualization of detection");
		selectWindow("peaks");
		run("Z Project...", "projection=[Max Intensity]");
		maxpeaks=getTitle;
		closeImage("peaks");
		
		//saveImage(maxpeaks, maxpeaks, dir);
		//closeImage("peaks");

		selectWindow(maxpeaks);
		run("Find Maxima...", "noise=0 output=[Point Selection]");
		roiManager("Add");

		selectWindow(mean);
		run("Z Project...", "projection=[Max Intensity]");
		run("Enhance Contrast...", "saturated=0.3");
		maxmean=getTitle;
		closeImage(mean);
		selectWindow(maxmean);
		roiManager("Select", 0);
		saveImage(maxmean, name + "_Detection", dir);
		saveAs("Selection", dir + name + "_Detection.roi");
		maxmean=getTitle;

		// close Images
		closeImage(maxmean);
		closeImage(maxpeaks);
		roiManager("reset"); 
		print("Saving Results to: " + dir);
		print("Finished Processing of file: " + name);
}
print("Finished Processing");
