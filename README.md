# brainviz

raw brain wave data visualization
made in processing: processing.org
using controlP5 and peasycam libraries

key commands:

	if (key == 's') saveFrame("screenshot.png");
	if (key == 'f') println("framerate: "+frameRate);
	if (key == 'm') mouseArmed = true;
	if (key == 'i') println("index: "+startIndex+"-"+endIndex);
	if (key == 'r') mode = RANGE;
	if (key == 'a') mode = ACTION;
	if (key == 'd') debug = !debug;
	if (key == 'h') settings = !settings;
	if (key == 'c') camOn = !camOn;
	if (key == 'p') recordPDF = true;
	if (key == '3') record3D = true;
