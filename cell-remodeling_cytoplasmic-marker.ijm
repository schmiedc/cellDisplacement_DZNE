// ============================================================================
/* pixelcoordinates
 * 
 * DESCRIPTION: Extracts coordinates of each pixel within a threshold
 * 				
 * 				
 *      AUTHOR: Christopher Schmied, christopher.schmied@dzne.de
 *    INSITUTE: German Centre for Neurodegenerative Diseases e.V. (DZNE)
 *    			Imaging Platform
 *				Tatzberg 41
 *				01307 Dresden
 *	            Germany
 *	            
 *	   LICENSE: MIT License:
 *	   			https://github.com/schmiedc/cellDisplacement_DZNE/blob/main/LICENSE
 *	            
 *        BUGS:
 *       NOTES: y axis is inverted so 0 is at the top left corner of the image
 *       		Height of analyzed files is written into result table name
 * DEPENDECIES: 
 * 
 *     VERSION: 2.0
 *     CREATED: 2017-02-09
 *    REVISION: 2021-08-12
 */
// ============================================================================
// Advanced Settings

// Projection setting
projection = "Max Intensity";

// ============================================================================
// setup for processing
run("Close All"); 
roiManager("reset");
close("Log");
setBatchMode(true);

// saves original imagej settings
saveSettings();

// set color options consistently
run("Colors...", "foreground=white background=black selection=yellow");
run("Options...", "iterations=1 count=1 black");

// ============================================================================
// Specifies input and output directories
#@ File (label = "Input directory", style = "directory") input
#@ File (label = "Output directory", style = "directory") output
#@ String (label = "File suffix", value = ".tif") suffix
#@ String (label = "Name channel 1 ", value = "Recoverin") C1
#@ String (label = "Name channel 2 ", value = "DAPI") C2
#@ Integer (label = "Median filter size ", value = 2) radius 
#@ Integer (label = "Rolling ball size ", value = 10) rolling
#@ String (label = "Threshold channel 1", choices={"Default","Huang","Intermodes","IsoData","Li","MaxEntropy","Mean","MinError(I)","Minimum","Moments","Otsu","Percentile","RenyiEntropy","Shanbhag","Triangle","Yen"}, style="listBox", value = "Mean") threshold1
#@ String (label = "Threshold channel 2", choices={"Default","Huang","Intermodes","IsoData","Li","MaxEntropy","Mean","MinError(I)","Minimum","Moments","Otsu","Percentile","RenyiEntropy","Shanbhag","Triangle","Yen"}, style="listBox", value = "Mean") threshold2

// ============================================================================
// save settings
getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
datum = "" + year + "-" + IJ.pad(month, 2) + "-" + IJ.pad(dayOfMonth, 2) + "";
print("Processing from: " + datum);
print("Started at: " + IJ.pad(hour, 2) + ":" + IJ.pad(minute, 2) + ":" + IJ.pad(second, 2));
print("");
print("Directories");
print(" Input: " + input);
print(" Output: " + output);
print(" File suffix: " + suffix);
print("");
print("Segmentation channel 1");
print(" Name: " + C1);
print(" Median filter size: " + radius);
print(" Rolling ball size: " + rolling);
print(" Threshold: " + threshold1);
print("");
print("Segmentation channel 2");
print(" Name: " + C2);
print(" Median filter size: " + radius);
print(" Rolling ball size: " + rolling);
print(" Threshold: " + threshold2);
print("");
print("Advanced Settings");
print(" Projection: " + projection);
print("");

selectWindow("Log");
saveAs("Text", output + File.separator + "Settings_" + datum + ".txt");
// ============================================================================
processFolder(input);

function processFolder(input) {
	list = getFileList(input);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(input + File.separator + list[i]))
			processFolder(input + File.separator + list[i]);
		if(endsWith(list[i], suffix))
			processFile(input, output, list[i], C1, C2, projection, radius, rolling, threshold1, threshold2);
	}
}

// ============================================================================
// takes images in input directory and performs processing

function processFile(input, output, file, C1, C2, projection, radius, rolling, threshold1, threshold2) {

	// Creating Directories for seving the images
	save_output_mask = output + File.separator + "masks";
	File.makeDirectory(save_output_mask);
	
	
	print("Input folder: " + input );
	print("Opening file: " + file );
	
	// Open image files 
	run("Bio-Formats Importer", 
	 	"open=[" + input + File.separator + file + "] " + 
	 	"autoscale " +
	 	"color_mode=Default " +
	 	"rois_import=[ROI manager] " +
	 	"view=Hyperstack " +
	 	"stack_order=XYCZT");

	originalTitle = getTitle();
	 	
	// gets and prints image height in px
	height = getHeight();
	print("Height of image is: " + height + " px");
	
	// Z-projection
	print("Performing: " + projection + " Projection...");
	run("Z Project...", "projection=[" + projection + "]");
	title = getTitle();

	// closes original
	close(originalTitle);

	// Median filtering
	selectWindow(title);
	print("Applying Median filter, radius: " + radius);
	run("Median...", "radius=" + radius);
	
	// background substraction
	print("Subtracting background, rolling: " + rolling );
	run("Subtract Background...", "rolling=" + rolling);
	
	print("Splitting channels...");
	run("Split Channels");
	
	// Create mask for channel 1
	selectWindow("C1-" + title );
	print("Applying " + threshold1 + " filter to channel: " + C1);
	setAutoThreshold(threshold1 + " dark");
	//run("Threshold...");
	setOption("BlackBackground", true);
	run("Convert to Mask");
	
	// Extracts xy coordinates
	print("Extracting pixel coordinates");
	run("Save XY Coordinates...", "background=0 invert save=[" + output + File.separator + height + "_" + file + "_" + C1 + ".txt]");
	
	// Saves mask image used for analysis
	print("Saving results to: " + output );
	selectWindow("C1-" + title );
	saveAs("Tiff", save_output_mask + File.separator + "Mask_" + file + "_" + C1);
	close();
	
	// Create mask for channel 2
	selectWindow("C2-" + title );
	print("Applying " + threshold2 + " filter to channel: " + C2);
	setAutoThreshold(threshold2 + " dark");
	//run("Threshold...");
	run("Convert to Mask");
	
	// Extracts xy coordinates
	print("Extracting pixel coordinates");
	run("Save XY Coordinates...", "background=0 invert save=[" + output  + File.separator + height + "_" + file + "_" + C2 + ".txt]");
	
	// Saves mask image used for analysis
	print("Saving results to: " + output );
	selectWindow("C2-" + title );
	saveAs("Tiff", save_output_mask + File.separator + "Mask_" + file + "_" + C2);
	close();
	
	// saves log file
	selectWindow( "Log");
	saveAs("Text", output + File.separator + "Log_" + datum + ".txt");
	
	print("Processing for " + file + " done");
	
}

// restores original imagej settings
restoreSettings;

print("Processing done");