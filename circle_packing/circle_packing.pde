Flock flock;
boolean growing = true;

void setup() {
  size(640, 360);
  noiseDetail(2,0.1);
  stroke(255);
  noFill();
  flock = new Flock();
  // Add an initial set of boids into the system
  for (int i = 0; i < 150; i++) {
    flock.addBoid(new Boid(width/2, height/2));
  }
}

void draw() {
  background(50);
  loadPixels();
  for (int y=0; y<height; y++) {
    for (int x=0; x<width; x++) {
      pixels[width*y+x] = color(noise(x*0.01, y*0.01) * 255.0); /*lerpColor(color(255, 0, 0), color(0, 0, 255), noise(x*0.01, y*0.01));*/
    }
  }
  updatePixels();
  flock.run();
  //flock.borders();

  if (growing)
    flock.addBoid(new Boid(width/2, height/2));
}

// Add a new boid into the System
void mousePressed() {
  flock.addBoid(new Boid(mouseX, mouseY));
}

void mouseDragged() {
  flock.addBoid(new Boid(mouseX, mouseY));
}



// The Flock (a list of Boid objects)

class Flock {
  ArrayList<Boid> boids; // An ArrayList for all the boids

  Flock() {
    boids = new ArrayList<Boid>(); // Initialize the ArrayList
  }

  void run() {
    for (Boid b : boids) {
      b.run(boids);  // Passing the entire list of boids to each boid individually
    }
  }

  void borders() {
    float border = 50;
    pushMatrix();
    translate(width/2, height/2);
    rectMode(CENTER);
    rect(0, 0, border*2, border*2);
    popMatrix();
  }

  void addBoid(Boid b) {
    boids.add(b);
  }

  void restart() {
    boids = new ArrayList<Boid>(); 
    for (int i = 0; i < 150; i++) {
      flock.addBoid(new Boid(width/2, height/2));
    }
  }
}




// The Boid class

class Boid {

  PVector position;
  PVector velocity;
  PVector acceleration;
  float r;
  float maxforce;    // Maximum steering force
  float maxspeed;    // Maximum speed

  Boid(float x, float y) {
    acceleration = new PVector(0, 0);

    // This is a new PVector method not yet implemented in JS
    // velocity = PVector.random2D();

    // Leaving the code temporarily this way so that this example runs in JS
    float angle = random(TWO_PI);
    velocity = new PVector(cos(angle), sin(angle));

    position = new PVector(x, y);
    //r = random(5, 20);
    updateRadius();
    maxspeed = 1;
    maxforce = 1;
  }

  void run(ArrayList<Boid> boids) {
    updateRadius();
    checkPosition(boids);
    flock(boids);
    update();
    //borders();
    render();
  }

  void applyForce(PVector force) {
    // We could add mass here if we want A = F / M
    acceleration.add(force);
  }

  // We accumulate a new acceleration each time based on three rules
  void flock(ArrayList<Boid> boids) {
    PVector sep = separate(boids);   // Separation
    applyForce(sep);
  }


  // Method to update position
  void update() {
    // Update velocity
    velocity.add(acceleration);
    // Limit speed
    velocity.limit(maxspeed);
    position.add(velocity);
    // Reset accelertion to 0 each cycle
    acceleration.mult(0);
  }

  void updateRadius() {
    r = 2 + noise(position.x*0.01, position.y*0.01) * 50;
  }

  void render() {
    ellipse(position.x, position.y, r, r);
  }

  // Wraparound
  void borders() {
    float border = 50;
    float left = width/2-border;
    float right = width/2+border;
    float top = height/2+border;
    float bottom = height/2-border;
    if (position.x < left+r/2) velocity.x = -velocity.x;
    if (position.y < top - r/2) velocity.y = -velocity.y;
    if (position.x > right-r/2) velocity.x = -velocity.x;
    if (position.y > bottom + r/2) velocity.y = -velocity.y;
  }

  void checkPosition (ArrayList<Boid> boids) {
    int count = 0;
    // For every boid in the system, check if it's too close
    for (Boid other : boids) {
      float d = PVector.dist(position, other.position);
      // If the distance is greater than 0 and less than an arbitrary amount
      if ((other!=this) && (d < r/2+other.r/2)) {
        count++;            // Keep track of how many
      }
    }
    // Zero velocity if no neighbours
    if (count == 0) {
      velocity.x = 0.0;
      velocity.y = 0.0;
    }
  }


  // Separation
  // Method checks for nearby boids and steers away
  PVector separate (ArrayList<Boid> boids) {
    PVector steer = new PVector(0, 0, 0);
    int count = 0;
    // For every boid in the system, check if it's too close
    for (Boid other : boids) {
      float d = PVector.dist(position, other.position);
      // If the distance is greater than 0 and less than an arbitrary amount (0 when you are yourself)
      if ((d > 0) && (d < r/2+other.r/2+5)) {
        // Calculate vector pointing away from neighbor
        PVector diff = PVector.sub(position, other.position);
        diff.normalize();
        diff.div(d);        // Weight by distance
        steer.add(diff);
        count++;            // Keep track of how many
      }
    }
    // Average -- divide by how many
    if (count > 0) {
      steer.div((float)count);
    }

    // As long as the vector is greater than 0
    if (steer.mag() > 0) {
      steer.setMag(maxspeed);
      steer.sub(velocity);
      steer.limit(maxforce);
    }
    return steer;
  }
}


void keyPressed() {
  if (key == 'r' || key == 'R') {
    flock.restart();
    noiseSeed((long)random(100000));
  } else if (key == 'p' || key == 'P') {
    growing=!growing;
  }
}