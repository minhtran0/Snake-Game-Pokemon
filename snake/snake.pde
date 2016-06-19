int width = 600, height = 600;
int dx = 30, dy = 30;
int stage = 1;
int score = 0;
ArrayList movement;
String difficulty;

int AppleX, AppleY;
String AppleImg;
String[][] direction = new String[20][20];
int[] wallX, wallY;

int addSize = 1.5;
boolean allowPassThroughEdge = true;

SnakeList head;
SnakeList tail;

void setup() {
	size(width, height);
	frameRate(30);

	// Loads images
	loadImg();
}

void init() {
	movement = new ArrayList();
	wallX = new int[4];
	wallY = new int[4];
	score = 0;

	head = new SnakeList(10, 10, "RIGHT", "0.png", null);
	image(loadImage(head.image), head.x*dx - addSize, head.y*dy - addSize, 30 + 2*addSize, 30 + 2*addSize);
	direction[10][10] = "RIGHT";
	SnakeList n2 = new SnakeList(9, 10, "RIGHT", str(int(random() * 16) + 1) + ".png", null);
	head.next = n2;
	image(loadImage(n2.image), n2.x*dx - addSize, n2.y*dy - addSize, 30 + 2*addSize, 30 + 2*addSize);
	direction[9][10] = "RIGHT";
	SnakeList n3 = new SnakeList(8, 10, "RIGHT", str(int(random() * 16) + 1) + ".png", null);
	n2.next = n3;
	image(loadImage(n3.image), n3.x*dx - addSize, n3.y*dy - addSize, 30 + 2*addSize, 30 + 2*addSize);
	direction[8][10] = "RIGHT";
	SnakeList n4 = new SnakeList(7, 10, "RIGHT", str(int(random() * 16) + 1) + ".png", null);
	n3.next = n4;
	image(loadImage(n4.image), n4.x*dx - addSize, n4.y*dy - addSize, 30 + 2*addSize, 30 + 2*addSize);
	direction[7][10] = "RIGHT";
	tail = n4;

	generateWalls();
	generateApple();
}

void generateApple() {
	outloop: while(true) {
		AppleX = int(random() * 20);
		AppleY = int(random() * 20);

		SnakeList current = head;
		while(current != null) {
			if (current.x == AppleX && current.y == AppleY) {
				continue outloop;
			}
			current = current.next;
		}
		for (int i = 0; i < wallX.length; i++) {
			if (AppleX == wallX[i] && AppleY == wallY[i]) {
				continue outloop;
			}
		}
		break;
	}
	AppleImg = str(int(random() * 16) + 1) + ".png";
}

void generateWalls() {
	wallX[0] = int(random() * 10);
	wallY[0] = int(random() * 10);
	wallX[1] = int(random() * 10) + 10;
	wallY[1] = int(random() * 10);
	wallX[2] = int(random() * 10);
	wallY[2] = int(random() * 9) + 11;
	wallX[3] = int(random() * 10) + 10;
	wallY[3] = int(random() * 9) + 11;
}

class SnakeList {
	private int x, y;
	private String dir, image;
	private SnakeList next;

	SnakeList(int x, int y, String dir, String img, SnakeList next) {
		this.x = x; this.y = y; this.dir = dir; this.image = img; this.next = next;
	}

	void checkEdges() {
		if (allowPassThroughEdge) {
			if (x > 19)		x = 0;
			if (x < 0)		x = 19;
			if (y > 19)		y = 0;
			if (y < 0)		y = 19;
		}
		else {
			if (x > 19 || x < 0 || y > 19 || y < 0) {
				stage = 3;
			}
		}
	}
}

void renderSnake() {
	if (movement.size() > 0) {
		if (movement.get(0) == 1)		head.dir = "UP";
		else if (movement.get(0) == 2)	head.dir = "RIGHT";
		else if (movement.get(0) == 3)	head.dir = "DOWN";
		else if (movement.get(0) == 4)	head.dir = "LEFT";

		movement.remove(0);
	}
	SnakeList current = head;
	while (current != null) {
		if (current != head) {
			current.dir = direction[current.x][current.y];
		}
		else if (current == head) {
			direction[current.x][current.y] = current.dir;
		}

		if (current.dir.equals("UP"))	current.y -= 1;
		if (current.dir.equals("DOWN")) current.y += 1;
		if (current.dir.equals("LEFT"))	current.x -= 1;
		if (current.dir.equals("RIGHT"))	current.x += 1;

		current.checkEdges();

		image(loadImage(current.image), current.x*dx - addSize, current.y*dy - addSize, 30 + 2*addSize, 30 + 2*addSize);

		// Next vertex
		current = current.next;
	}
	checkCollisions();
}

void checkCollisions() {
	SnakeList current = head;
	current = current.next;
	while(current != null) {
		if (current.x == head.x && current.y == head.y) {
			stage = 3;
		}
		current = current.next;
	}
	for (int i = 0; i < wallX.length; i++) {
		if (head.x == wallX[i] && head.y == wallY[i]) {
			stage = 3;
		}
	}

	if (head.x == AppleX && head.y == AppleY) {
		addSegment();
		score++;
	}
}

