import processing.dxf.*;
import processing.svg.*;


Pack pack;

boolean growing = false;
int n_start = 100;

void setup() {
  size(1230, 600);

  noFill();
  strokeWeight(1.5);
  stroke(5);

  noiseDetail(2, 0.1);

  pack = new Pack(n_start);
}

void draw() {
  background(#f5f4f4);

  pack.run();

  if (growing)
    pack.addCircle(new Circle(width/2, height/2));

  //saveFrame("frames/#####.tif");
}


class Pack {
  ArrayList<Circle> circles;

  float max_speed = 1;
  float max_force = 1;

  float border = 5;

  float min_radius = 5;
  float max_radius = 200;

  Pack(int n) {  
    initiate(n);
  }

  void initiate(int n) {
    circles = new ArrayList<Circle>(); 
    for (int i = 0; i < n; i++) {
      addCircle(new Circle(width/2, height/2));
    }
  }

  void addCircle(Circle b) {
    circles.add(b);
  }

  void run() {

    PVector[] separate_forces = new PVector[circles.size()];
    int[] near_circles = new int[circles.size()];

    for (int i=0; i<circles.size(); i++) {
      checkBorders(i);
      updateCircleRadius(i);
      applySeparationForcesToCircle(i, separate_forces, near_circles);
      displayCircle(i);
    }
  }

  void checkBorders(int i) {
    Circle circle_i=circles.get(i);
    if (circle_i.position.x-circle_i.radius/2 < border)
      circle_i.position.x = circle_i.radius/2 + border;
    else if (circle_i.position.x+circle_i.radius/2 > width - border)
      circle_i.position.x = width - circle_i.radius/2 - border;
    if (circle_i.position.y-circle_i.radius/2 < border)
      circle_i.position.y = circle_i.radius/2 + border;
    else if (circle_i.position.y+circle_i.radius/2 > height - border)
      circle_i.position.y = height - circle_i.radius/2 - border;
  }

  void updateCircleRadius(int i) {
    circles.get(i).updateRadius(min_radius, max_radius);
  }

  void applySeparationForcesToCircle(int i, PVector[] separate_forces, int[] near_circles) {

    if (separate_forces[i]==null)
      separate_forces[i]=new PVector();

    Circle circle_i=circles.get(i);

    for (int j=i+1; j<circles.size(); j++) {

      if (separate_forces[j] == null) 
        separate_forces[j]=new PVector();

      Circle circle_j=circles.get(j);

      PVector forceij = getSeparationForce(circle_i, circle_j);

      if (forceij.mag()>0) {
        separate_forces[i].add(forceij);        
        separate_forces[j].sub(forceij);
        near_circles[i]++;
        near_circles[j]++;
      }
    }

    if (near_circles[i]>0) {
      separate_forces[i].div((float)near_circles[i]);
    }

    if (separate_forces[i].mag() >0) {
      separate_forces[i].setMag(max_speed);
      separate_forces[i].sub(circles.get(i).velocity);
      separate_forces[i].limit(max_force);
    }

    PVector separation = separate_forces[i];

    circles.get(i).applyForce(separation);
    circles.get(i).update();

    // If they have no intersecting neighbours they will stop moving
    circle_i.velocity.x = 0.0;
    circle_i.velocity.y = 0.0;
  }

  PVector getSeparationForce(Circle n1, Circle n2) {
    PVector steer = new PVector(0, 0, 0);
    float d = PVector.dist(n1.position, n2.position);
    if ((d > 0) && (d < n1.radius/2+n2.radius/2 + border)) {
      PVector diff = PVector.sub(n1.position, n2.position);
      diff.normalize();
      diff.div(d);
      steer.add(diff);
    }
    return steer;
  }

  String getSaveName() {
    return  day()+""+hour()+""+minute()+""+second();
  }

  void exportDXF() {
    String exportName = getSaveName()+".dxf";
    RawDXF dxf = (RawDXF)createGraphics(width, height, DXF, exportName);
    dxf.beginDraw();
    for (int i=0; i<circles.size(); i++) {
      Circle p = circles.get(i);
      dxfCircle(p.position.x, p.position.y, p.radius/2., dxf);
    }
    dxf.endDraw();
    dxf.dispose();
    dxf.endRaw();

    println(exportName + " saved.");
  } 

  void dxfCircle(float x, float y, float r, RawDXF dxf) {
    dxf.println("0");
    dxf.println("CIRCLE");
    dxf.println("10");
    dxf.println(Float.toString(x));
    dxf.println("20");
    dxf.println(Float.toString(height - y));
    dxf.println("40");
    dxf.println(Float.toString(r));
  }

  void exportSVG() {
    String exportName = getSaveName()+".svg";
    PGraphics pg = createGraphics(width, height, SVG, exportName);
    pg.beginDraw();
    pg.rect(0, 0, width, height);
    for (int i=0; i<circles.size(); i++) {
      Circle p = circles.get(i);
      pg.ellipse(p.position.x, p.position.y, p.radius, p.radius);
    } 
    pg.endDraw();
    pg.dispose();
    println(exportName + " saved.");
  }

  void displayCircle(int i) {
    circles.get(i).display();
  }
}

class Circle {

  PVector position;
  PVector velocity;
  PVector acceleration;

  float radius = 1;

  Circle(float x, float y) {
    acceleration = new PVector(0, 0);
    velocity = PVector.random2D();
    position = new PVector(x, y);
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

  void updateRadius(float min, float max) {
    radius = min + noise(position.x*0.01, position.y*0.01) * (max-min);
  }

  void display() {
    ellipse(position.x, position.y, radius, radius);
  }
}

void mouseDragged() {
  pack.addCircle(new Circle(mouseX, mouseY));
}

void mouseClicked() {
  pack.addCircle(new Circle(mouseX, mouseY));
}

void keyPressed() {
  if (key == 'r' || key == 'R') {
    pack.initiate(n_start);
    noiseSeed((long)random(100000));
  } else if (key == 'p' || key == 'P') {
    growing=!growing;
  } else if (key == 's' || key == 'S') {
    String name = ""+day()+hour()+minute()+second();
    pack.exportDXF();
    pack.exportSVG();
    saveFrame(name+".png");
    println(name + " saved.");
  }
}
