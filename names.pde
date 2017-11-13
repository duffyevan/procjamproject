String firstHalf[] = {
	"Evans",
	"Scotts",
	"Jacksons",
	"Arling",
	"Michaels",
	"Shrews",
	"Spring"
};

String secondHalf[] = {
	"tropolis",
	"ville",
	"dale",
	" Orchard",
	"bury",
	"field"
};


String generateName(){
	return firstHalf[(int)random(0, firstHalf.length)] + secondHalf[(int)random(0, secondHalf.length)];
}