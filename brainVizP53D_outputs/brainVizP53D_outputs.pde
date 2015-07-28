import controlP5.*;
import peasy.*;
import processing.pdf.*;
import processing.dxf.*;

ControlP5 cp5;
Range range;

Table table;

int rows;

float min_left_ear, max_left_ear, min_left_forehead, max_left_forehead, min_right_ear, max_right_ear, min_right_forehead, max_right_forehead;

int startIndex = 500, endIndex = 600;

float xStep;

float graphSize = 200, strokeW = 0.5;

boolean mouseArmed = false;
int dragXMin, dragXMax;

int mode = 1;

PeasyCam cam;

float startDistance = 900, yPos = 544, sizing = 190, spacing = 15;
//float yOffset = 300;

final int RANGE = 0, ACTION = 1;

boolean debug = false;
boolean settings = true;
boolean camOn = false;

float spread = 100, diameter = 200;

float curvatureX, curvatureY, curvatureZ;

boolean recordPDF = false, record3D = false;

void setup () {
	size(1200,600, OPENGL);

	dragXMax = 0;
	dragXMin = width;

	table = loadTable("sampleEEG.csv", "header");
	rows = table.getRowCount();
	println(rows + " total rows in table");

 	for (int i = 0; i<rows; i++) {
    
		TableRow row = table.getRow(i);
	    float _time = row.getFloat("time");
	    float left_ear = row.getFloat("left ear");

	    min_left_ear = min(min_left_ear, left_ear);
	    max_left_ear = max(max_left_ear, left_ear);

	    float left_forehead = row.getFloat("left forehead");

	    min_left_forehead = min(min_left_forehead, left_forehead);
	    max_left_forehead = max(max_left_forehead, left_forehead);

	    float right_ear = row.getFloat("right ear");

	    min_right_ear = min(min_right_ear, right_ear);
	    max_right_ear = max(max_right_ear, right_ear);

	    float right_forehead = row.getFloat("right forehead");

	    min_right_forehead = min(min_right_forehead, right_forehead);
	    max_right_forehead = max(max_right_forehead, right_forehead);

	    //println("row nr: "+i+" with time stamp "+_time + " has left ear " + left_ear + " and left forehead " + left_forehead + " and right ear " + right_ear + " and right forehead " + right_forehead);
 	}

    cp5 = new ControlP5(this);

	cp5.setColorLabel(color(0,0,0));

    range = cp5.addRange("rangeController")
             // disable broadcasting since setRange and setRangeValues will trigger an event
             .setBroadcast(false) 
             .setPosition(50,50)
             .setSize(400,15)
             .setHandleSize(20)
             .setRange(0,rows)
             .setRangeValues(startIndex,endIndex)
             // after the initialization we turn broadcast back on again
             .setBroadcast(true)
             .setColorForeground(color(0,140))
             .setColorBackground(color(155,140))  
             ;

    cp5.addSlider("strokeW")
    		 .setPosition(50,70)
    		 .setSize(400,10)
    		 .setRange(0,5)
    		 ;

    cp5.addSlider("yPos")
    		 .setPosition(50,90)
    		 .setSize(400,10)
    		 .setRange(0,height)
    		 .setValue(526)
    		 ;

    		 
    cp5.addSlider("startDistance")
    		 .setPosition(50,110)
    		 .setSize(400,10)
    		 .setValue(4000)
    		 .setRange(0,5000)
    		 ;
    		 
    cp5.addSlider("spacing")
    		 .setPosition(50,130)
    		 .setSize(400,10)
    		 .setRange(-20,20)
    		 ;

    cp5.addSlider("sizing")
    		 .setPosition(50,150)
    		 .setSize(400,10)
    		 .setRange(0,500)
    		 ;

    cp5.addSlider("spread")
    		 .setPosition(50,170)
    		 .setSize(400,10)
    		 .setRange(0,360)
    		 ;

    cp5.addSlider("diameter")
    		 .setPosition(50,190)
    		 .setSize(400,10)
    		 .setRange(0,500)
    		 ;

    cp5.addSlider("curvatureX")
    		 .setPosition(50,210)
    		 .setSize(400,10)
    		 .setRange(-1,1)
    		 ;
    cp5.addSlider("curvatureY")
    		 .setPosition(50,230)
    		 .setSize(400,10)
    		 .setRange(-1,1)
    		 ;
    cp5.addSlider("curvatureZ")
    		 .setPosition(50,250)
    		 .setSize(400,10)
    		 .setRange(-1,1)
    		 ;

    // cp5.addSlider("yOffset")
    // 		 .setPosition(50,170)
    // 		 .setSize(400,10)
    // 		 .setRange(-1000,1000)
    // 		 ;

    cp5.setAutoDraw(false);

	cam = new PeasyCam(this, 1000);
}

