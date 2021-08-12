// ============================================================================
/* Batch macro nuclei detection     
 * 
 * DESCRIPTION: Detection of nuclei of tissue ROI
 *            	Using 3D ImageJ Suite: 3D Maxima Finder
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
 *       NOTES: 
 * DEPENDECIES: 3D ImageJ Suite: http://sites.imagej.net/Tboudier/
 * 				
 *     VERSION: 3.0
 *     CREATED: 2016-09-20
 *    REVISION: 2021-08-12
 */
// ============================================================================
// Advanced settings

// median filter radius
radius_xy_pix = 4;
radius_z_pix = 8;

// number of CPUs
Nb_cpus = 4;

rolling_ball_radius = 50;
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
#@ Integer (label = "Detection radius xy", value = 3) radiusxy 
#@ Integer (label = "Detection radius z", value = 3) radiusz 
#@ Integer (label = "Detection noise", value = 20) noise

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
print("Detection settings");
print(" Detection Radius xy: " + radiusxy);
print(" Detection Radius z: " + radiusz);
print(" Detection Noise: " + noise);
print("");
print("Advanced Settings");
print(" 3D Median filter radius xy: " + radius_xy_pix);
print(" 3D Median filter radius z: " +radius_z_pix);
print(" 3D Median filter number cpus: " + Nb_cpus);
print(" Rolling ball radius: " + rolling_ball_radius);
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
			processFile(input, output, list[i], radiusxy, radiusz, noise);
	}
}

// ============================================================================
// takes images in input directory and performs processing

function processFile(input, output, file, radiusxy, radiusz, noise) {
		
		function saveImage(title2, name, output){
				selectWindow(title2);
				saveAs("Tiff", output + File.separator + name + ".tif");
				//print("Saved image:" + title2);
		}

		// Open image files 
	 	run("Bio-Formats Importer", 
	 	"open=[" + input + File.separator + file + "] " + 
	 	"autoscale " +
	 	"color_mode=Default " +
	 	"rois_import=[ROI manager] " +
	 	"view=Hyperstack " +
	 	"stack_order=XYCZT");

		name=getTitle;
		nameWithout = File.nameWithoutExtension;

		// duplicate first stack
		selectImage(name);
		run("Duplicate...", "duplicate");
		duplicate = getTitle();

		print("Starting processing of file: " + name);
		
		// gets and prints image height in px
		selectImage(duplicate);
		height = getHeight();
		print("Height of image is: " + height + " px");
		
		// 3D median filter
		selectImage(duplicate);
		print("Starting 3D Fast Filter: Median filter");
		run("3D Fast Filters","filter=Median " + 
		"radius_x_pix=" + radius_xy_pix + " " +
		"radius_y_pix=" + radius_xy_pix + " " + 
		"radius_z_pix=" + radius_z_pix + " " +
		"Nb_cpus=" + Nb_cpus);
		
		median = getTitle();

		// subtract background
		selectImage(median);
		print("Substracting Background");
		run("Subtract Background...", "rolling=" + rolling_ball_radius + " stack");

		// detect cells using "3D Maxima Finder"
		selectImage(median);
		print("Starting 3D Maxima Finder");
		run("3D Maxima Finder", "radiusxy=" + radiusxy + " radiusz=" + radiusz + " noise=" + noise);
		// creates a window called peaks
		
		// adds the image height to results and saves the table
		selectWindow("Results"); 
		setResult("Height", 0, height);
		updateResults();
		saveAs("Results", output + File.separator + nameWithout +"_Results.xls");
		close("Results");

		// detect 2D position of cells for visualization
		print("Starting visualization of detection");
		selectWindow("peaks");
		run("Z Project...", "projection=[Max Intensity]");
		maxpeaks = getTitle;
		close("peaks");

		// count checker
		run("Find Maxima...", "prominence=0 output=Count");
		count = getResult("Count", 0);
		close("Results");
		
		// if there are detections create visualizations
		if (count > 0 ) {

			// extract detections for visualization 
			print("Success! Found " + count + " peak(s)");
			selectImage(maxpeaks);
			run("Find Maxima...", "noise=0 output=[Point Selection]");
			roiManager("Add");

			// process original image for visualization
			selectImage(name);
			run("Z Project...", "projection=[Max Intensity]");
			run("Enhance Contrast...", "saturated=0.3");
			maxOrg = getTitle;

			selectWindow(maxOrg);
			roiManager("Select", 0);
			saveImage(maxOrg, nameWithout + "_Detection", output);
			
			saveAs("Selection", output + File.separator + nameWithout + "_Detection.roi");
			maxOrg = getTitle;

			close(maxOrg);
			
		} else if ( count == 0 ) {

			print("Sorry! Found no peak(s)!");
			
		} else {

			print("ERROR: count invalid");
			
		}
		
		close(maxpeaks);
		close(name);
		close(duplicate);
		close(median);
		roiManager("reset"); 
		print("Saving Results to: " + output);
		print("Finished Processing of file: " + name);
		
}
// saving the log file
selectWindow("Log");
saveAs("Text", output + File.separator + "Log_" + datum + ".txt");

// restores original imagej settings
restoreSettings;

print("Finished Processing");