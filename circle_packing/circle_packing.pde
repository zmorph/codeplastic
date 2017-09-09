Pack pack;

boolean growing = false;

void setup() {
  size(1000, 600);

  background(0);
  noFill();
  stroke(255);

  noiseDetail(2, 0.1);

  pack = new Pack();
}

void draw() {
  background(50);

  pack.run();

  if (growing)
    pack.addBoid(new Node(width/2, height/2));
}


class Pack {
  ArrayList<Node> nodes;

  float max_speed = 1;
  float max_force = 1;

  Pack() {  
    initiate();
  }

  void initiate() {
    nodes = new ArrayList<Node>(); 
    for (int i = 0; i < 750; i++) {
      addBoid(new Node(width/2, height/2));
    }
  }

  void addBoid(Node b) {
    nodes.add(b);
  }

  void run() {

    PVector[] separate_forces = new PVector[nodes.size()];
    int[] near_nodes = new int[nodes.size()];

    for (int i=0; i<nodes.size(); i++) {
      checkBorders(i);
      updateNodeRadius(i);
      checkNodePosition(i);
      applySeparationForcesToNode(i, separate_forces, near_nodes);
      displayNode(i);
    }
  }

  void checkBorders(int i) {
    Node node_i=nodes.get(i);
    if (node_i.position.x-node_i.radius/2 < 0 || node_i.position.x+node_i.radius/2 > width)
    {
      node_i.velocity.x*=-1;
      node_i.update();
    }
    if (node_i.position.y-node_i.radius/2 < 0 || node_i.position.y+node_i.radius/2 > height)
    {
      node_i.velocity.y*=-1;
      node_i.update();
    }
  }

  void updateNodeRadius(int i) {
    nodes.get(i).updateRadius();
  }

  void checkNodePosition(int i) {

    Node node_i=nodes.get(i);

    for (int j=i+1; j<=nodes.size(); j++) {

      Node node_j = nodes.get(j == nodes.size() ? 0 : j);

      int count = 0;

      float d = PVector.dist(node_i.position, node_j.position);

      if (d < node_i.radius/2+node_j.radius/2) {
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
    if ((d > 0) && (d < n1.radius/2+n2.radius/2)) {
      PVector diff = PVector.sub(n1.position, n2.position);
      diff.normalize();
      diff.div(d);
      steer.add(diff);
    }
    return steer;
  }

  void displayNode(int i) {
    nodes.get(i).display();
  }
}

class Node {

  PVector position;
  PVector velocity;
  PVector acceleration;
  float radius;

  Node(float x, float y) {
    acceleration = new PVector(0, 0);
    velocity = PVector.random2D();
    position = new PVector(x, y);
    updateRadius();
  }

  void applyForce(PVector force) {
    acceleration.add(force);
  }

  void update() {
    //velocity.add(noise(100+position.x*0.01, 100+position.y*0.01)*0.5, noise(200+position.x*0.01, 200+position.y*0.01)*0.5); 
    velocity.add(acceleration);
    position.add(velocity);
    acceleration.mult(0);
  }

  void updateRadius() {
    radius = 2 + noise(position.x*0.01, position.y*0.01) * 50;
  }

  void display() {
    ellipse(position.x, position.y, radius, radius);
  }
}

void mouseDragged() {
  pack.addBoid(new Node(mouseX, mouseY));
}

void keyPressed() {
  if (key == 'r' || key == 'R') {
    pack.initiate();
    noiseSeed((long)random(100000));
  } else if (key == 'p' || key == 'P') {
    growing=!growing;
  }
}