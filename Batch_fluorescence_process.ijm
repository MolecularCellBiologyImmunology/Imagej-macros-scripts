/* Provided by MCCF Amsterdam - Please acknowledge
 * Please cite: 
 * Schindelin, J., Arganda-Carreras, I., Frise, E. et al. Fiji: an open-source platform for biological-image analysis. Nat Methods 9, 676–682 (2012). https://doi.org/10.1038/nmeth.2019
 * 
 * - opens files (single series .nd2, .tif, .vsi, or .czi) - only for fluorescence images
 * - makes IP if z-stack (as defined by user)
 * - Sets colors to predifined colors
 * - Allows for auto Brightness and contrast or set values on a per channel choice
 * - Saves merge as *.tif with predifined scale bar (as overlay - B&C can still be adjusted) (if wanted)
 * - Saves merge as *.png with predifined scale bar (if wanted)
 * - Saves each channel as individual *.png with predifined scale bar, in grayscale 
 * - Saves each channel with calibration bar (if manual B&C those values, otherwise the Auto selected values - might help you to define the range you want to use) (if wanted)
 * - Saves each channel as individual *.tif with predifined scale bar (as overlay - B&C can still be adjusted) (if wanted)
*/

//open dialog and get user input
#@ File(style="directory") input 
#@ File(style="directory") output 
#@ String(label="File Type", choices={".nd2", ".tif", ".czi", ".lif", ".vsi"}, style="list") type
#@ String(value="Ignor values for channels not used - all fields need to have values (don't delete)", visibility="MESSAGE") hint
#@ Integer(label="For large .vsi files it might be nescessary to reduce the resolution by 2^X fold; X=", value=0) vsiRed
#@ String(label="Z-Projection (if z-stack", choices={"Max Intensity", "Average Intensity", "Sum Slices", "Min Intensity", "Standard Deviation", "Median"}, style="list") Zproj
#@ Boolean(label="Save Merge .tif (B&C adjustable)") MergTif
#@ Boolean(label="Save Merge .png (Color, B&C set)") MergPng
#@ Integer(label="Scalebar length") scale
#@ String(label="Color Channel 1", choices={"Blue", "Red", "Green", "Cyan", "Magenta", "Yellow", "Grays", "none"}, style="list") color1
#@ String(label="Channel 1 Set Brightness & Contrast",  choices={"Auto", "Manual"}, style="radioButtonHorizontal") C1_BrightContr
#@ Integer(label="Channel 1 min", value=0) C1Min
#@ Integer(label="Channel 1 max", value=255) C1Max
#@ String(label="Channel 1 suffex to be added", value="CH1") C1lab
#@ Boolean(label="Save Channel 1 .tif (B&C adjustable)") C1Tif
#@ Boolean(label="Save Channel 1 .png (Grayscale B&C set)") C1Png
#@ Boolean(label="Show Channel 1 in merge") C1Merg
#@ String(label="Color Channel 2", choices={"Green", "Yellow", "Blue", "Red","Cyan", "Magenta", "Grays", "none"}, style="list") color2
#@ String(label="Channel 2 Set Brightness & Contrast", choices={"Auto", "Manual"}, style="radioButtonHorizontal") C2_BrightContr
#@ Integer(label="Channel 2 min", value=0) C2Min
#@ Integer(label="Channel 2 max", value=255) C2Max
#@ String(label="Channel 2 suffex to be added", value="CH2") C2lab
#@ Boolean(label="Save Channel 2 .tif (B&C adjustable)") C2Tif
#@ Boolean(label="Save Channel 2 .png (Grayscale B&C set)") C2Png
#@ Boolean(label="Show Channel 2 in merge") C2Merg
#@ String(label="Color Channel 3", choices={"Red", "Green", "Blue", "Cyan", "Magenta", "Yellow", "Grays", "none"}, style="list") color3
#@ String(label="Channel 3 Set Brightness & Contrast", choices={"Auto", "Manual"}, style="radioButtonHorizontal") C3_BrightContr
#@ Integer(label="Channel 3 min", value=0) C3Min
#@ Integer(label="Channel 3 max", value=255) C3Max
#@ String(label="Channel 3 suffex to be added", value="CH3") C3lab
#@ Boolean(label="Save Channel 3 .tif (B&C adjustable)") C3Tif
#@ Boolean(label="Save Channel 3 .png (Grayscale B&C set)") C3Png
#@ Boolean(label="Show Channel 3 in merge") C3Merg
#@ String(label="Color Channel 4", choices={"Red", "Green", "Blue", "Cyan", "Magenta", "Yellow", "Grays", "none"}, style="list") color4
#@ String(label="Channel 4 Set Brightness & Contrast", choices={"Auto", "Manual"}, style="radioButtonHorizontal") C4_BrightContr
#@ Integer(label="Channel 4 min", value=0) C4Min
#@ Integer(label="Channel 4 max", value=255) C4Max
#@ String(label="Channel 4 suffex to be added", value="CH4") C4lab
#@ Boolean(label="Save Channel 4 .tif (B&C adjustable)") C4Tif
#@ Boolean(label="Save Channel 4 .png (Grayscale B&C set)") C4Png
#@ Boolean(label="Show Channel 4 in merge") C4Merg


