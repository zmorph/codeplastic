Pack pack;
boolean growing = false;

void setup() {
  size(640, 360);

  noiseDetail(2, 0.1);
  stroke(255);
  noFill();

  pack = new Pack();
  pack.restart();
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

  pack.run();

  if (growing)
    pack.addBoid(new Node(width/2, height/2));
}


class Pack {
  ArrayList<Node> nodes; // An ArrayList for all the boids

  float max_speed = 1;
  float max_force = 1;

  Pack() {
    nodes = new ArrayList<Node>(); // Initialize the ArrayList
  }

  void run() {
    
    PVector[] separate_forces = new PVector[nodes.size()];
    int[] near_nodes = new int[nodes.size()];
    
    for (int i=0; i<nodes.size(); i++) {
      updateNodeRadius(i);
      checkNodePosition(i);
      applySeparationForcesToNode(i, separate_forces, near_nodes);
      displayNode(i);
    }
  }

  void checkNodePosition(int i) {

    Node node_i=nodes.get(i);

    for (int j=i+1; j<=nodes.size(); j++) {

      Node node_j = nodes.get(j == nodes.size() ? 0 : j);

      int count = 0;

      float d = PVector.dist(node_i.position, node_j.position);

      if (d < node_i.r/2+node_j.r/2) {
        count++;
      }

      // Zero velocity if no neighbours
      if (count == 0) {
        node_i.velocity.x = 0.0;
        node_i.velocity.y = 0.0;
      }
    }
  }


  void applySeparationForcesToNode(int i, PVector[] separate_forces, int[] near_nodes) {

    if (separate_forces[i]==null)
      separate_forces[i]=new PVector();

    Node node_i=nodes.get(i);

    for (int j=i+1; j<nodes.size(); j++) {

      if (separate_forces[j] == null) 
        separate_forces[j]=new PVector();

      Node node_j=nodes.get(j);

      PVector forceij = getSeparationForce(node_i, node_j);

      if (forceij.mag()>0) {
        separate_forces[i].add(forceij);        
        separate_forces[j].sub(forceij);
        near_nodes[i]++;
        near_nodes[j]++;
      }
    }

    if (near_nodes[i]>0) {
      separate_forces[i].div((float)near_nodes[i]);
    }

    if (separate_forces[i].mag() >0) {
      separate_forces[i].setMag(max_speed);
      separate_forces[i].sub(nodes.get(i).velocity);
      separate_forces[i].limit(max_force);
    }

    PVector separation = separate_forces[i];

    nodes.get(i).applyForce(separation);
    nodes.get(i).update();
  }

  PVector getSeparationForce(Node n1, Node n2) {
    PVector steer = new PVector(0, 0, 0);
    float d = PVector.dist(n1.position, n2.position);
    if ((d > 0) && (d < n1.r/2+n2.r/2)) {
      PVector diff = PVector.sub(n1.position, n2.position);
      diff.normalize();
      diff.div(d);        // Weight by distance
      steer.add(diff);
    }
    return steer;
  }

  void updateNodeRadius(int i) {
    nodes.get(i).updateRadius();
  }

  void displayNode(int i) {
    nodes.get(i).render();
  }

  void addBoid(Node b) {
    nodes.add(b);
  }

  void restart() {
    nodes = new ArrayList<Node>(); 
    for (int i = 0; i < 100; i++) {
      pack.addBoid(new Node(width/2, height/2));
    }
  }
}

class Node {

  PVector position;
  PVector velocity;
  PVector acceleration;
  float r;

  Node(float x, float y) {
    acceleration = new PVector(0, 0);
    velocity = PVector.random2D();
    position = new PVector(x, y);
    updateRadius();
  }

  void applyForce(PVector force) {
    acceleration.add(force);
  }

  // Method to update position
  void update() {
    // Update velocity
    velocity.add(acceleration);
    // Limit speed
    //velocity.limit(maxspeed);
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
}

// Add a new boid into the System
void mousePressed() {
  pack.addBoid(new Node(mouseX, mouseY));
}

void mouseDragged() {
  pack.addBoid(new Node(mouseX, mouseY));
}

void keyPressed() {
  if (key == 'r' || key == 'R') {
    pack.restart();
    noiseSeed((long)random(100000));
  } else if (key == 'p' || key == 'P') {
    growing=!growing;
  }
}