void draw() {

    if (recordPDF) {
    	beginRecord(PDF, "frame-####.pdf"); 
    }
    if (record3D) {
    	beginRaw(DXF, "output-####.dxf");
    }

	switch (mode) {
		case RANGE:
			camOn = false;
			justDrawData();
			break;

		case ACTION:
			action();
			if (!camOn) camera();
			break;
	}

	if (recordPDF) {
		endRecord();
		recordPDF = false;
	}
	if (record3D) {
		endRaw();
    	record3D = false;
	}

    if (settings) gui();
}

void action() {

	background(255);

	pushMatrix();

	translate(0,0,-startDistance);
	
	colorMode(RGB);
	stroke(0);
	strokeWeight(strokeW);
	fill(100);

	for (int j = startIndex; j<endIndex; j++) {
		if (j == endIndex-1) {
			debug = true;
		} else {
			debug = false;
		}
		pushMatrix();
		translate(width/2,yPos);
		
		TableRow row = table.getRow(j);

		float reading[] = new float [4];
		float value = 0;

		for (int k = 0; k<4; k++) {
			
			if (k == 0) {
				value = row.getFloat("left ear");
				reading[k] = map(value, min_left_ear, max_left_ear, 0, sizing);
			} else if (k == 1) {
				value = row.getFloat("left forehead");
				reading[k] = map(value, min_left_forehead, max_left_forehead, 0, sizing);
			} else if (k == 2) {
				value = row.getFloat("right ear");
				reading[k] = map(value, min_right_ear, max_right_ear, 0, sizing);
			} else if (k == 3) {
				value = row.getFloat("right forehead");
				reading[k] = map(value, min_right_forehead, max_right_forehead, 0, sizing);
			}



			//println(j+": reading "+k+": "+reading[k]);

		}

		float curveX[] = new float [6];
		float curveY[] = new float [6];

		pushMatrix();

		rotate(-radians(spread)/2);

		int steps = 50;
		float stepRotation = radians(spread) / steps;


		for (int i = 0; i<steps; i++) {
			pushMatrix();
			translate(0, -diameter, 0);
			noFill();
			stroke(255,0,0,100);
			if (debug) ellipse(0,0,1,1);
			popMatrix();
			rotate(stepRotation);
		}


		steps = 4;
		stepRotation = radians(spread) / steps;

		rotate(radians(-spread));

		pushMatrix();

		translate(0, -diameter, 0);
		curveX[0] = modelX(0,0,0);
		curveY[0] = modelY(0,0,0);

		popMatrix();

		rotate(stepRotation/2);

		for (int i = 0; i<steps; i++) {

			pushMatrix();
			translate(0, -diameter, 0);
			noFill();
			stroke(255,0,0);
			if (debug) ellipse(0,0,2,2);
			if (debug) line(0,0,0,-reading[i]);
			translate(0,-reading[i]);
			if (debug) ellipse(0,0,1,1);

			curveX[i+1] = modelX(0,0,0);
			curveY[i+1] = modelY(0,0,0);

			popMatrix();

			rotate(stepRotation);
		}

		pushMatrix();

		rotate(-stepRotation/2);

		translate(0, -diameter, 0);
		curveX[5] = modelX(0,0,0);
		curveY[5] = modelY(0,0,0);

		popMatrix();
		popMatrix();
	    popMatrix();

	    pushMatrix();
	    //translate(0,yOffset,0);

	    float t = map(mouseX, 0, width, -1, 1);
	    curveTightness(t);

	    stroke(0,100);

		beginShape();
	    curveVertex(curveX[0],curveY[0]);
	  
		for (int i = 0; i<6; i++) {
	 		curveVertex(curveX[i], curveY[i]);
		}

	    curveVertex(curveX[5],curveY[5]);
		endShape();

		popMatrix();
		translate(0, 0, spacing);
		rotateX(radians(curvatureX));
		rotateY(radians(curvatureY));
		rotateZ(radians(curvatureZ));
		
	}

	popMatrix();

}