close("Log");
color = newArray(color1,color2,color3,color4);
Cmin = newArray(C1Min,C2Min,C3Min,C4Min);
Cmax = newArray(C1Max,C2Max,C3Max,C4Max);
suflab = newArray(C1lab,C2lab,C3lab,C4lab);
BC = newArray(C1_BrightContr,C2_BrightContr,C3_BrightContr,C4_BrightContr);
CTif = newArray(C1Tif,C2Tif,C3Tif,C4Tif);
CPng = newArray(C1Png,C2Png,C3Png,C4Png);
mergch = newArray(C1Merg, C2Merg, C3Merg, C4Merg);
actch = "";
for (i = 0; i < mergch.length; i ++) {
	if (mergch[i] == true) {
		actch = actch + "1";
	}
	else {
		actch = actch + "0";
	}
}
run("Bio-Formats Macro Extensions");
list = getFileList(input); // get all images in input folder
setBatchMode(true); // run without showing images
for (i=0; i<list.length; i++) {
	if(endsWith(list[i], type)){ // only use files with the ending you selected
		if(endsWith(list[i], "vsi")) { //only for vsi files
			label = replace(list[i], ".vsi", "_label.png");
			overview = replace(list[i], ".vsi", "_overview.png");
			outlabel = output+File.separator +label;
			outoverview = output+File.separator + overview;
			PATH = input + File.separator + list[i];
			Ext.setId(PATH);
			Ext.getSeriesCount(seriesCount)
			objectives_str = ".*\\d{1,2}x.*"; // anything followed by either 1 or 2 digits followed by an 'x' followed by anything. (typically how highest resolution images are named)
			for(j=0; j<seriesCount; j++) {
				Ext.setSeries(j);
				Ext.getSeriesName(seriesName);
				if(matches(seriesName, "label")) {
					print(list[i]+"_"+seriesName);
// open + save label
					lab= j + 2; // Bioformats numbering is different than imagj, also reduces resulition by 2
					run("Bio-Formats Importer", "open=["+PATH+"] color_mode=Composite crop rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_"+lab+"");
					run("Stack to RGB");
					saveAs("PNG", outlabel);
					run("Close All");	
				}
				if(matches(seriesName, "overview")) {
					print(list[i]+"_"+seriesName);
// open + save overview
					over = j+2; // Bioformats numbering is different than imagj, also reduces resulition by 2
					run("Bio-Formats Importer", "open=["+PATH+"] color_mode=Composite crop rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_"+over+"");
					run("Stack to RGB");
					saveAs("PNG", outoverview);
					run("Close All");			
				}
// open + process actual images				
				if(matches(seriesName, objectives_str)) {
					print("Start with: "+list[i]+" Series: "+seriesName);
					sri = j+vsiRed+1;
				run("Bio-Formats Importer", "open=["+PATH+"] autoscale color_mode=Composite view=Hyperstack stack_order=XYCZT series_"+sri+"");
				rename(list[i]+"_"+seriesName);
				titl = getTitle();
				process(titl);
			}
	}
	}
	else { // if non vsi
		PATH = input+File.separator+list[i];
		Ext.setId(PATH);
		Ext.getSeriesCount(seriesCount);
		if(seriesCount > 1) { //if multiple series do this for all
		for (j = 1; j <= seriesCount; j++) {
			print("Start with: "+list[i]+" Series: "+j+" of "+seriesCount); //some feedback
			run("Bio-Formats Importer", "open=["+PATH+"] autoscale color_mode=Composite view=Hyperstack stack_order=XYCZT series_"+j+""); // open windowless
			titl = getTitle();
			process(titl);
		}
		}	
		else { //if single sereis
			print("Start with: "+list[i]); //some feedback
			run("Bio-Formats Windowless Importer", "open=["+PATH+"] autoscale color_mode=Composite rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT"); // open windowless
			titl = getTitle();
			process(titl);
		}
	}
	}
	else {
	}
}
	
