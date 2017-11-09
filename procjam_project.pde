int RANDOM_SEED = 12345678;
int NUMBER_OF_LANDMARKS = 5;
int POINT_DIAMETER = 10;

class Coordinate {
	int x;
	int y;
	Coordinate(int X, int Y){
		x = X;
		y = Y;
	}
}  


Coordinate landmarks[] = new Coordinate[NUMBER_OF_LANDMARKS];

void setup(){
	randomSeed(RANDOM_SEED);
	size(512, 512);
	for (int i = 0; i < NUMBER_OF_LANDMARKS; i ++){
		landmarks[i] = randomCoordinate();
	}
}


void draw(){
	try{ // error handling so processing doesnt hang on me
		for (Coordinate l : landmarks){
			ellipse(l.x, l.y,POINT_DIAMETER,POINT_DIAMETER);
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