void addSegment() {
	if (tail.dir.equals("UP")) {
		tail.next = new SnakeList(tail.x, tail.y+1, "UP", AppleImg, null);
		tail = tail.next;
	}
	else if (tail.dir.equals("RIGHT")) {
		tail.next = new SnakeList(tail.x-1, tail.y, "UP", AppleImg, null);
		tail = tail.next;
	}
	else if (tail.dir.equals("DOWN")) {
		tail.next = new SnakeList(tail.x, tail.y-1, "UP", AppleImg, null);
		tail = tail.next;
	}
	else if (tail.dir.equals("LEFT")) {
		tail.next = new SnakeList(tail.x+1, tail.y, "UP", AppleImg, null);
		tail = tail.next;
	}
	tail.checkEdges();

	generateApple();
}

void keyPressed() {
	if (stage == 2) {
		if (keyCode == UP) {
			if (!head.dir.equals("DOWN"))
				movement.add(1);
		}
		else if (keyCode == RIGHT) {
			if (!head.dir.equals("LEFT"))
				movement.add(2);
		}
		else if (keyCode == DOWN) {
			if (!head.dir.equals("UP"))
				movement.add(3);
		}
		else if (keyCode == LEFT) {
			if (!head.dir.equals("RIGHT"))
				movement.add(4);
		}
	}
}

void drawGameBackground() {
	background(0);
	stroke(255, 255, 255, 255 * 1/10);
	strokeWeight(2);

	// Drawing grid lines
	for (int x = dy; x < width; x += dy) {
		line(x, 0, x, height);
	}
	for (int y = dx; y < height; y += dx) {
		line(0, y, width, y);
	}

	// Draw walls
	fill(224,142,121);
	noStroke();
	for (int i = 0; i < wallX.length; i++) {
		rect(wallX[i]*dx + 3, wallY[i]*dy + 3, 30 - 2*3, 30 - 2*3);
	}

	// Draw orb around apple
	fill(255, 255, 255, 255 * 1/12);
	stroke(255, 255, 255, 255 * 1/3);
	ellipse(AppleX*dx + dx/2, AppleY*dy + dy/2, 30, 30);

	// Draw apple
	image(loadImage(AppleImg), AppleX*dx - addSize, AppleY*dy - addSize, 30 + 2*addSize, 30 + 2*addSize);
}

void drawStartScreen() {
	background(84,36,55);
	image(loadImage("main_logo.png"), 100, 100, 400);
	fill(283,119,122);
	textFont("sans-serif", 50);
	text("easy", 230, 350);
	text("medium", 200, 420);
	text("hard", 230, 490);

	// Draw eye
	noStroke();
	fill(255);
	ellipse(150, 102, 20, 20);
	fill(0);
	PVector locEye = new PVector(mouseX-150, mouseY-102);
	locEye.limit(6);
	ellipse(locEye.x + 150, locEye.y + 102, 5, 5);
}

void drawEndScreen() {
	fill(84,36,55, 255 * 9/10);
	rect(0, 0, 600, 600);

	textFont("sans-serif", 30);
	fill(217,91,67);
	text("score:", 200, 170);
	text("on", 420, 280);
	text(difficulty.toLowerCase(), 420, 320);
	text("mode", 420, 360);

	textFont("sans-serif", 200);
	fill(236,208,120);
	if (int(score / 10) == 0)
		text(score, 270, 360);
	else
		text(score, 180, 360);

	fill(217,91,67);
	textFont("sans-serif", 24);
	text("click anywhere to play again", 140, 500);
}

void mouseClicked() {
	if (stage == 1) {
		if (mouseX > 222 && mouseY > 316 && mouseX < 340 && mouseY < 354) {
			difficulty = "EASY";
			frameRate(10);
			stage = 2;
		}
		else if (mouseX > 196 && mouseY > 381 && mouseX < 382 && mouseY < 426) {
			difficulty = "MEDIUM";
			frameRate(15);
			stage = 2;
		}
		else if (mouseX > 217 && mouseY > 449 && mouseX < 333 && mouseY < 492) {
			difficulty = "HARD";
			frameRate(20);
			stage = 2;
		}
	}
	else if (stage == 0) {
		stage = 1;
	}
}

void draw() {
	if (stage == 1) {
		init();
		drawStartScreen();
	}
	else if (stage == 2) {
		drawGameBackground();
		renderSnake();
	}
	else if (stage == 3) {
		stage = 0;
		drawEndScreen();
	}
}

void loadImg() {
	/* @pjs preload="main_logo.png,0.png,1.png,2.png,3.png,4.png,5.png,6.png,7.png,8.png,9.png,10.png,11.png,12.png,13.png,14.png,15.png,16.png"; */
}