// give some infos in log file
print("input: "+input+File.separator);
print("output: "+output+File.separator);
print("Channels active in merge: "+actch);
print("Scalebar = "+scale +" µm");
print("Ch1: Color: "+color1+", Contrast: "+C1_BrightContr+", set Min: "+C1Min+", set Max: "+C1Max+", Suffix: " + C1lab);
print("Ch2: Color: "+color2+", Contrast: "+C2_BrightContr+", set Min: "+C2Min+", set Max: "+C2Max+", Suffix: " + C2lab);
print("Ch3: Color: "+color3+", Contrast: "+C3_BrightContr+", set Min: "+C3Min+", set Max: "+C3Max+", Suffix: " + C3lab);
print("Ch4: Color: "+color4+", Contrast: "+C4_BrightContr+", set Min: "+C4Min+", set Max: "+C4Max+", Suffix: " + C4lab);

// save log file
string = getInfo("log");
File.saveString(string, output+File.separator+"macro_log.txt");



// define a custom function
function process (titl) {
	title = replace(titl, type, "");
	Stack.getDimensions(width, height, channels, slices, frames);
	if (slices > 1) {	//MIP if z-stack
		run("Z Project...", "projection=["+Zproj+"]");
	}
	if (channels > 1) {
		run("Make Composite");
	}
	for (k=0; k<channels; k++) { // set-up for each channel
		ch = k+1;
		if (channels > 1) {
			Stack.setChannel(ch);
		}
		run(color[k]);
		if(BC[k]=="Auto"){ // if Auto B&C selected run auto contrast
			run("Enhance Contrast", "saturated=0.35");
		}
		else{  //  if not use set values
			setMinAndMax(Cmin[k], Cmax[k]);
		}
	}
	scaleheight = height/250; 
	run("Scale Bar...", "width="+scale+" height=0 thickness="+scaleheight+" hide overlay");		//  add scale bar
	name=getTitle();
	run("Duplicate...", "duplicate");
	if (channels > 1) {
		Stack.setActiveChannels(actch);	
	}
	if (MergTif == true) {
	saveAs("Tiff", output+File.separator+title+"_MERGE.tif"); // save merge as tif
	}
	if (MergPng == true) {
	saveAs("PNG", output+File.separator+title+"_MERGE.png"); // save merge as png
	}
	close();
	selectImage(name); 
	for (k=0; k<channels; k++) { // run for each channel produce B&W .png and calibration bar immage for B&C 
		ch = k+1;
		run("Duplicate...", "duplicate");
		if (channels > 1) {
			Stack.setDisplayMode("grayscale");
			Stack.setChannel(ch);
		}
		name2 = getTitle();
		if (CPng[k] == true) { // if .png for channel is wanted, save it (and calibration bar)
			run("Calibration Bar...", "location=[Separate Image] fill=White label=Black number=5 decimal=0 font=12 zoom=3");
			selectImage("CBar");
			saveAs("PNG", output+File.separator+title+"_"+suflab[k]+"_cbar.png");
			close();
			selectImage(name2);
			saveAs("PNG", output+File.separator+title+"_"+suflab[k]+".png");
			close();
		}
		else {
			close();
		}
	}
	selectImage(name);
	if (channels > 1) {
		run("Split Channels");
		for (k=0; k<channels; k++) { // save as tif that can still be manipulated
			ch = k+1;
			selectImage("C"+ch+"-"+name);
			if (CTif[k] == true) {
				saveAs("TIFF", output+File.separator+title+"_"+suflab[k]+".tif");
			}	
			close();
		}
	}
	else{
		close();
	}
	run("Collect Garbage");
	print("Done with :"+title);
}