void gui() {
  hint(DISABLE_DEPTH_TEST);
  cam.beginHUD();
  if (camOn) {
  	cam.setMouseControlled(true);
  } else {
  	cam.setMouseControlled(false);
  }
  cp5.draw();
  cam.endHUD();
  hint(ENABLE_DEPTH_TEST);
}

void justDrawData() {
	background(255);

	if (mousePressed && mouseArmed) {
		dragXMax = max(dragXMax, mouseX);
		dragXMin = min(dragXMin, mouseX);
		colorMode(RGB);
		fill(100,100);
		noStroke();
		rect (dragXMin,0,(dragXMax-dragXMin),height);
	}

	pushMatrix();

	//float scaleFactor = (endIndex-startIndex) / width;
	//println("scaleFactor: "+scaleFactor);
	
	float lastX = 0, lastY = height/2;

	float currentColor = 0;
	colorMode(HSB);

	for (int j = 0; j<4; j++) {

		translate(0,height/5);
		stroke(currentColor,150,150);
		currentColor += 255/5;

		pushMatrix();

		xStep = float(width)/(endIndex-startIndex);
		strokeWeight(xStep*0.8);

		for (int i = startIndex; i<endIndex; i++) {

			TableRow row = table.getRow(i);
			
			float value = 0, scaledValue = 0;

			if (j == 0) {
				value = row.getFloat("left ear");
				scaledValue = map(value, min_left_ear, max_left_ear, 0, height/5);
			} else if (j == 1) {
				value = row.getFloat("left forehead");
				scaledValue = map(value, min_left_forehead, max_left_forehead, 0, height/5);
			} else if (j == 2) {
				value = row.getFloat("right ear");
				scaledValue = map(value, min_right_ear, max_right_ear, 0, height/5);
			} else if (j == 3) {
				value = row.getFloat("right forehead");
				scaledValue = map(value, min_right_forehead, max_right_forehead, 0, height/5);
			}

			line (0, - scaledValue, 0, scaledValue);
			translate(xStep, 0);

		}
		popMatrix();
	}

	popMatrix();

}


void controlEvent(ControlEvent theControlEvent) {
  if(theControlEvent.isFrom("rangeController")) {
    // min and max values are stored in an array.
    // access this array with controller().arrayValue().
    // min is at index 0, max is at index 1.
    startIndex = int(theControlEvent.getController().getArrayValue(0));
    endIndex = int(theControlEvent.getController().getArrayValue(1));
    println("min: "+ startIndex);
    println("max: "+ endIndex);
    println("range update, done.");
  }
  
}


void keyPressed() {
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
	if (key == CODED) {
		if (keyCode == LEFT) {
			println("LEFT");
			startIndex = startIndex+1;
			endIndex = endIndex+1;
			//startIndex = constrain(startIndex++,0,rows);
			//endIndex = constrain(endIndex++,0,rows);
			range.setRangeValues(startIndex, endIndex);
		}
		if (keyCode == RIGHT) {
			println("RIGHT");
			startIndex = startIndex-1;
			endIndex = endIndex-1;
			//startIndex = constrain(startIndex--,0,rows);
			//endIndex = constrain(endIndex--,0,rows);
			range.setRangeValues(startIndex, endIndex);

		}
	}
}

void mouseReleased() {

	if (mouseArmed) {	
		println("dragged mouse from "+dragXMin+" to "+dragXMax);
		print("rescaling index from "+startIndex+"-"+endIndex);
		startIndex = int(map(dragXMin, 0, width, startIndex, endIndex));
		endIndex = int(map(dragXMax, 0, width, startIndex, endIndex));
		println(" to "+startIndex+"-"+endIndex);

		range.setRangeValues(startIndex, endIndex);

		dragXMax = 0;
		dragXMin = width;
		mouseArmed = false;
	}
}