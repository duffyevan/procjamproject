import megamu.mesh.*;

PImage overlay;

int RANDOM_SEED = 123456789;
int NUMBER_OF_LANDMARKS = 60;
int POINT_DIAMETER = 10;

long dStart = 0;

class Coordinate {
	int x;
	int y;
	Coordinate(int X, int Y){
		x = X;
		y = Y;
	}
	void draw(){
		fill(#916C20);
		noStroke();
		ellipse(x, y,POINT_DIAMETER,POINT_DIAMETER);
	}

	float distanceTo(Coordinate other){
		return sqrt(pow(other.x-x, 2)+pow(other.y-y, 2));
	}

	String toString(){
		return "("+ x + "," + y + ")";
	}
}  

class Line {
	Coordinate p1;
	Coordinate p2;
	Line(Coordinate p1, Coordinate p2){
		this.p1 = p1;
		this.p2 = p2;
	}
	void draw(){
		stroke(#6C3B14);
		line(p1.x, p1.y, p2.x, p2.y);
	}

	String toString(){
		return "Line from " + p1 + " to " + p2;
	}
}  


Coordinate landmarks[] = new Coordinate[NUMBER_OF_LANDMARKS];
Voronoi mainVoronoi;
Line lines[];

void setup(){
	// randomSeed(RANDOM_SEED);
	
	overlay = loadImage("./overlay.png");

	size(512, 512);
	for (int i = 0; i < NUMBER_OF_LANDMARKS; i ++){
		landmarks[i] = randomCoordinate();
	}
	mainVoronoi = calculateVoronoi();
	lines = getLines();
}


void draw(){
	try{ // error handling so processing doesn't hang on me
		dStart = System.nanoTime(); // used for calculating FPS
		
		background(#B18C40); // clear the screen

		for (Coordinate l : landmarks){ // draw the castles
			l.draw();
		}
		for (Line line : lines){ // draw the border lines
			line.draw();
		}
			
		if (mousePressed){
			Coordinate c = findClosestLandmark(new Coordinate(mouseX,mouseY)); // click and drag!
			c.x = mouseX;
			c.y = mouseY;	

			// update when clicking and dragging
			mainVoronoi = calculateVoronoi(); // calculate to Voronoi figure
			lines = getLines();
		}
		// image(overlay, 0, 0, width, height);
		println("FPS: " + 1000000000/(System.nanoTime()-dStart)); // print the FPS	
	}
	catch (Exception e) {
		e.printStackTrace(); // just quit if theres an unhanded error
		exit();
	}
}


/**
 * @brief      Make A Random Coordinate
 * This is useful because I don't have to do this over 
 * and over and make the main loop messy
 * @return     The newly created random coordinate
 */
Coordinate randomCoordinate(){
	return new Coordinate((int)random(0, width),(int)random(0, height));
}

/**
 * @brief      Calculates the bisecting line.
 * I wrote this as a start to writing the Voronoi 
 * part myself, but it was too much math and I ended 
 * up using a library. Leaving this here in case 
 * I decide to finish this myself later
 * @param[in]  p1    The first point
 * @param[in]  p2    The second point
 *
 * @return     The bisecting line.
 */
Line calculateVLine(Coordinate p1, Coordinate p2){
	int A = p2.x; 
	int B = p2.y;
	int C = p1.x;
	int D = p1.y;

	return new Line(new Coordinate(0,(int)jacksonsEquation(A,B,C,D,0)),new Coordinate(width,(int)jacksonsEquation(A,B,C,D,width)));
}


/**
 * @brief      Jackson (my roommate) helped me with the math for this part. It's the equation for the lines needed for the borders
 *
 * @param[in]  a,b,c,d     Coordinate parameters
 * @param[in]  x           The x coordinate to solve for y
 * 
 * @return     the solved y value for a bisecting line
 */
float jacksonsEquation(int a, int b, int c, int d, int x){
	return ((0.5*(a-c))/(0.5*(d-b))*(x-0.5*(c+a)) + .5*(d+b)); // 
}


/**
 * @brief      Find the closest landmark to a given location on the map
 *
 * @param[in]  location  The location to look from
 *
 * @return     The closest location
 */
Coordinate findClosestLandmark(Coordinate location){
	Coordinate closest = null;
	int closestDistance = Integer.MAX_VALUE; // really big number
	for (Coordinate l : landmarks){
		if (location != l){
			int tempD = (int)location.distanceTo(l);
			if (tempD < closestDistance){
				closestDistance = tempD;
				closest = l;
			}
		}
	}
	return closest;
}

/**
 * @brief      Calculates the Voronoi figure from all the landmarks.
 *
 * @return     The Voronoi.
 */
Voronoi calculateVoronoi(){
	float points[][] = new float [NUMBER_OF_LANDMARKS][2];

	for (int i = 0; i < NUMBER_OF_LANDMARKS; i ++){
		points[i][0] = landmarks[i].x;
		points[i][1] = landmarks[i].y;
	}
	return new Voronoi(points);
}

Line[] getLines(){
	float [][] lineCoordValues = mainVoronoi.getEdges();
	Line ret[] = new Line[lineCoordValues.length];
	for (int i = 0; i < lineCoordValues.length; i++){
		ret[i] = new Line(new Coordinate((int)lineCoordValues[i][0],(int)lineCoordValues[i][1]),new Coordinate((int)lineCoordValues[i][2],(int)lineCoordValues[i][3]));
	}
	return ret;
}