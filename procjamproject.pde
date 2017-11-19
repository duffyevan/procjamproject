import megamu.mesh.*;

PImage overlay;
PImage castle;
PFont font;

int RANDOM_SEED = 123456789;
int NUMBER_OF_LANDMARKS = 0;


int RANDOM_POINT_MIN_X = 224;
int RANDOM_POINT_MAX_X = 877;

int RANDOM_POINT_MIN_Y = 164;
int RANDOM_POINT_MAX_Y = 670;

int MIN_SEPARATION_DISTANCE = 40;

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
		// ellipse(x, y,POINT_DIAMETER,POINT_DIAMETER);
		image(castle, x-8, y-8);
	}

	float distanceTo(Coordinate other){
		if (other == null) return Integer.MAX_VALUE;
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


Coordinate landmarks[];
Voronoi mainVoronoi;
Line lines[];
String regionName; 

void setup(){
	try{
		loadJsonConfig();	
	} catch (Exception e){
		e.printStackTrace();
		exit();
	}

	if (RANDOM_SEED != 0){
		randomSeed(RANDOM_SEED); // used for explicitly chosing a random seed
	}

	if (NUMBER_OF_LANDMARKS == 0){
		NUMBER_OF_LANDMARKS = (int)random(10,60);
		MIN_SEPARATION_DISTANCE = (int)(60.0/NUMBER_OF_LANDMARKS * 20.0);
	}
	
	landmarks = new Coordinate[NUMBER_OF_LANDMARKS];
	
	font = createFont("Purisa Oblique", 72);

	regionName = generateName();
	println("regionName: "+regionName);
	
	overlay = loadImage("scroll.png");
	castle = loadImage("Castle.png");
	
	size(1105, 834);
	
	for (int i = 0; i < NUMBER_OF_LANDMARKS; i ++){
		landmarks[i] = randomCoordinate();
	}
	mainVoronoi = calculateVoronoi();
	lines = getLines();
}


void draw(){
	try{ // error handling so processing doesn't hang on me
		dStart = System.nanoTime(); // used for calculating FPS
		
		background(#FDF4BE); // clear the screen

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
		image(overlay, 0, 0, width, height);
	
		textFont(font);
		textAlign(CENTER,CENTER);
		text(regionName, width/2, 80);
		
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
	Coordinate ret;
	Coordinate closest;
	do{
		ret = new Coordinate((int)random(RANDOM_POINT_MIN_X, RANDOM_POINT_MAX_X),(int)random(RANDOM_POINT_MIN_Y, RANDOM_POINT_MAX_Y));
		closest = findClosestLandmark(ret);
		if (closest == null) break;
	} while (closest != null && ret.distanceTo(closest) < MIN_SEPARATION_DISTANCE);
	return ret;
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


/**
 * @brief      Gets the lines form the voronoi calculation.
 *
 * @return     The lines that make up the Voronio.
 */
Line[] getLines(){
	float [][] lineCoordValues = mainVoronoi.getEdges();
	Line ret[] = new Line[lineCoordValues.length];
	for (int i = 0; i < lineCoordValues.length; i++){
		ret[i] = new Line(new Coordinate((int)lineCoordValues[i][0],(int)lineCoordValues[i][1]),new Coordinate((int)lineCoordValues[i][2],(int)lineCoordValues[i][3]));
	}
	return ret;
}


/**
 * Loads a json configuration.
 * @brief      Loads a json configuration.
 */
void loadJsonConfig(){
	String params = "";
	for (String s : loadStrings("params.json")){
		params = params + s;
	}
	JSONObject j = parseJSONObject(params);
	println("j: "+j);
	int value = 0; 
	
	value = Integer.parseInt(j.getString("RANDOM_SEED"));
	if (value != 0)
		RANDOM_SEED = value;

	value = Integer.parseInt(j.getString("NUMBER_OF_LANDMARKS"));
	if (value != 0)
		NUMBER_OF_LANDMARKS = value;

	value = Integer.parseInt(j.getString("RANDOM_POINT_MAX_Y"));
	if (value != 0)
		RANDOM_POINT_MAX_Y = value;

	value = Integer.parseInt(j.getString("RANDOM_POINT_MIN_Y"));
	if (value != 0)
		RANDOM_POINT_MIN_Y = value;

	value = Integer.parseInt(j.getString("RANDOM_POINT_MAX_X"));
	if (value != 0)
		RANDOM_POINT_MAX_X = value;

	value = Integer.parseInt(j.getString("RANDOM_POINT_MIN_X"));
	if (value != 0)
		RANDOM_POINT_MIN_X = value;

	value = Integer.parseInt(j.getString("MIN_SEPARATION_DISTANCE"));
	if (value != 0)
		MIN_SEPARATION_DISTANCE = value;
}
