

int RANDOM_SEED = 123456789;
int NUMBER_OF_LANDMARKS = 5;
int POINT_DIAMETER = 10;

class Coordinate {
	int x;
	int y;
	Coordinate(int X, int Y){
		x = X;
		y = Y;
	}
	void draw(){
		ellipse(x, y,POINT_DIAMETER,POINT_DIAMETER);
	}

	float distanceTo(Coordinate other){
		return sqrt(pow(other.x, 2)+pow(other.y, 2));
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
		line(p1.x, p1.y, p2.x, p2.y);
	}

	String toString(){
		return "Line from " + p1 + " to " + p2;
	}
}  


Coordinate landmarks[] = new Coordinate[NUMBER_OF_LANDMARKS];

void setup(){
	// randomSeed(RANDOM_SEED);
	size(512, 512);
	for (int i = 0; i < NUMBER_OF_LANDMARKS; i ++){
		landmarks[i] = randomCoordinate();
	}
}


void draw(){
	try{ // error handling so processing doesnt hang on me
		background(100);
		for (Coordinate l : landmarks){
			l.draw();
		}
		
	}
	catch (Exception e) {
		e.printStackTrace(); // just quit if theres an unhandled error
		exit();
	}
}


Coordinate randomCoordinate(){
	return new Coordinate((int)random(0, width),(int)random(0, height));
}

Line calculateVLine(Coordinate p1, Coordinate p2){
	int A = p2.x; 
	int B = p2.y;
	int C = p1.x;
	int D = p1.y;

	return new Line(new Coordinate(0,(int)jacksonsEquation(A,B,C,D,0)),new Coordinate(width,(int)jacksonsEquation(A,B,C,D,width)));
}

float jacksonsEquation(int a, int b, int c, int d, int x){
	return ((0.5*(a-c))/(0.5*(d-b))*(x-0.5*(c+a)) + .5*(d+b)); // jackson helped me with the math for this part. It's the equation for the lines needed for the borders
}


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