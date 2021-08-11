// ============================================================================
/* pixelcoordinates
 * 
 * DESCRIPTION: Extracts coordinates of each pixel within a threshold
 * 				
 * 				
 *      AUTHOR: Christopher Schmied, christopher.schmied@dzne.de
 *    INSITUTE: Deutsches Zentrum für Neurodegenerative Erkankungen (DZNE)
 *        BUGS:
 *       NOTES: y axis is inverted so 0 is at the top left corner of the image
 *       		Height of analyzed files is written into result table name
 * DEPENDECIES: 
 * 
 *     VERSION: 1.0
 *     CREATED: 2017-02-09
 *    REVISION: 2017-02-09
 */
// ============================================================================
// User defined parameters
C1="Recoverin";
C2="DAPI";

// Projection
projection="Max Intensity";

// Median filer
radius=2;

// Background substraction
rolling=10;

// Automatic threshold signal
threshold1="Mean";

// Automatic threshold DAPI
threshold2="Mean";

// ============================================================================
// Selection of input and output folder
// run as batch over files in input folder
input = getDirectory("Input directory");
output = getDirectory("Output directory");

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
			processFile(input, output, list[i], C1, C2, projection, radius, rolling, threshold1, threshold2);
	}
}

// ============================================================================
// takes images in input directory and performs processing

function processFile(input, output, file, C1, C2, projection, radius, rolling, threshold1, threshold2) {

// Batch mode
setBatchMode(true); 

// Creating Directories for seving the images
save_output_mask = output + "/masks/";
File.makeDirectory(save_output_mask);


print("Input folder: " + input );
print("Opening file: " + file );
open(input + file);

// gets and prints image height in px
height = getHeight();
print("Height of image is: " + height + " px");

// Z-projection
print("Performing: " + projection + " Projection...");
run("Z Project...", "projection=[" + projection + "]");

title = getTitle();
selectWindow(file);
close();

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
run("Save XY Coordinates...", "background=0 invert save=" + output + height + "_" + file + "_" + C1 + ".txt");

// Saves mask image used for analysis
print("Saving results to: " + output );
selectWindow("C1-" + title );
saveAs("Tiff", save_output_mask + "Mask_" + file + "_" + C1);
close();

// Create mask for channel 2
selectWindow("C2-" + title );
print("Applying " + threshold2 + " filter to channel: " + C2);
setAutoThreshold(threshold2 + " dark");
//run("Threshold...");
run("Convert to Mask");

// Extracts xy coordinates
print("Extracting pixel coordinates");
run("Save XY Coordinates...", "background=0 invert save=" + output + height + "_" + file + "_" + C2 + ".txt");

// Saves mask image used for analysis
print("Saving results to: " + output );
selectWindow("C2-" + title );
saveAs("Tiff", save_output_mask + "Mask_" + file + "_" + C2);
close();

// saves log file
selectWindow( "Log");
saveAs("Text", output + "Log.txt");

print("Processing for " + file + " done");
setBatchMode(false); 
}

print("Processing done");